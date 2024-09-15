import 'dart:convert';
import 'dart:math';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;


class QuoteService {
  static const String QUOTES_KEY = 'displayed_quotes';
  static final GetStorage _storage = GetStorage();

  static Future<List<String>> fetchQuotes() async {
    final response = await http.get(Uri.parse('https://zenquotes.io/api/quotes'));

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      return List<String>.from(jsonResponse.map((quote) => '${quote['q']} - ${quote['a']}'));
    } else {
      throw Exception('Failed to load quotes');
    }
  }

  static Future<String> getRandomQuote() async {
    List<String> allQuotes = await fetchQuotes();
    List<String> displayedQuotes = getDisplayedQuotes();

    // Filter out displayed quotes
    List<String> newQuotes = allQuotes.where((quote) => !displayedQuotes.contains(quote)).toList();

    if (newQuotes.isEmpty) {
      // If all quotes have been displayed, reset and use all quotes again
      newQuotes = allQuotes;
      _storage.remove(QUOTES_KEY);
    }

    // Get a random quote from the new quotes
    Random random = Random();
    String randomQuote = newQuotes[random.nextInt(newQuotes.length)];

    // Save the displayed quote
    await saveDisplayedQuote(randomQuote);

    return randomQuote;
  }

  static List<String> getDisplayedQuotes() {
    return _storage.read<List<String>>(QUOTES_KEY) ?? [];
  }

  static Future<void> saveDisplayedQuote(String quote) async {
    List<String> displayedQuotes = getDisplayedQuotes();
    displayedQuotes.add(quote);
    await _storage.write(QUOTES_KEY, displayedQuotes);
  }
}