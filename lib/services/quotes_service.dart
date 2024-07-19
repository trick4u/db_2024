import 'dart:convert';
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

  static Future<List<String>> getDisplayedQuotes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(QUOTES_KEY) ?? [];
  }

  static Future<void> saveDisplayedQuote(String quote) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> displayedQuotes = prefs.getStringList(QUOTES_KEY) ?? [];
    displayedQuotes.add(quote);
    await prefs.setStringList(QUOTES_KEY, displayedQuotes);
  }
}