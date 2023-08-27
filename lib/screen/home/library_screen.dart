import 'package:flutter/material.dart';

import 'package:ebook_application/screen/home/components/summary_info_book.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TabBarView(
          children: [
            ListView.builder(
              itemCount: 6,
              itemBuilder: (context, index) => const SummaryInfoBook(
                title: 'dsds',
                authors: ['dsds', 'dsdsd'],
                description: 'dsdsd',
                imgUrl:
                    'http://books.google.com/books/content?id=ZoECAAAAYAAJ&printsec=frontcover&img=1&zoom=1&edge=curl&source=gbs_api',
              ),
            ),
            ListView.builder(
              itemCount: 3,
              itemBuilder: (context, index) => InkWell(
                onTap: () {},
                child: Column(
                  children: [
                    ListTile(
                      leading: Image.network(
                        'http://books.google.com/books/content?id=ZoECAAAAYAAJ&printsec=frontcover&img=1&zoom=1&edge=curl&source=gbs_api',
                      ),
                      title: const Text(
                        'My Shelf',
                        style: TextStyle(fontSize: 18),
                      ),
                      subtitle: const Text(
                        '4 books',
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_outlined,
                        color: Colors.lightBlueAccent,
                      ),
                    ),
                    const Divider(
                      height: 3,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
