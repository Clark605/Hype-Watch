import 'dart:convert';

List<String> scorersJsonNormalizer(String input) {
  try {
    // Step 1: Normalize quotes to regular double quotes
    String normalized = input
        .replaceAll('“', '"')
        .replaceAll('”', '"')
        .replaceAll('’', "'");

    // Step 2: Convert { } → [ ] so it becomes valid JSON array
    normalized = normalized.replaceAll('{', '[').replaceAll('}', ']');

    // Step 3: Decode JSON
    List<dynamic> rawList = jsonDecode(normalized);

    // Step 4: Convert to List<String> safely
    List<String> result = rawList.map((e) => e.toString()).toList();

    return result;
  } catch (e) {
    print("Error parsing string: $e");
    return [];
  }
}
