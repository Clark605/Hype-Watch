/// Human-readable hype reason statements shown in the app UI.
///
/// These explain WHY a match has a high hype score — the "story" behind the number.
/// Each match card shows up to 3 reason tags (the top 3 by priority).
///
/// Reasons are evaluated at runtime by HypeScoreCalculator and
/// returned as a List<HypeReason> alongside the numeric score.
///
/// Usage in UI:
///   match.hyp eReasons.take(3).forEach((r) => HypeTag(label: r.label))
///
/// Example output for Brazil vs Morocco:
///   🔥 "2022 WC Rematch"   🏆 "Both Top 10"   ⚔️ "Group Stage Decider"
class HypeReasons {
  HypeReasons._();

  // ─── Stage Reasons ───────────────────────────────────────────────────────────

  static const String worldCupFinal = '🏆 World Cup Final';
  static const String semifinal = '🔥 Semifinal Showdown';
  static const String quarterFinal = '⚡ Quarterfinal Clash';
  static const String roundOf16 = '🎯 Knockout Stage';
  static const String roundOf32 = '🎯 First Knockout Round';
  static const String groupStageDecider = '📍 Group Stage Decider';
  static const String mustWinGame = '🚨 Must-Win Game';
  static const String eliminationThreat = '⚠️ Elimination on the Line';
  static const String deadRubber = '😴 Dead Rubber';

  // ─── Rivalry Reasons ─────────────────────────────────────────────────────────

  static const String classicRivalry = '⚔️ Classic Rivalry';
  static const String historicRivalry = '🏟️ Historic Rivalry';
  static const String recentRematch = '🔄 Recent Rematch';
  static const String continentalDerby = '🌍 Continental Derby';
  static const String politicalRivalry = '🔥 Politically Charged';
  static const String davidVsGoliath = '🐣 David vs Goliath';
  static const String debutMatch = '🌟 World Cup Debut';
  static const String hostNationMatch = '🏠 Host Nation Playing';
  static const String coHostsClash = '🏠🏠 Co-Hosts Clash';

  // ─── Team Quality Reasons ────────────────────────────────────────────────────

  static const String bothTopTen = '🌟 Both Top 10 Teams';
  static const String bothTopFive = '👑 Both Top 5 Favorites';
  static const String titleContender = '🏆 Title Contender Involved';
  static const String defendingChampion = '🥇 Defending Champions';
  static const String formerChampionClash = '🏆🏆 Former Champions Clash';

  // ─── Stakes Reasons ──────────────────────────────────────────────────────────

  static const String bothNeedPoints = '📊 Both Teams Need Points';
  static const String topOfGroup = '🥇 Clash for Group Leadership';
  static const String onTeamEliminationEdge = '⚠️ One Team Already Eliminated';
  static const String groupWinnerDecider = '🎖️ Winner Takes the Group';
  static const String qualificationDecider = '🎫 Final Qualification Spot';

  // ─── Goal Threat Reasons ─────────────────────────────────────────────────────

  static const String highScoring = '⚽ High-Scoring Teams';
  static const String attackingSpectacle = '🎆 Attacking Spectacle Expected';
  static const String goalFest = '🎯 Goal Fest Potential';

  // ─── Specific Matchup Narratives (hardcoded for known group fixtures) ─────────
  /// These override generic reasons for specific iconic group matches.
  /// Key: sorted team codes joined by '_'

  static const Map<String, List<String>> matchNarratives = {
    // Group A
    'KOR_MEX': [
      '🔄 Korea Shocked Mexico in 2018',
      '🏠 Host Nation Pressure',
      '📍 Group Opener Stakes',
    ],
    'CZE_KOR': ['🌍 Europe vs Asia Clash', '⚡ Qualification Battle'],

    // Group B
    'BIH_SUI': ['🌍 Balkan vs Alpine Neighbors', '⚡ European Grudge Match'],
    'QAT_SUI': ['🔄 2022 WC Group Stage Rematch', '⚠️ Qatar Needs a Win'],

    // Group C
    'BRA_MAR': [
      '🔄 2022 WC Quarterfinal Rematch',
      '🌟 Both Top 10 Teams',
      '🔥 Morocco Shocked the World',
    ],
    'BRA_SCO': [
      '👑 Brazil Favorites vs Underdog Scotland',
      '📍 Group Stage Opener',
    ],
    'HAI_MAR': ['🌍 African Giant vs Caribbean Debut', '🐣 Haiti\'s WC Moment'],

    // Group D
    'TUR_USA': [
      '🔥 NATO Nations Clash',
      '🏠 USA on Home Soil',
      '⚡ Knockout-Level Quality',
    ],
    'AUS_USA': ['🏠 USA Playing at Home', '🌏 Pacific vs Americas'],

    // Group E
    'CUW_GER': [
      '🐣 Smallest Nation vs Germany',
      '🌟 David vs Goliath',
      '🏟️ Historic WC Debut',
    ],
    'CIV_GER': ['🔄 2006 WC Rematch', '🌍 Africa vs European Giant'],
    'ECU_GER': [
      '🔄 2006 WC Group Stage Rematch',
      '⚽ Ecuador\'s Attacking Threat',
    ],

    // Group F
    'NED_SWE': ['🌍 Northern Europe Derby', '⚡ Scandinavia vs Dutch Masters'],
    'JPN_NED': ['🔄 2010 WC R16 Rematch', '🌏 Asia vs European Elite'],

    // Group G
    'BEL_EGY': ['🔄 1994 WC Rematch', '🌍 Africa vs Belgium\'s Golden Gen'],
    'EGY_IRN': [
      '🔥 Middle East vs North Africa Rivalry',
      '⚡ Battle of the Continents',
    ],

    // Group H
    'ESP_URU': [
      '🏆🏆 Former Champions Clash',
      '🔄 1950 WC History',
      '👑 Spain vs South American Giants',
    ],
    'CPV_ESP': [
      '🐣 Cabo Verde\'s World Stage Debut',
      '🌍 David vs Spanish Giant',
    ],
    'KSA_URU': ['🔄 1994 WC Rematch', '🌍 South America vs Middle East'],

    // Group I
    'FRA_SEN': [
      '🔥 2002 WC Upset Rematch',
      '🏟️ Colonial History + Football Pride',
      '👑 France Favorites Under Pressure',
    ],
    'FRA_NOR': [
      '🔄 1998 WC Group Stage Rematch',
      '🌟 Erling Haaland vs World Champions',
    ],
    'NOR_SEN': ['🔄 2002 WC Group Stage Rematch'],

    // Group J
    'ALG_ARG': [
      '🔄 2014 WC R16 Rematch',
      '🔥 Algeria Dreams of Another Upset',
      '🥇 Defending Champions',
    ],
    'ARG_AUT': ['🏟️ Historical WC Rivals', '🥇 Defending Champions Playing'],
    'ARG_JOR': [
      '🐣 Jordan\'s First World Cup vs Champions',
      '🌟 Messi vs Underdogs',
    ],
    'ALG_AUT': [
      '🏟️ 1982 WC Disgrace of Gijón Legacy',
      '🔥 Redemption Narrative',
    ],

    // Group K
    'COL_POR': [
      '🔄 2014 WC Group Stage Rematch',
      '🌟 Both Dark Horse Contenders',
    ],
    'POR_UZB': [
      '🐣 Uzbekistan\'s World Cup Debut',
      '🌟 Ronaldo Era vs New Blood',
    ],
    'COD_POR': ['🌍 African Giant vs European Power', '🏟️ Colonial Narrative'],

    // Group L
    'CRO_ENG': [
      '🔥 2018 WC Semifinal Revenge Match',
      '⚔️ One of WC\'s Biggest Rivalries',
      '⚡ Knockout-Level Quality',
    ],
    'ENG_GHA': ['🔄 2006 WC R16 Rematch', '🌍 Africa vs England'],
    'ENG_PAN': [
      '🔄 2018 WC — England Won 6-1',
      '🏠 England\'s Tournament Ambitions',
    ],
    'CRO_GHA': [
      '🔄 Three WC Meetings — 2006, 2014, 2026',
      '⚡ Competitive African vs European Clash',
    ],
  };

  /// Returns narrative tags for a specific matchup if they exist,
  /// otherwise returns an empty list (HypeScoreCalculator builds generic ones).
  static List<String> getNarrative(String teamACode, String teamBCode) {
    final codes = [teamACode.toUpperCase(), teamBCode.toUpperCase()]..sort();
    final key = '${codes[0]}_${codes[1]}';
    return matchNarratives[key] ?? [];
  }
}
