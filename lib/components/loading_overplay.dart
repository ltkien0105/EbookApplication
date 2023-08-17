import 'package:flutter/material.dart';

class LoadingOverplay extends StatefulWidget {
  const LoadingOverplay({super.key});

  @override
  State<LoadingOverplay> createState() => _LoadingOverplayState();
}

class _LoadingOverplayState extends State<LoadingOverplay> {
  @override
  Widget build(BuildContext context) {
    return const Stack(
      children: [
        Opacity(
          opacity: 0.2,
          child: ModalBarrier(
            dismissible: false,
            color: Colors.black,
          ),
        ),
        Center(
          child: SizedBox(
            width: 50,
            height: 50,
            child: CircularProgressIndicator(
              strokeWidth: 6,
            ),
          ),
        ),
      ],
    );
  }
}
