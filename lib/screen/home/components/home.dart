import 'dart:io';

import 'package:ebook_application/apis/api.dart';
import 'package:ebook_application/models/book.dart';
import 'package:ebook_application/providers/books_provider.dart';
import 'package:ebook_application/screen/home/book_details.dart';
import 'package:flutter/material.dart';

import 'package:ebook_application/size_config.dart';
import 'package:ebook_application/screen/home/category_list.dart';
import 'package:ebook_application/screen/home/components/list_horizontal.dart';
import 'package:ebook_application/screen/home/components/summary_info_book.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Home extends ConsumerStatefulWidget {
  const Home({super.key});

  @override
  ConsumerState<Home> createState() => _HomeState();
}

class _HomeState extends ConsumerState<Home>
    with AutomaticKeepAliveClientMixin<Home> {
  late final Future myFuture;

  @override
  bool get wantKeepAlive => true;

  Future<void> getDataToHomePage({
    required int popularAmount,
    required int recentAmount,
  }) async {
    BooksNotifier booksNotifier = ref.read(booksProvider.notifier);

    List<Map<String, dynamic>> listPopularBooks =
        await GoogleBooksApi.getBooksByFields(
      "''",
      maxResults: popularAmount,
    );

    List<Map<String, dynamic>> listRecentBooks =
        await GoogleBooksApi.getBooksByFields(
      "",
      searchTerm: 'fiction',
      searchField: SearchFields.subject,
      maxResults: recentAmount,
      isNewest: true,
    );

    booksNotifier.addBookList(listPopularBooks, isPopular: true);
    booksNotifier.addBookList(listRecentBooks, isRecent: true);
  }

  @override
  void initState() {
    super.initState();
    myFuture = getDataToHomePage(popularAmount: 10, recentAmount: 10);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FutureBuilder(
        future: myFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.connectionState == ConnectionState.done) {
            final bookProvider = ref.watch(booksProvider);
            final popularList = bookProvider
                .where((book) =>
                    book.isPopular &&
                    book.imageUrl.contains('books.google.com'))
                .toList();
            final recentList = bookProvider
                .where((book) =>
                    book.isRecent && book.imageUrl.contains('books.google.com'))
                .toList();

            return WillPopScope(
              onWillPop: () {
                exit(0);
              },
              child: SafeArea(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Expanded(
                        flex: 2,
                        child: ListHorizontal(bookList: popularList),
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      Expanded(
                        flex: 1,
                        child: SizedBox(
                          width: double.infinity,
                          height: 300,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              SizedBox(
                                width: double.infinity,
                                child: Text(
                                  'Categories',
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                    fontSize: getProportionateScreenWidth(20),
                                  ),
                                ),
                              ),
                              // const Spacer(),
                              SizedBox(
                                height: getProportionateScreenHeight(40),
                                child: ListView.separated(
                                  separatorBuilder: (context, index) =>
                                      SizedBox(
                                    width: getProportionateScreenWidth(10),
                                  ),
                                  scrollDirection: Axis.horizontal,
                                  itemCount: 7,
                                  itemBuilder: (context, index) =>
                                      filterButton('Short Stories'),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      Expanded(
                        flex: 4,
                        child: Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              child: Text(
                                'Recently Added',
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  fontSize: getProportionateScreenWidth(20),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: getProportionateScreenHeight(16),
                            ),
                            Expanded(
                              child: ListView.separated(
                                separatorBuilder: (context, index) =>
                                    const SizedBox(
                                  height: 16,
                                ),
                                itemCount: recentList.length,
                                itemBuilder: (context, index) => InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => BookDetails(
                                          book: recentList[index],
                                        ),
                                      ),
                                    );
                                  },
                                  child: SummaryInfoBook(
                                    title: recentList[index].title,
                                    authors: recentList[index].authors,
                                    description: recentList[index].description,
                                    imgUrl: recentList[index].imageUrl,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          return const Center(
            child: CircularProgressIndicator(),
          );
        });
  }

  ElevatedButton filterButton(String type) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                const CategoryList(category: Category.education),
          ),
        );
      },
      style: const ButtonStyle(
        backgroundColor: MaterialStatePropertyAll(Colors.blueAccent),
        foregroundColor: MaterialStatePropertyAll(Colors.white),
        shape: MaterialStatePropertyAll(
          StadiumBorder(),
        ),
      ),
      child: Text(
        type,
      ),
    );
  }
}
