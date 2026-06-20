import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';
import 'package:world_cup_watch/core/constants/api_constants.dart';
import 'package:world_cup_watch/core/error/error_message_helper.dart';
import 'package:world_cup_watch/core/network/dio_client.dart';
import 'package:world_cup_watch/core/network/result_api.dart';
import 'package:world_cup_watch/features/matches/data/models/group_model.dart';
import 'package:world_cup_watch/features/matches/data/models/match_model.dart';
import 'package:world_cup_watch/features/matches/data/models/stadium_model.dart';
import 'package:world_cup_watch/features/matches/data/models/team_model.dart';
import 'package:world_cup_watch/features/matches/data/repo/matches_repo.dart';

@LazySingleton(as: MatchesRepository)
class MatchesRepositoryImpl implements MatchesRepository {
  final DioClient _dioClient;

  // ── On-disk cache filenames ───────────────────────────────────────────────
  // We cache the raw JSON response body (not parsed Dart objects), so reading
  // it back just runs through the same fromJson constructors already used
  // for live API responses — no toJson() needed on any model.
  static const String _matchesCacheFile = 'cache_matches.json';
  static const String _groupsCacheFile = 'cache_groups.json';
  static const String _teamsCacheFile = 'cache_teams.json';

  // Stadium cache keyed by ID — separate concern, stays in-memory per
  // session as before (not part of the stale-while-revalidate flow).
  final Map<String, Stadium> _cachedStadiums = {};

  MatchesRepositoryImpl(this._dioClient);

  // ── getMatches ───────────────────────────────────────────────────────────────
  @override
  Future<ResultApi<List<Match>>> getMatches() async {
    try {
      final response = await _requestWithRetry(
        () => _dioClient.dio.get(ApiConstants.gamesEp),
      );
      final rawJson = response.data as Map<String, dynamic>;
      await _writeCache(_matchesCacheFile, rawJson);
      final model = MatchModel.fromJson(rawJson);
      return SuccessApi(model.games ?? []);
    } on DioException catch (e) {
      return ErrorApi(ErrorMessageHelper.getErrorMessage(e));
    } catch (e) {
      return ErrorApi('Unexpected error: ${e.toString()}');
    }
  }

  // ── getGroups ────────────────────────────────────────────────────────────────
  @override
  Future<ResultApi<List<Groups>>> getGroups() async {
    try {
      final response = await _requestWithRetry(
        () => _dioClient.dio.get(ApiConstants.groupsEp),
      );
      final rawJson = response.data as Map<String, dynamic>;
      await _writeCache(_groupsCacheFile, rawJson);
      final model = GroupModel.fromJson(rawJson);
      return SuccessApi(model.groups ?? []);
    } on DioException catch (e) {
      return ErrorApi(ErrorMessageHelper.getErrorMessage(e));
    } catch (e) {
      return ErrorApi('Unexpected error: ${e.toString()}');
    }
  }

  // ── getTeams ─────────────────────────────────────────────────────────────────
  @override
  Future<ResultApi<List<Team>>> getTeams() async {
    try {
      final response = await _requestWithRetry(
        () => _dioClient.dio.get(ApiConstants.teamsEp),
      );
      final rawJson = response.data as Map<String, dynamic>;
      await _writeCache(_teamsCacheFile, rawJson);
      final model = TeamModel.fromJson(rawJson);
      return SuccessApi(model.teams ?? []);
    } on DioException catch (e) {
      return ErrorApi(ErrorMessageHelper.getErrorMessage(e));
    } catch (e) {
      return ErrorApi('Unexpected error: ${e.toString()}');
    }
  }

  // ── getStadiumById ────────────────────────────────────────────────────────────
  /// Fetches a single stadium by ID. Returns cached result if already fetched.
  /// Not part of the stale-while-revalidate flow — different access pattern
  /// (per-match, on-demand), so it keeps its own simple in-memory cache.
  @override
  Future<ResultApi<Stadium>> getStadiumById(String stadiumId) async {
    if (_cachedStadiums.containsKey(stadiumId)) {
      return SuccessApi(_cachedStadiums[stadiumId]!);
    }
    try {
      final response = await _requestWithRetry(
        () => _dioClient.dio.get('${ApiConstants.stadiumEp}/$stadiumId'),
      );
      final stadium = StadiumModel.fromJson(
        response.data as Map<String, dynamic>,
      );
      _cachedStadiums[stadiumId] = stadium.stadium!;
      return SuccessApi(stadium.stadium!);
    } on DioException catch (e) {
      return ErrorApi(ErrorMessageHelper.getErrorMessage(e));
    } catch (e) {
      return ErrorApi('Unexpected error: ${e.toString()}');
    }
  }

  // ── Cached reads (no network) ─────────────────────────────────────────────────
  @override
  Future<List<Match>?> getCachedMatches() async {
    final json = await _readCache(_matchesCacheFile);
    if (json == null) return null;
    return MatchModel.fromJson(json).games;
  }

  @override
  Future<List<Groups>?> getCachedGroups() async {
    final json = await _readCache(_groupsCacheFile);
    if (json == null) return null;
    return GroupModel.fromJson(json).groups;
  }

  @override
  Future<List<Team>?> getCachedTeams() async {
    final json = await _readCache(_teamsCacheFile);
    if (json == null) return null;
    return TeamModel.fromJson(json).teams;
  }

  // ── Disk cache helpers ─────────────────────────────────────────────────────────
  Future<File> _cacheFile(String filename) async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$filename');
  }

  Future<void> _writeCache(String filename, Map<String, dynamic> json) async {
    try {
      final file = await _cacheFile(filename);
      await file.writeAsString(jsonEncode(json));
    } catch (_) {
      // Cache write is best-effort — the fetch already succeeded and the
      // Cubit already has fresh data. A failed write just means next cold
      // start won't have a cache to read; not worth surfacing as an error.
    }
  }

  Future<Map<String, dynamic>?> _readCache(String filename) async {
    try {
      final file = await _cacheFile(filename);
      if (!await file.exists()) return null;
      final contents = await file.readAsString();
      return jsonDecode(contents) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  // ── Retry wrapper ──────────────────────────────────────────────────────────────
  /// Retries a Dio request up to 3 attempts total, immediately (no backoff).
  /// Skips retrying — fails fast — for a genuine "no internet" error, since
  /// retrying that immediately has no real chance of succeeding.
  /// All other DioExceptions (timeouts, 5xx, etc.) get retried.
  Future<Response> _requestWithRetry(
    Future<Response> Function() request,
  ) async {
    const maxAttempts = 3;
    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        return await request();
      } on DioException catch (e) {
        final isNoInternet =
            e.type == DioExceptionType.connectionError ||
            e.error is SocketException;

        if (isNoInternet || attempt == maxAttempts) rethrow;
        // otherwise loop and retry immediately
      }
    }
    // Unreachable — loop either returns or rethrows on the final attempt.
    throw StateError('Unreachable');
  }
}
