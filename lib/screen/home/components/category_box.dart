import 'package:flutter/material.dart';

import 'package:ebook_application/size_config.dart';
import 'package:ebook_application/screen/home/book_list.dart';

class CategoryBox extends StatelessWidget {
  const CategoryBox({super.key, required this.category});

  final String category;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BookList(
              searchTerm: category,
            ),
          ),
        );
      },
      child: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(
          getProportionateScreenWidth(2),
        ),
        decoration: BoxDecoration(
          border: Border.all(
            color: const Color.fromARGB(255, 40, 170, 227),
          ),
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(16),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(category),
        ),
      ),
    );
  }
}
