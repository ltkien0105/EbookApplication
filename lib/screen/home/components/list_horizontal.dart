import 'package:flutter/material.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:ebook_application/apis/api.dart';
import 'package:ebook_application/models/book.dart';
import 'package:ebook_application/providers/books_provider.dart';
import 'package:ebook_application/screen/home/book_details.dart';

class ListHorizontal extends ConsumerStatefulWidget {
  const ListHorizontal({
    super.key,
    required this.category,
  });

  final String category;

  @override
  ConsumerState<ListHorizontal> createState() => _ListHorizontalState();
}

class _ListHorizontalState extends ConsumerState<ListHorizontal> {
  late Future myFuture;
  List<Book> bookList = [];

  Future<void> getDataByCategory() async {
    BooksNotifier booksNotifier = ref.read(booksProvider.notifier);

    switch (widget.category) {
      case 'popular':
        final List<Map<String, dynamic>>? listPopularBooks =
            await GoogleBooksApi.getBooksByFields(
          "''",
          maxResults: 7,
        );

        if (listPopularBooks != null) {
          booksNotifier.addBookList(listPopularBooks, isPopular: true);
        }

        List<Book> books = ref.read(booksProvider);
        bookList = books.where((book) {
          if (book.imageUrl != null) {
            return book.isPopular &&
                book.imageUrl!.contains('books.google.com');
          }
          return false;
        }).toList();
        break;
      default:
        final List<Map<String, dynamic>>? listBookByCategory =
            await GoogleBooksApi.getBooksByFields(
          '',
          searchTerm: widget.category,
          searchField: SearchFields.subject,
          maxResults: 7,
        );

        if (listBookByCategory != null) {
          booksNotifier.addBookList(listBookByCategory);
        }

        List<Book> books = ref.read(booksProvider);

        bookList = books
            .where((book) => book.categories
                .join(' ')
                .toLowerCase()
                .contains(widget.category))
            .toList();
    }
  }

  @override
  void initState() {
    super.initState();

    myFuture = getDataByCategory();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: myFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
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
                      child: bookList[index].imageUrl != null
                          ? CachedNetworkImage(
                              imageUrl: bookList[index].imageUrl!,
                              fit: BoxFit.fill,
                              width: 130,
                            )
                          : Opacity(
                              opacity: 0.3,
                              child: SvgPicture.asset(
                                'assets/images/book_placeholder.svg',
                                width: 130,
                              ),
                            ),
                    ),
                  ),
                );
              },
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        });
  }
}
