import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get_it/get_it.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../controllers/services/localization.dart';
import '../../controllers/stores/user_store.dart';
import '../../controllers/stores/localization_store.dart';

import '../../models/utils/constants.dart';
import '../../models/database/history_model.dart';
import '../../models/routes/app_routes.dart';

import '../widgets/history/history_item_widget.dart';
import '../widgets/history/void_history.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final DatabaseReference _database = FirebaseDatabase.instance.reference();
  late StreamSubscription<Event> _dataStreamSubscription;
  final UserStore _userStore = GetIt.I.get<UserStore>();
  final Localization _localization =
      GetIt.I.get<LocalizationStore>().localization;

  final BannerAd _bannerAd = BannerAd(
    adUnitId: Constants.instance.bannerAdUnitId,
    size: AdSize.banner,
    request: const AdRequest(),
    listener: BannerAdListener(
        onAdFailedToLoad: (Ad ad, LoadAdError loadAdError) async {
      await ad.dispose();
    }),
  );

  List<HistoryModel> _historyItems = [];

  void _navigateToMainScreen(BuildContext context) {
    Navigator.of(context).pushReplacementNamed(AppRoutes.main);
  }

  void _clearHistoryItemsState() {
    setState(() {
      _historyItems = [];
    });
  }

  void _setHistoryItemsState(HistoryModel historyItem) {
    setState(() {
      _historyItems.add(historyItem);
    });
  }

  Future<void> _deleteAllHistory() async {
    if (_userStore.user.id != null) {
      await _database
          .child('users')
          .child(_userStore.user.id!)
          .child('history')
          .remove()
          .then((_) {
        Navigator.pop(context);
      });
    }
  }

  Future<void> _deleteHistoryItem(HistoryModel historyItem) async {
    if (_userStore.user.id != null) {
      await _database
          .child('users')
          .child(_userStore.user.id!)
          .child('history')
          .child(historyItem.datetime)
          .remove()
          .then((_) {
        Navigator.of(context).pop();
      });
    }
  }

  Future<void> _showDeleteAlertDialog(
    BuildContext context,
    Function() confirmAction,
    String? contentText,
  ) async {
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => AlertDialog(
        title: Text(_localization.translation.dialog['title']),
        content: contentText != null ? Text(contentText) : null,
        actions: <TextButton>[
          TextButton(
            onPressed: confirmAction,
            child: Text(_localization.translation.dialog['buttons']['yes']),
          ),
          TextButton(
            child: Text(_localization.translation.dialog['buttons']['no']),
            onPressed: () => Navigator.of(dialogContext).pop(),
          ),
        ],
      ),
    );
  }

  DateTime formatDate(HistoryModel historyItem) {
    final List<String> formattedDateString =
        historyItem.date.split(RegExp(r'/'));
    final List<String> formattedTimeString =
        historyItem.time.split(RegExp(r':'));

    final int day = int.parse(formattedDateString[0]);
    final int month = int.parse(formattedDateString[1]);
    final int year = int.parse(formattedDateString[2]);

    final int hour = int.parse(formattedTimeString[0]);
    final int minute = int.parse(formattedTimeString[1]);
    final int second = int.parse(formattedTimeString[2]);

    final DateTime dateTime =
        DateTime.utc(year, month, day, hour, minute, second);
    return dateTime;
  }

  void _activeListeners() {
    if (_userStore.user.id != null) {
      _dataStreamSubscription = _database
          .child('users')
          .child(_userStore.user.id!)
          .child('history')
          .onValue
          .listen((event) {
        _clearHistoryItemsState();
        final historyItemsFromDatabase =
            Map<String, dynamic>.from(event.snapshot.value);

        historyItemsFromDatabase.forEach((_, historyItem) {
          setState(() {
            _setHistoryItemsState(
                HistoryModel.convertFromDatabase(historyItem));
          });
        });

        _historyItems.sort((a, b) {
          final DateTime dateA = formatDate(a);
          final DateTime dateB = formatDate(b);
          return dateB.compareTo(dateA);
        });
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _activeListeners();
    _bannerAd.load();
  }

  @override
  void deactivate() {
    _dataStreamSubscription.cancel();
    super.deactivate();
  }

  @override
  void dispose() {
    _bannerAd.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: const Key('History Scaffold'),
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          title: Text(_localization.translation.titles['history']),
          leading: IconButton(
            onPressed: () => _navigateToMainScreen(context),
            icon: const Icon(
              Icons.arrow_back,
              color: Color(0xFFFFFFFF),
            ),
          ),
          actions: <IconButton>[
            IconButton(
              onPressed: _historyItems.isNotEmpty
                  ? () async => await _showDeleteAlertDialog(
                        context,
                        _deleteAllHistory,
                        _localization.translation.dialog['history_content'],
                      )
                  : null,
              icon: const Icon(
                Icons.delete_forever,
                color: Color(0xFFFFFFFF),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            SizedBox(
              width: _bannerAd.size.width.toDouble(),
              height: _bannerAd.size.height.toDouble() + 5,
              child: AdWidget(ad: _bannerAd),
            ),
            Expanded(
              child: _historyItems.isNotEmpty
                  ? StreamBuilder(
                      key: const Key('History Stream Builder'),
                      stream: _database
                          .child('users')
                          .child(_userStore.user.id!)
                          .child('history')
                          .onValue,
                      builder: (_, snapshot) => ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        itemCount: _historyItems.length,
                        itemBuilder: (_, index) => HistoryItemWidget(
                          key: UniqueKey(),
                          historyItem: _historyItems[index],
                          deleteHistoryItem: () async {
                            await _showDeleteAlertDialog(
                              context,
                              () async => await _deleteHistoryItem(
                                  _historyItems[index]),
                              null,
                            );
                          },
                        ),
                      ),
                    )
                  : VoidHistory(),
            ),
          ],
        ),
      ),
    );
  }
}
