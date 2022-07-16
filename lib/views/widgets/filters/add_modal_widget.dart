import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:firebase_database/firebase_database.dart';

import '../../../controllers/services/localization.dart';
import '../../../controllers/stores/localization_store.dart';

import '../../../models/utils/database_codification.dart';

class AddModalWidget extends StatefulWidget {
  const AddModalWidget({
    Key? key,
    required this.changeCurrentFilter,
    required this.userUID,
  }) : super(key: key);

  final String? userUID;
  final Function(String filter) changeCurrentFilter;

  @override
  State<AddModalWidget> createState() => _AddModalWidgetState();
}

class _AddModalWidgetState extends State<AddModalWidget> {
  final TextEditingController _filterInputController = TextEditingController();

  final Localization _localization =
      GetIt.I.get<LocalizationStore>().localization;

  Future<void> _addNewFilter() async {
    final String? userUID = widget.userUID;
    final String filter = _filterInputController.text;
    final String encodedFilter =
        DatabaseCodification().encodeToDatabase(text: filter);

    if (userUID != null && filter.isNotEmpty) {
      final DatabaseReference database = FirebaseDatabase.instance.reference();
      await database
          .child('users')
          .child(userUID)
          .child('filters')
          .child(encodedFilter)
          .set({'filter': encodedFilter}).then(
              (_) => widget.changeCurrentFilter(encodedFilter));
    }
  }

  @override
  void dispose() {
    _filterInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 75,
      child: Container(
        color: Theme.of(context).backgroundColor,
        padding: const EdgeInsets.all(10),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 10),
                child: SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: TextField(
                    controller: _filterInputController,
                    textCapitalization: TextCapitalization.words,
                    autofocus: true,
                    onSubmitted: (_) => _addNewFilter(),
                    style: TextStyle(
                      fontSize: 22,
                      color:
                          Theme.of(context).appBarTheme.titleTextStyle?.color,
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
                      fillColor: Theme.of(context).appBarTheme.foregroundColor,
                      hintText:
                          _localization.translation.placeholder['add_filter'],
                      hintStyle: const TextStyle(
                        color: Color(0xFF888888),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            FloatingActionButton(
              heroTag: 'Add New Filter Modal FAB',
              onPressed: _addNewFilter,
              child: const Icon(
                Icons.add,
                color: Color(0xFFFFFFFF),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
