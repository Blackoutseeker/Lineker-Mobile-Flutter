import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../controllers/services/localization.dart';
import '../../../controllers/stores/localization_store.dart';

import '../../../models/database/history_model.dart';

class HistoryItemWidget extends StatefulWidget {
  const HistoryItemWidget({
    required UniqueKey key,
    required this.historyItem,
    required this.deleteHistoryItem,
  }) : super(key: key);

  final HistoryModel historyItem;
  final Function deleteHistoryItem;

  @override
  State<HistoryItemWidget> createState() => _HistoryItemWidgetState();
}

class _HistoryItemWidgetState extends State<HistoryItemWidget> {
  final Localization _localization =
      GetIt.I.get<LocalizationStore>().localization;

  Future<void> _launchUrl(BuildContext context) async {
    final bool canLaunchUrl = await canLaunchUrlString(widget.historyItem.url);
    if (canLaunchUrl) {
      await launchUrlString(widget.historyItem.url);
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

  String formatDate() {
    final List<String> formattedDateString =
        widget.historyItem.date.split(RegExp(r'/'));
    final List<String> formattedTimeString =
        widget.historyItem.time.split(RegExp(r':'));

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
                          widget.historyItem.title,
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
                            widget.historyItem.url,
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
                        onPressed: () => widget.deleteHistoryItem(),
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
