abstract class ApiConstants {
  static const String baseUrl = "https://worldcup26.ir/";
  static const String registerEp = "auth/register";
  static const String loginEp = "auth/login";
  static const String gamesEp = "get/games";
  static const String groupsEp = "get/groups";
  static const String teamsEp = "get/teams";
  static const String stadiumEp = "get/stadium";

  // In production you'd read this from secure storage
  static const String token =
      "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjZhMmQzYmUwNWE5YjM0NGQyYmY2YWIxNCIsImlhdCI6MTc4MTM0OTM0NCwiZXhwIjoxNzg4NjA2OTQ0fQ.q6vrNX_GDyNCnQxZBoKYpQ5ea_bLFn4cKI3aTe5ttHQ";
}
