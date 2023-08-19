import 'dart:convert';

import 'package:ebook_application/screen/home/book_list.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

import 'package:ebook_application/apis/api.dart';

class CustomSearchDelegate extends SearchDelegate {
  SearchFields searchFieldsValue = SearchFields.intitle;
  List<String>? results;

  Future<void> getResults() async {
    late final String fieldGetData;

    if (searchFieldsValue == SearchFields.intitle) {
      fieldGetData = 'title';
    } else {
      fieldGetData = 'authors';
    }

    final url = Uri.parse(
        'https://www.googleapis.com/books/v1/volumes?fields=items/volumeInfo/$fieldGetData&q=${searchFieldsValue.name}:$query&maxResults=10');

    final data = await http.get(url);
    final response = data.body;

    if (searchFieldsValue == SearchFields.intitle) {
      results = List<String>.from(json
          .decode(response)['items']
          .map((item) => item['volumeInfo'][fieldGetData]));
    } else {
      results = List<String>.from(json
          .decode(response)['items']
          .map((item) => item['volumeInfo']['authors'][0]));
    }
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: const Icon(Icons.clear),
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, null);
      },
      icon: const Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return IconButton(
      onPressed: () {},
      icon: const Icon(Icons.clear),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return FutureBuilder(
      future: getResults(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (results != null) {
            return SingleChildScrollView(
              child: Column(
                children: results!
                    .map(
                      (result) => ListTile(
                        leading: const Icon(Icons.search),
                        title: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BookList(
                                  searchTerm: result,
                                ),
                              ),
                            );
                          },
                          child: Text(
                            result,
                            style: const TextStyle(fontSize: 18),
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.north_west),
                          onPressed: () {
                            query = result;
                          },
                        ),
                      ),
                    )
                    .toList(),
              ),
            );
          }
        }

        return const Text('');
      },
    );
  }
}
