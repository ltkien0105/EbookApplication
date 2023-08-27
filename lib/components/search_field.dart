import 'package:ebook_application/constants.dart';
import 'package:flutter/material.dart';

import 'package:ebook_application/screen/home/components/custom_search_delegate.dart';

class SearchField extends StatelessWidget {
  const SearchField(this.imgUrl, {super.key});

  final String imgUrl;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        child: TextField(
          readOnly: true,
          showCursor: false,
          textAlignVertical: TextAlignVertical.center,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade300,
            hintText: 'Search books',
            contentPadding: const EdgeInsets.only(top: 4),
            prefixIcon: const Icon(Icons.search),
            prefixIconColor: Colors.grey,
            border: const OutlineInputBorder(
              borderSide: BorderSide.none,
            ),
            suffixIcon: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.network(
                  imgUrl,
                  fit: BoxFit.cover,
                  height: 5,
                  width: 5,
                ),
              ),
            ),
          ),
          onTap: () {
            print(auth.currentUser);
            showSearch(
              context: context,
              delegate: CustomSearchDelegate(),
            );
          },
        ),
      ),
    );
  }
}
