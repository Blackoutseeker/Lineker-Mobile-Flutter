import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get_it/get_it.dart';

import '../../controllers/stores/filter_store.dart';
import '../../controllers/stores/user_store.dart';

import '../../models/database/filter_model.dart';
import '../../models/routes/app_routes.dart';
import '../../models/utils/database_codification.dart';

import '../widgets/filters/add_modal_widget.dart';

class FiltersScreen extends StatefulWidget {
  const FiltersScreen({Key? key}) : super(key: key);

  @override
  _FiltersScreenState createState() => _FiltersScreenState();
}

class _FiltersScreenState extends State<FiltersScreen> {
  final DatabaseReference _database = FirebaseDatabase.instance.reference();
  late StreamSubscription<Event> _dataStreamSubscription;
  List<FilterModel> _filters = [];
  final UserStore _userStore = GetIt.I.get<UserStore>();
  final FilterStore _filterStore = GetIt.I.get<FilterStore>();

  void _clearFiltersState() {
    setState(() {
      _filters = [];
    });
  }

  void _setFiltersState(FilterModel filter) {
    setState(() {
      _filters.add(filter);
    });
  }

  void _navigateToMainScreen(BuildContext context) {
    Navigator.of(context).pushReplacementNamed(AppRoutes.main);
  }

  Future<void> _changeCurrentFilter(String filter) async {
    await _filterStore
        .changeFilter(filter)
        .then((_) => _navigateToMainScreen(context));
  }

  Future<void> _deleteFilter(String filter, BuildContext context) async {
    if (_userStore.user.id != null) {
      final DatabaseReference database = FirebaseDatabase.instance.reference();

      await database
          .child('users')
          .child(_userStore.user.id!)
          .child('links')
          .child(filter)
          .remove();

      await database
          .child('users')
          .child(_userStore.user.id!)
          .child('filters')
          .child(filter)
          .remove()
          .then((_) {
        Navigator.of(context).pop();
        _changeCurrentFilter('Default');
      });
    }
  }

  void _activeListeners() {
    if (_userStore.user.id != null) {
      _dataStreamSubscription = _database
          .child('users')
          .child(_userStore.user.id!)
          .child('filters')
          .onValue
          .listen((event) {
        _clearFiltersState();
        final filtersFromDatabase =
            Map<String, dynamic>.from(event.snapshot.value);
        filtersFromDatabase.forEach((_, filter) {
          setState(() {
            _setFiltersState(FilterModel.convertFromDatabase(filter));
          });
        });
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _activeListeners();
  }

  @override
  void deactivate() {
    _dataStreamSubscription.cancel();
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GestureDetector(
        onTap: FocusScope.of(context).unfocus,
        child: Scaffold(
          key: const Key('Filters Scaffold'),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          floatingActionButton: FloatingActionButton(
            heroTag: 'Add new Filter FAB',
            child: const Icon(Icons.add),
            onPressed: () => showModalBottomSheet(
              context: context,
              builder: (_) => Padding(
                padding: MediaQuery.of(context).viewInsets,
                child: AddModalWidget(
                  userUID: _userStore.user.id,
                  changeCurrentFilter: _changeCurrentFilter,
                ),
              ),
            ),
          ),
          appBar: AppBar(
            centerTitle: true,
            backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
            title: const Text('Filters'),
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Color(0xFFFFFFFF),
              ),
              onPressed: () => _navigateToMainScreen(context),
            ),
          ),
          body: StreamBuilder(
            key: const Key('Filters Stream Builder'),
            stream: _database
                .child('users')
                .child(_userStore.user.id!)
                .child('filters')
                .onValue,
            builder: (_, snapshot) => ListView.builder(
              padding: const EdgeInsets.only(bottom: 80),
              itemCount: _filters.length,
              itemBuilder: (_, index) => ListTile(
                key: UniqueKey(),
                onTap: () => _changeCurrentFilter(_filters[index].filter),
                title: Text(
                  DatabaseCodification()
                      .decodeFromDatabase(text: _filters[index].filter),
                  style: const TextStyle(
                    color: Color(0xFFFFFFFF),
                    fontSize: 20,
                    overflow: TextOverflow.ellipsis,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                selected: _filters[index].filter == _filterStore.filter,
                selectedTileColor: const Color.fromRGBO(255, 255, 255, 0.15),
                trailing: _filters[index].filter != 'Default'
                    ? IconButton(
                        icon: const Icon(
                          Icons.delete,
                          color: Color(0xFFFFFFFF),
                        ),
                        onPressed: () => showDialog(
                          barrierDismissible: true,
                          context: context,
                          builder: (dialogContext) => AlertDialog(
                            title: const Text('Are you sure?'),
                            content: const Text(
                              'All your links within this filter will be deleted!',
                            ),
                            actions: <TextButton>[
                              TextButton(
                                child: const Text('Yes'),
                                onPressed: () => _deleteFilter(
                                    _filters[index].filter, dialogContext),
                              ),
                              TextButton(
                                child: const Text('No'),
                                onPressed: () =>
                                    Navigator.of(dialogContext).pop(),
                              ),
                            ],
                          ),
                        ),
                      )
                    : null,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
