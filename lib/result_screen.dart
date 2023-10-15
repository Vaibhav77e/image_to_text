import 'package:flutter/material.dart';

class ResultScreen extends StatefulWidget {
  String scannedResultText;
  ResultScreen({super.key, required this.scannedResultText});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  late String name;
  late String phone;
  late String email;

  void _extractContactDetails(scannedResultText) {
    RegExp nameRegex = RegExp(r'name\s*:\s*(.*)', caseSensitive: false);
    RegExp phoneRegex =
        RegExp(r'phone number\s*:\s*([0-9]{10})', caseSensitive: false);
    RegExp emailRegex = RegExp(
        r'email\s*:\s*([a-zA-Z0-9._-]+@[a-zA-Z0-9._-]+\.[a-zA-Z0-9_-]+)',
        caseSensitive: false);

    name = nameRegex.firstMatch(scannedResultText)?.group(1) ?? '';
    phone = phoneRegex.firstMatch(scannedResultText)?.group(1) ?? '';
    email = emailRegex.firstMatch(scannedResultText)?.group(1) ?? '';
  }

  @override
  void initState() {
    _extractContactDetails(widget.scannedResultText);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanned Details'),
      ),
      body: Column(
        children: [
          //  Text(widget.scannedResultText),
          Divider(),
          Text(name),
          Text(phone),
          Text(email),
        ],
      ),
    );
  }
}
