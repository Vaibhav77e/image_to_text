import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class ResultScreen extends StatefulWidget {
  String scannedResultText;
  ResultScreen({super.key, required this.scannedResultText});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  late String _name;
  late String _phone = '';
  late String _email = '';
  bool requestContact = false;

  late final Future<void> _requestContactPermissionDetail;

  @override
  void initState() {
    _name = extractName(widget.scannedResultText);
    _phone = extractPhoneNumber(widget.scannedResultText);
    _email = extractEmail(widget.scannedResultText);
    _requestContactPermissionDetail = requestContactPermission();
    super.initState();
  }

  String extractName(String text) {
    // Implement logic to extract name
    // Example logic, assuming name is the first line of text
    List<String> lines = text.split('\n');
    if (lines.isNotEmpty) {
      return lines[0];
    }
    return '';
  }

  String extractPhoneNumber(String text) {
    RegExp regex = RegExp(r'(\+?0?\d{10})');
    Iterable<RegExpMatch> matches = regex.allMatches(text);
    for (RegExpMatch match in matches) {
      return match.group(0) ?? '';
    }
    return '';
  }

  String extractEmail(String text) {
    RegExp regex = RegExp(r'[\w-\.]+@([\w-]+\.)+[\w-]{2,4}');
    Iterable<RegExpMatch> matches = regex.allMatches(text);
    for (RegExpMatch match in matches) {
      return match.group(0) ?? '';
    }
    return '';
  }

  Future<void> requestContactPermission() async {
    final status = await Permission.contacts.request();
    requestContact = status == await Permission.contacts.status;
  }

// to save contacts
  Future<void> saveContact(
      {required String name,
      required String phone,
      required String email}) async {
    try {
      PermissionStatus permissionStatus = await Permission.contacts.status;
      if (permissionStatus != PermissionStatus.granted) {
        await Permission.contacts.request();
        PermissionStatus permissionStatus = await Permission.contacts.status;
        return;
      }
      if (permissionStatus == PermissionStatus.granted) {
        Contact contact = Contact();
        contact.givenName = name;
        contact.phones = [Item(label: 'mobile', value: phone)];
        contact.emails = [Item(label: 'work', value: email)];
        await ContactsService.addContact(contact);
        print(contact.givenName);
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Permission deined')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanned Details'),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.scannedResultText),
            Divider(),
            Text('Name: $_name'),
            Text('Phone: $_phone'),
            Text('Email: $_email'),
            SizedBox(
              height: 50,
            ),
            FutureBuilder(
                future: _requestContactPermissionDetail,
                builder: (context, snapshot) {
                  return TextButton(
                      onPressed: () => saveContact(
                          name: _name, phone: _phone, email: _email),
                      child: const Text('Save Contact to Phone'));
                }),
          ],
        ),
      ),
    );
  }
}
