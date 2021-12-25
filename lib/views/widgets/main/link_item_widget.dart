import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:url_launcher/url_launcher.dart';

import './qr_modal_widget.dart';

class LinkItemWidget extends StatelessWidget {
  const LinkItemWidget({
    required UniqueKey key,
    required this.title,
    required this.url,
    required this.userUID,
    required this.currentFilter,
    required this.datetime,
    required this.searchInputFocusNode,
  }) : super(key: key);

  final String title;
  final String url;
  final String? userUID;
  final String currentFilter;
  final String datetime;
  final FocusNode searchInputFocusNode;

  void _showQrModalWidget(BuildContext context, String url) {
    final bool searchInputHasNoFocus = !searchInputFocusNode.hasFocus;
    if (searchInputHasNoFocus) {
      showModalBottomSheet(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(8),
            topRight: Radius.circular(8),
          ),
        ),
        isScrollControlled: true,
        context: context,
        builder: (_) => QrModalWidget(url: url),
      );
    }
  }

  Future<void> _launchUrl(BuildContext context) async {
    final bool canLaunchUrl = await canLaunch(url);
    if (canLaunchUrl) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Can\'t open this URL!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _copyUrlToClipboard(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: url)).then((_) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('URL copied to the clipboard!'),
          duration: Duration(seconds: 2),
        ),
      );
    });
  }

  Future<void> _deleteLink(BuildContext context) async {
    if (userUID != null) {
      final DatabaseReference database = FirebaseDatabase.instance.reference();
      await database
          .child('users')
          .child(userUID!)
          .child('links')
          .child(currentFilter)
          .child(datetime)
          .remove()
          .then((_) => Navigator.of(context).pop());
    }
  }

  Future<void> _showDeleteConfirmationDialog(BuildContext context) async {
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContex) => AlertDialog(
        title: const Text('Are you sure?'),
        actions: <TextButton>[
          TextButton(
            child: const Text('Yes'),
            onPressed: () => _deleteLink(dialogContex),
          ),
          TextButton(
            child: const Text('No'),
            onPressed: () => Navigator.of(dialogContex).pop(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(vertical: 6),
        child: Container(
          width: double.infinity,
          height: 70,
          padding: const EdgeInsets.all(5),
          child: Row(
            children: <Widget>[
              GestureDetector(
                onTap: () => _showQrModalWidget(context, url),
                child: const Icon(
                  Icons.qr_code_2,
                  color: Color(0xFFFFFFFF),
                  size: 60,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 20,
                              color: Color(0xFFFFFFFF),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: <Widget>[
                              Icon(
                                url.contains('https')
                                    ? Icons.lock
                                    : Icons.warning,
                                color: const Color(0xFFFFFFFF),
                              ),
                              const SizedBox(width: 5),
                              GestureDetector(
                                onTap: () => _launchUrl(context),
                                child: Text(
                                  url,
                                  style: const TextStyle(
                                    color: Color(0xFFFFFFFF),
                                    fontSize: 18,
                                    fontWeight: FontWeight.normal,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: 110,
                height: double.infinity,
                child: Row(
                  children: <Expanded>[
                    Expanded(
                      child: SizedBox(
                        height: double.infinity,
                        child: TextButton(
                          child: const Icon(
                            Icons.copy,
                            color: Color(0xFFFFFFFF),
                            size: 25,
                          ),
                          onPressed: () => _copyUrlToClipboard(context),
                        ),
                      ),
                    ),
                    Expanded(
                      child: SizedBox(
                        height: double.infinity,
                        child: TextButton(
                          child: const Icon(
                            Icons.delete,
                            color: Color(0xFFFFFFFF),
                            size: 25,
                          ),
                          onPressed: () =>
                              _showDeleteConfirmationDialog(context),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
