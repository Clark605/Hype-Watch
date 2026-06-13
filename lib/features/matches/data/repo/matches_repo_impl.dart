import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:world_cup_watch/core/constants/api_constants.dart';
import 'package:world_cup_watch/core/error/error_message_helper.dart';
import 'package:world_cup_watch/core/network/dio_client.dart';
import 'package:world_cup_watch/core/network/result_api.dart';
import 'package:world_cup_watch/features/matches/data/models/group_model.dart';
import 'package:world_cup_watch/features/matches/data/models/match_model.dart';
import 'package:world_cup_watch/features/matches/data/models/team_model.dart';
import 'package:world_cup_watch/features/matches/data/repo/matches_repo.dart';

@LazySingleton(as: MatchesRepository)
class MatchesRepositoryImpl implements MatchesRepository {
  final DioClient _dioClient;

  // ── In-memory cache ─────────────────────────────────────────────────────────
  // Prevents redundant API calls within the same session.
  // If the API goes down mid-session, the last successful response is returned.
  List<Match>? _cachedMatches;
  List<Groups>? _cachedGroups;
  List<Team>? _cachedTeams;

  MatchesRepositoryImpl(this._dioClient);

  // ── getMatches ───────────────────────────────────────────────────────────────
  @override
  Future<ResultApi<List<Match>>> getMatches() async {
    try {
      final response = await _dioClient.dio.get(ApiConstants.gamesEp);
      final model = MatchModel.fromJson(response.data);
      final matches = model.games ?? [];
      _cachedMatches = matches;
      return SuccessApi(matches);
    } on DioException catch (e) {
      // Return cached data if available so the UI doesn't break on network error
      if (_cachedMatches != null) return SuccessApi(_cachedMatches!);
      return ErrorApi(ErrorMessageHelper.getErrorMessage(e));
    } catch (e) {
      if (_cachedMatches != null) return SuccessApi(_cachedMatches!);
      return ErrorApi('Unexpected error: ${e.toString()}');
    }
  }

  // ── getGroups ────────────────────────────────────────────────────────────────
  @override
  Future<ResultApi<List<Groups>>> getGroups() async {
    try {
      final response = await _dioClient.dio.get(ApiConstants.groupsEp);
      final model = GroupModel.fromJson(response.data as Map<String, dynamic>);
      final groups = model.groups ?? [];
      _cachedGroups = groups;
      return SuccessApi(groups);
    } on DioException catch (e) {
      if (_cachedGroups != null) return SuccessApi(_cachedGroups!);
      return ErrorApi(ErrorMessageHelper.getErrorMessage(e));
    } catch (e) {
      if (_cachedGroups != null) return SuccessApi(_cachedGroups!);
      return ErrorApi('Unexpected error: ${e.toString()}');
    }
  }

  // ── getTeams ─────────────────────────────────────────────────────────────────
  @override
  Future<ResultApi<List<Team>>> getTeams() async {
    try {
      final response = await _dioClient.dio.get(ApiConstants.teamsEp);
      final model = TeamModel.fromJson(response.data as Map<String, dynamic>);
      final teams = model.teams ?? [];
      _cachedTeams = teams;
      return SuccessApi(teams);
    } on DioException catch (e) {
      if (_cachedTeams != null) return SuccessApi(_cachedTeams!);
      return ErrorApi(ErrorMessageHelper.getErrorMessage(e));
    } catch (e) {
      if (_cachedTeams != null) return SuccessApi(_cachedTeams!);
      return ErrorApi('Unexpected error: ${e.toString()}');
    }
  }
}
