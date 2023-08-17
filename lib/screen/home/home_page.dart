import 'package:flutter/material.dart';

import 'package:ebook_application/size_config.dart';
import 'package:ebook_application/screen/home/explore.dart';
import 'package:ebook_application/screen/settings/settings.dart';
import 'package:ebook_application/screen/home/components/home.dart';
import 'package:ebook_application/screen/home/add_new_book.dart';
import 'package:ebook_application/screen/home/components/custom_search_delegate.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late int _selectedPageIndex;
  late List<Widget> _pages;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();

    _selectedPageIndex = 0;
    _pages = [
      const Home(),
      const Explore(),
      const Settings(),
    ];
    _pageController = PageController(initialPage: _selectedPageIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          getTitle(_selectedPageIndex),
          style: TextStyle(
            fontSize: getProportionateScreenWidth(25),
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: (_selectedPageIndex == 0 || _selectedPageIndex == 1)
            ? [
                IconButton(
                  onPressed: () {
                    showSearch(
                      context: context,
                      delegate: CustomSearchDelegate(),
                    );
                  },
                  icon: const Icon(Icons.search),
                ),
              ]
            : null,
        automaticallyImplyLeading: false,
        centerTitle: true,
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
            label: 'Settings',
            icon: Icon(Icons.settings),
          ),
        ],
        currentIndex: _selectedPageIndex,
        onTap: (selectedPageIndex) {
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
                    builder: (context) => const AddNewBook(),
                  ),
                );
              },
              backgroundColor: Colors.blue,
              child: const Icon(Icons.add),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: _pages,
      ),
    );
  }

  String getTitle(int index) {
    switch (index) {
      case 1:
        return 'Explore';
      case 2:
        return 'Settings';
      default:
        return 'Flutter Ebook App';
    }
  }
}
