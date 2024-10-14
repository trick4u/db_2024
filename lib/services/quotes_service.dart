import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class QuoteService {
  static const String QUOTES_KEY = 'displayed_quotes';

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
    List<String> displayedQuotes = await getDisplayedQuotes();

    // Filter out displayed quotes
    List<String> newQuotes = allQuotes.where((quote) => !displayedQuotes.contains(quote)).toList();

    if (newQuotes.isEmpty) {
      // If all quotes have been displayed, reset and use all quotes again
      newQuotes = allQuotes;
      await clearDisplayedQuotes();
    }

    // Get a random quote from the new quotes
    Random random = Random();
    String randomQuote = newQuotes[random.nextInt(newQuotes.length)];

    // Save the displayed quote
    await saveDisplayedQuote(randomQuote);

    return randomQuote;
  }

  static Future<List<String>> getDisplayedQuotes() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(QUOTES_KEY) ?? [];
  }

  static Future<void> saveDisplayedQuote(String quote) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> displayedQuotes = await getDisplayedQuotes();
    displayedQuotes.add(quote);
    await prefs.setStringList(QUOTES_KEY, displayedQuotes);
  }

  static Future<void> clearDisplayedQuotes() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(QUOTES_KEY);
  }
}