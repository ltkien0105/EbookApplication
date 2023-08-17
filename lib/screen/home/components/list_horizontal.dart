import 'package:cached_network_image/cached_network_image.dart';
import 'package:ebook_application/models/book.dart';
import 'package:ebook_application/screen/home/book_details.dart';
import 'package:flutter/material.dart';

class ListHorizontal extends StatelessWidget {
  const ListHorizontal({
    super.key,
    required this.bookList,
  });

  final List<Book> bookList;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      separatorBuilder: (context, index) => const SizedBox(
        width: 25,
      ),
      itemCount: bookList.length,
      itemBuilder: (context, index) {
        return Card(
          elevation: 16,
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BookDetails(
                    book: bookList[index],
                  ),
                ),
              );
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: CachedNetworkImage(
                imageUrl: bookList[index].imageUrl,
                fit: BoxFit.fill,
                width: 130,
              ),
            ),
          ),
        );
      },
    );
  }
}
