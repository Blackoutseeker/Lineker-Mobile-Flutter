import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

import '../../../models/database/link_model.dart';
import '../../../models/database/history_model.dart';

class AddLinkModalWidget extends StatefulWidget {
  const AddLinkModalWidget({
    Key? key,
    required this.userUID,
    required this.filter,
  }) : super(key: key);

  final String? userUID;
  final String filter;

  @override
  _AddLinkModalWidgetState createState() => _AddLinkModalWidgetState();
}

class _AddLinkModalWidgetState extends State<AddLinkModalWidget> {
  final TextEditingController _titleInputController = TextEditingController();
  final TextEditingController _urlInputController = TextEditingController();

  Future<String> _getClipboardText() async {
    ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
    return data?.text ?? '';
  }

  Future<void> _pasteClipboardTextToUrlInput() async {
    _urlInputController.text = await _getClipboardText();
  }

  Future<void> _addNewLinkIntoDatabase() async {
    final String title = _titleInputController.text;
    final String url = _urlInputController.text;

    if (widget.userUID != null && url.isNotEmpty) {
      final DatabaseReference database = FirebaseDatabase.instance.reference();

      final DateTime currentDate = DateTime.now();
      final String datetime =
          DateFormat('dd-MM-yyyy-HH:mm:ss').format(currentDate);
      final String date = DateFormat('dd/MM/yyyy').format(currentDate);
      final String time = DateFormat('HH:mm:ss').format(currentDate);

      final LinkModel newLink = LinkModel(
        title: title.isNotEmpty ? title : 'Untitled',
        url: url,
        date: date,
        datetime: datetime,
      );

      final HistoryModel newHistoryItem = HistoryModel(
        title: title.isNotEmpty ? title : 'Untitled',
        url: url,
        date: date,
        time: time,
        datetime: datetime,
      );

      await database
          .child('users')
          .child(widget.userUID!)
          .child('filters')
          .child(widget.filter)
          .set({'filter': widget.filter});

      await database
          .child('users')
          .child(widget.userUID!)
          .child('links')
          .child(widget.filter)
          .child(datetime)
          .set({
        'title': newLink.title,
        'url': newLink.url,
        'date': newLink.date,
        'datetime': newLink.datetime,
      });

      await database
          .child('users')
          .child(widget.userUID!)
          .child('history')
          .child(datetime)
          .set({
        'title': newHistoryItem.title,
        'url': newHistoryItem.url,
        'date': newHistoryItem.date,
        'time': newHistoryItem.time,
        'datetime': newHistoryItem.datetime,
      }).then((_) => Navigator.of(context).pop());
    }
  }

  @override
  void dispose() {
    _titleInputController.dispose();
    _urlInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 120,
      child: Container(
        color: Theme.of(context).backgroundColor,
        padding: const EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      width: double.infinity,
                      height: 40,
                      child: TextField(
                        controller: _titleInputController,
                        textCapitalization: TextCapitalization.words,
                        onSubmitted: (_) => _addNewLinkIntoDatabase(),
                        style: TextStyle(
                          fontSize: 22,
                          color: Theme.of(context)
                              .appBarTheme
                              .titleTextStyle
                              ?.color,
                        ),
                        decoration: InputDecoration(
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 20),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(40),
                            borderSide: const BorderSide(
                              width: 0,
                              style: BorderStyle.none,
                            ),
                          ),
                          filled: true,
                          fillColor:
                              Theme.of(context).appBarTheme.foregroundColor,
                          hintText: 'Title',
                          hintStyle: const TextStyle(
                            color: Color(0xFF888888),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 40,
                      child: TextField(
                        autofocus: true,
                        keyboardType: TextInputType.url,
                        controller: _urlInputController,
                        onSubmitted: (_) => _addNewLinkIntoDatabase(),
                        style: TextStyle(
                          fontSize: 22,
                          color: Theme.of(context)
                              .appBarTheme
                              .titleTextStyle
                              ?.color,
                        ),
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.only(left: 20),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(40),
                            borderSide: const BorderSide(
                              width: 0,
                              style: BorderStyle.none,
                            ),
                          ),
                          filled: true,
                          fillColor:
                              Theme.of(context).appBarTheme.foregroundColor,
                          hintText: 'URL',
                          hintStyle: const TextStyle(
                            color: Color(0xFF888888),
                          ),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.paste),
                            onPressed: _pasteClipboardTextToUrlInput,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            FloatingActionButton(
              heroTag: 'Add New Link Modal FAB',
              child: const Icon(
                Icons.add,
                color: Color(0xFFFFFFFF),
              ),
              onPressed: _addNewLinkIntoDatabase,
            ),
          ],
        ),
      ),
    );
  }
}
