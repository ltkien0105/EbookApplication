import 'dart:io';

import 'package:flutter/material.dart';

import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfViewer extends StatelessWidget {
  const PdfViewer({super.key, required this.file});

  final File file;

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: SafeArea(child: SfPdfViewer.file(file)));
  }
}
