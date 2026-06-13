/// FIFA World Rankings for all 48 teams at the 2026 World Cup.
///
/// Source: NBC Sports power rankings (June 11, 2026).
/// Rank 1 = strongest team, 48 = weakest.
/// These rankings are static for the duration of the tournament
/// and are used as an input to the HypeScoreCalculator.
///
/// Key: FIFA country code (matches worldcup26.ir /get/teams response)
/// Value: Tournament strength rank (1–48), lower = stronger
class FifaRankings {
  FifaRankings._();

  /// Returns the strength rank for a given country code.
  /// Returns 48 (weakest) if the country code is not found.
  static int getRank(String countryCode) {
    return _rankings[countryCode.toUpperCase()] ?? 48;
  }

  /// Normalizes a rank (1–48) to a 0–10 hype score contribution.
  /// Rank 1  → 10.0 (strongest)
  /// Rank 48 → 0.0  (weakest)
  static double normalizeRank(int rank) {
    return ((48 - rank) / 47) * 10;
  }

  /// Returns the combined team quality score (0–10) for a match,
  /// averaged from both teams' normalized ranks.
  static double matchQualityScore(String teamACode, String teamBCode) {
    final rankA = normalizeRank(getRank(teamACode));
    final rankB = normalizeRank(getRank(teamBCode));
    return (rankA + rankB) / 2;
  }

  // ─── Rankings map ────────────────────────────────────────────────────────────
  // Format: 'FIFA_CODE': strengthRank
  // Source: NBC Sports 2026 World Cup power rankings, June 11, 2026

  static const Map<String, int> _rankings = {
    // ── The Favorites (1–6) ──────────────────────────────────────────────────
    'FRA': 1, // France
    'ESP': 2, // Spain
    'ARG': 3, // Argentina
    'ENG': 4, // England
    'POR': 5, // Portugal
    'BRA': 6, // Brazil
    // ── Legit Darkhorses (7–12) ──────────────────────────────────────────────
    'MAR': 7, // Morocco
    'NED': 8, // Netherlands
    'BEL': 9, // Belgium
    'GER': 10, // Germany
    'SEN': 11, // Senegal
    'ECU': 12, // Ecuador
    // ── Potential Darkhorses (13–24) ─────────────────────────────────────────
    'JPN': 13, // Japan
    'TUR': 14, // Türkiye
    'COL': 15, // Colombia
    'SUI': 16, // Switzerland
    'CRO': 17, // Croatia
    'USA': 18, // United States
    'CAN': 19, // Canada
    'NOR': 20, // Norway
    'URU': 21, // Uruguay
    'MEX': 22, // Mexico
    'AUT': 23, // Austria
    'SCO': 24, // Scotland
    // ── The Upstarts (25–36) ─────────────────────────────────────────────────
    'KOR': 25, // South Korea
    'EGY': 26, // Egypt
    'CIV': 27, // Ivory Coast
    'CZE': 28, // Czechia
    'AUS': 29, // Australia
    'PAR': 30, // Paraguay
    'SWE': 31, // Sweden
    'IRN': 32, // Iran
    'BIH': 33, // Bosnia and Herzegovina
    'ALG': 34, // Algeria
    'GHA': 35, // Ghana
    'KSA': 36, // Saudi Arabia
    // ── The Minnows (37–48) ──────────────────────────────────────────────────
    'RSA': 37, // South Africa
    'UZB': 38, // Uzbekistan
    'TUN': 39, // Tunisia
    'CPV': 40, // Cape Verde
    'COD': 41, // DR Congo
    'PAN': 42, // Panama
    'QAT': 43, // Qatar
    'HAI': 44, // Haiti
    'IRQ': 45, // Iraq
    'CUW': 46, // Curaçao
    'NZL': 47, // New Zealand
    'JOR': 48, // Jordan
  };
}
