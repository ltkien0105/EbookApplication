import 'package:flutter/material.dart';

import 'package:ebook_application/size_config.dart';

class Favorite extends StatelessWidget {
  const Favorite({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Favorites',
          style: TextStyle(
            fontSize: getProportionateScreenWidth(25),
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(
            getProportionateScreenWidth(16),
          ),
          child: GridView.builder(
            shrinkWrap: true,
            itemCount: 50,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 16,
              childAspectRatio: 1 / 1.8,
            ),
            itemBuilder: (context, index) => Column(
              children: [
                Image.network(
                  'https://covers.feedbooks.net/book/3166.jpg?size=large&t=1688155167',
                ),
                const SizedBox(
                  height: 4,
                ),
                Text(
                  'Title',
                  style: TextStyle(
                    fontSize: getProportionateScreenWidth(14),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
