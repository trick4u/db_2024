import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

class PexelsService {
  final String apiKey =
      'Rp6TdzbMOsLxt45N8sNYdVuP9J6UxkV1u8bQyUj2OIDTl0aeJ4RQfZPN';
  final String baseUrl = 'https://api.pexels.com/v1/';

Future<String> getRandomImageUrl() async {
  final response = await http.get(
    Uri.parse(
      '${baseUrl}search?query=nature+landscape&orientation=portrait&per_page=1&page=${_getRandomPage()}&size=large'),
    headers: {'Authorization': apiKey},
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    if (data['photos'].isEmpty) {
      throw Exception('No vertical images found');
    }
    return data['photos'][0]['src']['large2x']; // Use large2x for better quality without excessive file size
  } else {
    throw Exception('Failed to load image. Status code: ${response.statusCode}');
  }
}



int _getRandomPage() {
  return 1 + Random().nextInt(100); // Pexels typically has 80 pages max, but this gives some buffer
}
}
