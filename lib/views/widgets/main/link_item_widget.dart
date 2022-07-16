import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get_it/get_it.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../controllers/services/localization.dart';

import '../../../controllers/stores/localization_store.dart';

import './qr_modal_widget.dart';

class LinkItemWidget extends StatefulWidget {
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

  @override
  State<LinkItemWidget> createState() => _LinkItemWidgetState();
}

class _LinkItemWidgetState extends State<LinkItemWidget> {
  final Localization _localization =
      GetIt.I.get<LocalizationStore>().localization;

  void _showQrModalWidget(String url) {
    final bool searchInputHasNoFocus = !widget.searchInputFocusNode.hasFocus;
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

  Future<void> _launchUrl() async {
    final bool canLaunchUrl = await canLaunchUrlString(widget.url);
    if (canLaunchUrl) {
      await launchUrlString(widget.url);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_localization.translation.snackbar['launch_url']),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _copyUrlToClipboard() async {
    await Clipboard.setData(ClipboardData(text: widget.url)).then((_) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_localization.translation.snackbar['copy_url']),
          duration: const Duration(seconds: 2),
        ),
      );
    });
  }

  Future<void> _deleteLink(BuildContext dialogContex) async {
    if (widget.userUID != null) {
      final DatabaseReference database = FirebaseDatabase.instance.reference();
      await database
          .child('users')
          .child(widget.userUID!)
          .child('links')
          .child(widget.currentFilter)
          .child(widget.datetime)
          .remove()
          .then((_) => Navigator.of(dialogContex).pop());
    }
  }

  Future<void> _showDeleteConfirmationDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContex) => AlertDialog(
        title: Text(
          _localization.translation.dialog['title'],
        ),
        actions: <TextButton>[
          TextButton(
            child: Text(_localization.translation.dialog['buttons']['yes']),
            onPressed: () => _deleteLink(dialogContex),
          ),
          TextButton(
            child: Text(_localization.translation.dialog['buttons']['no']),
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
                onTap: () => _showQrModalWidget(widget.url),
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
                            widget.title,
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
                                widget.url.contains('https')
                                    ? Icons.lock
                                    : Icons.warning,
                                color: const Color(0xFFFFFFFF),
                              ),
                              const SizedBox(width: 5),
                              GestureDetector(
                                onTap: () => _launchUrl(),
                                child: Text(
                                  widget.url,
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
                          onPressed: () => _copyUrlToClipboard(),
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
                          onPressed: () => _showDeleteConfirmationDialog(),
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
