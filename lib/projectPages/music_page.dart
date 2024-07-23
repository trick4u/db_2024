import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';

import '../services/pexels_service.dart';

class QuoteController extends GetxController {
  final RxString currentQuote = ''.obs;
  final RxString currentImageUrl = ''.obs;
  final PexelsService _pexelsService = PexelsService();

  final List<String> quotes = [
    'Your first quote here',
    'Your second quote here',
    // Add more quotes
  ];

  @override
  void onInit() {
    super.onInit();
    changeQuote();
  }

  Future<void> changeQuote() async {
    final randomIndex = Random().nextInt(quotes.length);
    currentQuote.value = quotes[randomIndex];

    try {
      currentImageUrl.value = await _pexelsService.getRandomImageUrl();
    } catch (e) {
      print('Error fetching image: $e');
      currentImageUrl.value = ''; // Set a default image URL or handle the error
    }
  }
}

class QuoteWidget extends StatelessWidget {
  final QuoteController quoteController = Get.put(QuoteController());

  @override
  Widget build(BuildContext context) {
    return Obx(() => Stack(
          children: [
            if (quoteController.currentImageUrl.isNotEmpty)
              CachedNetworkImage(
                imageUrl: quoteController.currentImageUrl.value,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                placeholder: (context, url) => CircularProgressIndicator(),
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      quoteController.currentQuote.value,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: quoteController.changeQuote,
                  child: Text('Change Quote'),
                ),
              ],
            ),
          ],
        ));
  }
}
