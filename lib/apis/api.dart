import 'dart:convert';

import 'package:http/http.dart' as http;

class GoogleBooksApi {
  static String baseUrl = 'https://www.googleapis.com';
  static String volumePath = '$baseUrl/books/v1/volumes';

  static Future<List<Map<String, dynamic>>> getBook(String url) async {
    final Uri uri = Uri.parse(url);

    final data = await http.get(uri);
    final response = data.body;

    final List<Map<String, dynamic>> results = List<Map<String, dynamic>>.from(
        json.decode(response)['items'].map((item) => item));

    return results;
  }

  static Future<List<Map<String, dynamic>>> getBooksByFields(
    String query, {
    String? searchTerm,
    int startIndex = 0,
    int maxResults = 10,
    SearchFields? searchField,
    bool isNewest = false,
  }) async {
    String url =
        '$volumePath?fields=items(id,volumeInfo(title,authors,description,categories,imageLinks/thumbnail))&q=${query.trim()}';
    if (searchField != null) {
      url += '+${searchField.name}:${searchTerm!.trim()}';
    }

    url += '&startIndex=$startIndex&maxResults=$maxResults';
    if (isNewest) {
      url += '&orderBy=newest';
    }

    final List<Map<String, dynamic>> results = await getBook(url);

    return results;
  }

  static Future<List<Map<String, dynamic>>> getBookById(String id) async {
    String url =
        '$volumePath/$id?fields=volumeInfo(title,authors,description,categories,imageLinks/thumbnail)';

    final List<Map<String, dynamic>> results = await getBook(url);

    return results;
  }
}

enum SearchFields { intitle, inauthor, subject }
