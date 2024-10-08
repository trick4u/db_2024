import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PexelsService {
  final String apiKey =
      'Rp6TdzbMOsLxt45N8sNYdVuP9J6UxkV1u8bQyUj2OIDTl0aeJ4RQfZPN';
  final String baseUrl = 'https://api.pexels.com/v1/';
   // final String baseUrl = 'https://api.pexels.com/videos/';


Future<String> getRandomImageUrl() async {
    final prefs = await SharedPreferences.getInstance();
    final usedImages = prefs.getStringList('used_background_images') ?? [];

    String imageUrl;
    int attempts = 0;
    const maxAttempts = 5;

    do {
      final response = await http.get(
        Uri.parse(
          '${baseUrl}search?query=nature+landscape&orientation=landscape&per_page=1&page=${_getRandomPage()}&size=large'),
        headers: {'Authorization': apiKey},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['photos'].isEmpty) {
          throw Exception('No images found');
        }
        imageUrl = data['photos'][0]['src']['large2x'];
        attempts++;
      } else {
        throw Exception('Failed to load image. Status code: ${response.statusCode}');
      }
    } while (usedImages.contains(imageUrl) && attempts < maxAttempts);

    if (!usedImages.contains(imageUrl)) {
      usedImages.add(imageUrl);
      if (usedImages.length > 50) {  // Keep track of last 50 images
        usedImages.removeAt(0);
      }
      await prefs.setStringList('used_background_images', usedImages);
    }

    return imageUrl;
  }

  Future<String> getRandomImageUrlAbs() async {
    final prefs = await SharedPreferences.getInstance();
    final usedImages = prefs.getStringList('used_background_images') ?? [];

    String imageUrl;
    int attempts = 0;
    const maxAttempts = 5;

    do {
      final response = await http.get(
        Uri.parse(
          '${baseUrl}search?query=abstract+landscape&orientation=landscape+illustrations&per_page=1&page=${_getRandomPage()}&size=large'),
        headers: {'Authorization': apiKey},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['photos'].isEmpty) {
          throw Exception('No images found');
        }
        imageUrl = data['photos'][0]['src']['large2x'];
        attempts++;
      } else {
        throw Exception('Failed to load image. Status code: ${response.statusCode}');
      }
    } while (usedImages.contains(imageUrl) && attempts < maxAttempts);

    if (!usedImages.contains(imageUrl)) {
      usedImages.add(imageUrl);
      if (usedImages.length > 50) {  // Keep track of last 50 images
        usedImages.removeAt(0);
      }
      await prefs.setStringList('used_background_images', usedImages);
    }

    return imageUrl;
  }


  // Future<String> getRandomVideoUrl() async {
  //   try {
  //     final response = await http.get(
  //       Uri.parse(
  //           '${baseUrl}search?query=nature+landscape&orientation=landscape&per_page=1&page=${_getRandomPage()}'),
  //       headers: {'Authorization': apiKey},
  //     );

  //     if (response.statusCode == 200) {
  //       final data = json.decode(response.body);
  //       if (data['videos'].isEmpty) {
  //         print('No vertical videos found');
  //         return '';
  //       }
        
  //       final videoFiles = data['videos'][0]['video_files'];
  //       final hdVideo = videoFiles.firstWhere(
  //         (file) => file['quality'] == 'hd' && file['width'] < file['height'],
  //         orElse: () => videoFiles.firstWhere(
  //           (file) => file['quality'] == 'sd' && file['width'] < file['height'],
  //           orElse: () => null,
  //         ),
  //       );

  //       if (hdVideo == null) {
  //         print('No suitable vertical video found');
  //         return '';
  //       }

  //       return hdVideo['link'] ?? '';
  //     } else {
  //       print('Failed to load video. Status code: ${response.statusCode}');
  //       return '';
  //     }
  //   } catch (e) {
  //     print('Error fetching video: $e');
  //     return '';
  //   }
  // }

  int _getRandomPage() {
    return 1 + Random().nextInt(10);
  }
  
}