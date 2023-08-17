import 'package:flutter/material.dart';

import 'package:ebook_application/size_config.dart';

class Header extends StatelessWidget {
  const Header({
    super.key,
    required this.firstText,
    required this.secondText,
  });

  final String firstText;
  final String secondText;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: double.infinity,
          child: Text(
            firstText,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: getProportionateScreenWidth(25),
            ),
            textAlign: TextAlign.start,
          ),
        ),
        SizedBox(
          width: double.infinity,
          child: Text(
            secondText,
            style: TextStyle(
              fontSize: getProportionateScreenWidth(15),
            ),
            textAlign: TextAlign.start,
          ),
        ),
      ],
    );
  }
}
