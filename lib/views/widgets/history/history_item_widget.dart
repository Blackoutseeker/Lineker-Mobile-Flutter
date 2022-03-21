import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../models/database/history_model.dart';

class HistoryItemWidget extends StatelessWidget {
  const HistoryItemWidget({
    required UniqueKey key,
    required this.historyItem,
    required this.deleteHistoryItem,
  }) : super(key: key);

  final HistoryModel historyItem;
  final Function deleteHistoryItem;

  Future<void> _launchUrl(BuildContext context) async {
    final bool canLaunchUrl = await canLaunch(historyItem.url);
    if (canLaunchUrl) {
      await launch(historyItem.url);
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

  String formatDate() {
    final List<String> formattedDateString =
        historyItem.date.split(RegExp(r'/'));
    final List<String> formattedTimeString =
        historyItem.time.split(RegExp(r':'));

    final String day = formattedDateString[0];
    final String month = formattedDateString[1];
    final String year = formattedDateString[2];

    final String hour = formattedTimeString[0];
    final String minute = formattedTimeString[1];

    final String formattedDate = '$day/$month/$year - $hour:$minute';
    return formattedDate;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Container(
          width: double.infinity,
          height: 80,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            children: <Widget>[
              Expanded(
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Text(
                          historyItem.title,
                          style: const TextStyle(
                            fontSize: 20,
                            color: Color(0xFFFFFFFF),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: Text(
                        formatDate(),
                        style: const TextStyle(
                          color: Color.fromRGBO(255, 255, 255, 0.7),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: GestureDetector(
                          onTap: () async => await _launchUrl(context),
                          child: Text(
                            historyItem.url,
                            style: const TextStyle(
                              fontSize: 18,
                              color: Color(0xFFFFFFFF),
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    FittedBox(
                      fit: BoxFit.fitHeight,
                      child: IconButton(
                        onPressed: () => deleteHistoryItem(),
                        icon: const Icon(
                          Icons.delete,
                          color: Color(0xFFFFFFFF),
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
