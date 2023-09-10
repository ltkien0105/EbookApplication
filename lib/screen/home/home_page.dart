import 'package:ebook_application/constants.dart';
import 'package:flutter/material.dart';

import 'package:ebook_application/screen/home/explore.dart';
import 'package:ebook_application/components/search_field.dart';
import 'package:ebook_application/screen/home/chat_screen.dart';
import 'package:ebook_application/screen/settings/settings.dart';
import 'package:ebook_application/screen/home/library_screen.dart';
import 'package:ebook_application/screen/home/components/home.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late int _selectedPageIndex;
  late List<Widget> _pages;
  late PageController _pageController;

  String? imgUrl =
      'http://books.google.com/books/content?id=Pv1eUCKdP-QC&printsec=frontcover&img=1&zoom=1&edge=curl&source=gbs_api';

  @override
  void initState() {
    super.initState();

    if (auth.currentUser != null) {
      if (auth.currentUser!.photoURL != null) {
        imgUrl = auth.currentUser!.photoURL;
      }
    }

    _selectedPageIndex = 0;
    _pages = [
      const Home(),
      const Explore(),
      const LibraryScreen(),
      const Settings(),
    ];
    _pageController = PageController(initialPage: _selectedPageIndex);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: _selectedPageIndex == 3
              ? const Text(
                  'Settings',
                  style: TextStyle(
                    fontSize: 25,
                  ),
                )
              : null,
          actions: _selectedPageIndex != 3
              ? [
                  SearchField(imgUrl!),
                ]
              : null,
          automaticallyImplyLeading: false,
          centerTitle: true,
          bottom: _selectedPageIndex == 2
              ? const TabBar(
                  labelColor: Colors.blue,
                  unselectedLabelColor: Colors.grey,
                  indicator: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.blue,
                        width: 3,
                      ),
                    ),
                  ),
                  tabs: [
                    Tab(
                      child: Text(
                        'All books',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    Tab(
                      child: Text(
                        'Shelves',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ],
                )
              : null,
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              label: 'Home',
              icon: Icon(Icons.home),
            ),
            BottomNavigationBarItem(
              label: 'Explore',
              icon: Icon(Icons.explore),
            ),
            BottomNavigationBarItem(
              label: 'Library',
              icon: Icon(Icons.format_list_bulleted),
            ),
            BottomNavigationBarItem(
              label: 'Settings',
              icon: Icon(Icons.settings),
            ),
          ],
          currentIndex: _selectedPageIndex,
          onTap: (selectedPageIndex) {
            // if (selectedPageIndex == 2) {
            //   Navigator.push(
            //     context,
            //     MaterialPageRoute(
            //       builder: (context) => const LibraryScreen(),
            //     ),
            //   );
            // }
            setState(() {
              _selectedPageIndex = selectedPageIndex;
              _pageController.jumpToPage(selectedPageIndex);
            });
          },
        ),
        floatingActionButton: _selectedPageIndex == 0
            ? FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ChatScreen(),
                    ),
                  );
                },
                backgroundColor: Colors.blue,
                child: Image.asset('assets/icons/chatbot.png'),
              )
            : _selectedPageIndex == 2
                ? FloatingActionButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) {
                          final TextEditingController shelfNameController =
                              TextEditingController();

                          return AlertDialog(
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                TextField(
                                  controller: shelfNameController,
                                  decoration: const InputDecoration(
                                    hintText: 'Shelf name',
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    firestore
                                        .doc(
                                            'libraries/${auth.currentUser!.uid}')
                                        .collection('shelves')
                                        .doc(shelfNameController.text)
                                        .set({
                                      "booksID": [],
                                    }).then((_) {
                                      Navigator.pop(context);
                                    });
                                  },
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                    backgroundColor: Colors.blue,
                    child: Image.asset('assets/icons/chatbot.png'),
                  )
                : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        body: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: _pages,
        ),
      ),
    );
  }
}
