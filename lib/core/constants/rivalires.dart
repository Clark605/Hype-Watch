/// Rivalry scores for matches that CAN actually happen in the 2026 World Cup.
///
/// Covers two tiers:
/// 1. GROUP STAGE — guaranteed matches within each group (teams in same group WILL meet)
/// 2. KNOCKOUT STAGE — known rivalries between teams from different groups
///    that could realistically meet in R32 → Final.
///
/// Official 2026 World Cup Groups (December 5, 2025 draw):
/// Group A: Mexico, South Africa, South Korea, Czechia
/// Group B: Canada, Bosnia & Herzegovina, Qatar, Switzerland
/// Group C: Brazil, Morocco, Haiti, Scotland
/// Group D: United States, Paraguay, Australia, Türkiye
/// Group E: Germany, Curaçao, Côte d'Ivoire, Ecuador
/// Group F: Netherlands, Japan, Sweden, Tunisia
/// Group G: Belgium, Egypt, IR Iran, New Zealand
/// Group H: Spain, Cabo Verde, Saudi Arabia, Uruguay
/// Group I: France, Senegal, Iraq, Norway
/// Group J: Argentina, Algeria, Austria, Jordan
/// Group K: Portugal, Congo DR, Uzbekistan, Colombia
/// Group L: England, Croatia, Ghana, Panama
///
/// Score guide:
///   9.0–10.0 → All-time classic, unmissable
///   7.0–8.9  → Major rivalry, historically significant
///   5.0–6.9  → Regional/competitive, always interesting
///   3.0–4.9  → Some history, mild interest
///   1.0–2.9  → Rarely meet, minimal rivalry
///   0.0      → Default (no known rivalry)
class Rivalries {
  Rivalries._();

  /// Returns rivalry score (0.0–10.0) between two teams.
  /// Falls back to [_defaultScore] if no rivalry is defined.
  static double getRivalryScore(String teamACode, String teamBCode) {
    if (teamACode.toUpperCase() == teamBCode.toUpperCase()) return 0.0;

    final codes = [teamACode.toUpperCase(), teamBCode.toUpperCase()]..sort();
    final key = '${codes[0]}_${codes[1]}';

    return _rivalries[key] ?? _defaultScore;
  }

  static const double _defaultScore = 2.0;

  static const Map<String, double> _rivalries = {
    // ════════════════════════════════════════════════════════════════
    // GROUP STAGE — GUARANTEED MATCHES
    // Every combination within each group will definitely happen
    // ════════════════════════════════════════════════════════════════

    // ── Group A: Mexico, South Africa, South Korea, Czechia ──────────
    'MEX_RSA': 4.0, // Mexico vs South Africa — decent opener, host team energy
    'KOR_MEX': 5.5, // South Korea vs Mexico — 2018 WC shock (Korea won 2-1)
    'CZE_MEX': 4.0, // Czechia vs Mexico — little history
    'KOR_RSA': 3.0, // South Korea vs South Africa — rarely meet
    'CZE_RSA': 2.0, // Czechia vs South Africa — minimal history
    'CZE_KOR':
        5.0, // Czechia vs South Korea — competitive European vs Asian clash
    // ── Group B: Canada, Bosnia & Herzegovina, Qatar, Switzerland ────
    'BIH_CAN': 3.0, // Bosnia vs Canada — first ever meeting likely
    'CAN_SUI': 4.0, // Canada vs Switzerland — CONCACAF vs European clash
    'CAN_QAT': 3.5, // Canada vs Qatar — host nation vs 2022 hosts
    'BIH_QAT': 2.5, // Bosnia vs Qatar — rarely meet
    'BIH_SUI': 5.0, // Bosnia vs Switzerland — Balkan neighbors, some rivalry
    'QAT_SUI': 3.0, // Qatar vs Switzerland — 2022 WC group stage rematch
    // ── Group C: Brazil, Morocco, Haiti, Scotland ─────────────────────
    'BRA_MAR':
        8.0, // Brazil vs Morocco — 2022 WC QF rematch (Morocco shocked everyone)
    'BRA_HAI': 3.5, // Brazil vs Haiti — CONMEBOL vs Caribbean, comfortable
    'BRA_SCO': 5.5, // Brazil vs Scotland — classic friendly history
    'HAI_MAR': 3.0, // Haiti vs Morocco — first meeting likely
    'MAR_SCO': 4.5, // Morocco vs Scotland — Africa vs Europe
    'HAI_SCO': 2.5, // Haiti vs Scotland — minimal history
    // ── Group D: United States, Paraguay, Australia, Türkiye ─────────
    'PAR_USA': 5.5, // Paraguay vs USA — CONCACAF-adjacent rivalry
    'AUS_USA': 5.0, // Australia vs USA — English-speaking giants
    'TUR_USA': 6.0, // Türkiye vs USA — political undertones, NATO nations
    'AUS_PAR': 3.5, // Australia vs Paraguay — rarely meet
    'PAR_TUR': 3.0, // Paraguay vs Türkiye — minimal history
    'AUS_TUR': 4.0, // Australia vs Türkiye — some competitive history
    // ── Group E: Germany, Curaçao, Côte d'Ivoire, Ecuador ───────────
    'CIV_GER': 5.0, // Côte d'Ivoire vs Germany — 2006 WC group stage meeting
    'CUW_GER':
        7.5, // Curaçao vs Germany — David vs Goliath, smallest nation vs powerhouse
    'ECU_GER': 5.0, // Ecuador vs Germany — 2006 WC group stage rematch
    'CIV_CUW': 3.0, // Côte d'Ivoire vs Curaçao — debut match for Curaçao at WC
    'CIV_ECU': 4.0, // Côte d'Ivoire vs Ecuador — Africa vs South America
    'CUW_ECU': 3.5, // Curaçao vs Ecuador — CONCACAF vs CONMEBOL
    // ── Group F: Netherlands, Japan, Sweden, Tunisia ─────────────────
    'JPN_NED': 6.0, // Japan vs Netherlands — 2010 WC R16 (Netherlands won 1-0)
    'NED_SWE': 6.5, // Netherlands vs Sweden — Northern Europe rivalry
    'NED_TUN': 4.5, // Netherlands vs Tunisia — 1978 WC group stage
    'JPN_SWE': 4.5, // Japan vs Sweden — competitive Asian vs Scandinavian
    'JPN_TUN': 3.5, // Japan vs Tunisia — 2002 WC group stage rematch
    'SWE_TUN': 4.0, // Sweden vs Tunisia — 1978 WC group stage
    // ── Group G: Belgium, Egypt, IR Iran, New Zealand ────────────────
    'BEL_EGY':
        6.5, // Belgium vs Egypt — 1994 WC group stage, African vs European giant
    'BEL_IRN': 5.0, // Belgium vs Iran — 2014 WC group stage (Belgium won late)
    'BEL_NZL': 3.5, // Belgium vs New Zealand — minimal history
    'EGY_IRN': 6.0, // Egypt vs Iran — Middle East vs North Africa rivalry
    'EGY_NZL': 3.0, // Egypt vs New Zealand — rarely meet
    'IRN_NZL': 2.5, // Iran vs New Zealand — minimal history
    // ── Group H: Spain, Cabo Verde, Saudi Arabia, Uruguay ────────────
    'ESP_URU':
        7.0, // Spain vs Uruguay — 1950 WC (Uruguay beat Spain), tactical classics
    'ESP_KSA': 5.0, // Spain vs Saudi Arabia — 1994 WC group stage
    'CPV_ESP': 5.5, // Cabo Verde vs Spain — African debutant vs powerhouse
    'KSA_URU': 4.5, // Saudi Arabia vs Uruguay — 1994 WC group stage
    'CPV_KSA': 3.0, // Cabo Verde vs Saudi Arabia — Arab vs African rival
    'CPV_URU':
        3.5, // Cabo Verde vs Uruguay — debut for Cabo Verde vs 2x WC champion
    // ── Group I: France, Senegal, Iraq, Norway ────────────────────────
    'FRA_SEN':
        7.5, // France vs Senegal — colonial history + 2002 WC upset (Senegal won)
    'FRA_IRQ': 4.0, // France vs Iraq — little WC history
    'FRA_NOR': 5.5, // France vs Norway — 1998 WC group stage (France won 2-1)
    'IRQ_SEN': 3.5, // Iraq vs Senegal — rarely meet
    'NOR_SEN': 4.0, // Norway vs Senegal — 2002 WC group stage
    'IRQ_NOR': 3.0, // Iraq vs Norway — minimal history
    // ── Group J: Argentina, Algeria, Austria, Jordan ──────────────────
    'ALG_ARG':
        6.5, // Algeria vs Argentina — 1982 WC group stage + 2014 R16 (Argentina won 2-1 AET)
    'ARG_AUT': 5.5, // Argentina vs Austria — 1998 WC group stage
    'ARG_JOR':
        4.0, // Argentina vs Jordan — Jordan's debut vs defending champions
    'ALG_AUT': 4.5, // Algeria vs Austria — 1982 WC infamous "Disgrace of Gijón"
    'ALG_JOR': 4.0, // Algeria vs Jordan — Arab nations clash
    'AUT_JOR': 3.0, // Austria vs Jordan — minimal history
    // ── Group K: Portugal, Congo DR, Uzbekistan, Colombia ────────────
    'COD_POR': 4.5, // Congo DR vs Portugal — colonial/African history
    'COL_POR':
        6.0, // Colombia vs Portugal — 2014 WC group stage (Colombia won 1-0)
    'POR_UZB': 4.0, // Portugal vs Uzbekistan — Uzbekistan's WC debut
    'COD_COL': 3.5, // Congo DR vs Colombia — rarely meet
    'COD_UZB': 2.5, // Congo DR vs Uzbekistan — minimal history
    'COL_UZB': 3.0, // Colombia vs Uzbekistan — minimal history
    // ── Group L: England, Croatia, Ghana, Panama ──────────────────────
    'CRO_ENG':
        8.5, // Croatia vs England — 2018 WC semi-final (Croatia won), Euro 2020 group
    'ENG_GHA': 6.0, // England vs Ghana — 2006 WC R16 (England won 1-0)
    'ENG_PAN': 5.5, // England vs Panama — 2018 WC group stage (England won 6-1)
    'CRO_GHA': 5.0, // Croatia vs Ghana — 2006 & 2014 WC group stage meetings
    'CRO_PAN': 3.5, // Croatia vs Panama — minimal history
    'GHA_PAN': 3.0, // Ghana vs Panama — rarely meet
    // ════════════════════════════════════════════════════════════════
    // KNOCKOUT STAGE — CROSS-GROUP RIVALRIES
    // Teams from different groups who could meet from R32 onwards
    // ════════════════════════════════════════════════════════════════

    // ── All-time classics (could meet from QF onwards) ────────────────
    'ARG_BRA': 10.0, // The greatest football rivalry ever
    'ARG_ENG': 8.5, // Hand of God, Falklands, 1986 quarter-final
    'ARG_FRA': 8.5, // 2022 WC final — one of the greatest finals ever
    'ARG_URU': 9.0, // Río de la Plata derby — 213 meetings
    'BRA_FRA': 8.5, // 1998 final, 2006 QF
    'BRA_GER': 8.0, // The 7-1 — 2014 WC semifinal trauma
    'ENG_GER': 9.5, // 1966 final, 1990 semi, 1996 Euro semi
    'ESP_GER': 7.5, // 2010 WC semi-final, Euro 2008
    'ESP_POR': 9.0, // Iberian derby — 2018 WC group stage classic (3-3)
    'BRA_NED': 7.5, // 1974 & 1994 WC classics
    'GER_NED': 8.0, // "Clockwork Orange" era, bitter rivalry
    'BEL_FRA': 7.5, // 2018 WC semi-final (France won 1-0)
    'CRO_BRA': 7.0, // 2014 & 2022 WC group stage
    'MAR_POR': 7.5, // 2022 WC QF (Morocco won on penalties — historic upset)
    'MEX_USA': 8.5, // CONCACAF's fiercest rivalry, 77 meetings, co-hosts 2026
    'CAN_USA': 6.0, // Growing CONCACAF rivalry, co-hosts 2026
    'CAN_MEX': 5.5, // CONCACAF co-hosts clash
    'JPN_KOR': 7.5, // East Asian derby — intense historical rivalry
    'EGY_ALG': 6.5, // 2009 WC playoff — one of football's most violent games
    'MAR_ALG': 7.5, // North African derby — intense political history
    'MAR_SEN': 6.0, // West vs North Africa
    'IRN_KSA': 6.5, // Middle East political + football rivalry
    'IRQ_KSA': 6.0, // Arab world derby
    'COL_URU': 6.5, // South American rivals
    'ECU_COL': 5.5, // Andean neighbors
    'NOR_SWE': 5.0, // Scandinavian derby
    'BEL_NED': 6.0, // Low Countries derby
  };
}
