import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get_it/get_it.dart';

import '../../controllers/services/load.dart';
import '../../controllers/stores/user_store.dart';
import '../../controllers/stores/filter_store.dart';

import '../../models/routes/app_routes.dart';
import '../../models/database/link_model.dart';

import '../widgets/drawer_widget.dart';
import '../widgets/title_widget.dart';
import '../widgets/main/filter_button_widget.dart';
import '../widgets/main/link_item_widget.dart';
import '../widgets/main/add_modal_widget.dart';
import '../widgets/main/void_link_widget.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final DatabaseReference _database = FirebaseDatabase.instance.reference();
  late StreamSubscription<Event> _dataStreamSubscription;
  List<LinkModel> _links = [];
  List<LinkModel> _filteredLinks = [];
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchInputController = TextEditingController();
  final FocusNode _searchInputFocusNode = FocusNode();
  bool _isSearching = false;

  final UserStore userStore = GetIt.I.get<UserStore>();
  final FilterStore filterStore = GetIt.I.get<FilterStore>();

  void _clearLinksState() {
    setState(() {
      _links = [];
      _filteredLinks = [];
    });
  }

  void _setLinksState(LinkModel link) {
    setState(() {
      _links.add(link);
      _filteredLinks.add(link);
    });
  }

  void _activateListeners() {
    if (userStore.user.id != null) {
      _dataStreamSubscription = _database
          .child('users')
          .child(userStore.user.id!)
          .child('links')
          .child(filterStore.filter)
          .onValue
          .listen((event) {
        _clearLinksState();
        final linksFromDatabase =
            Map<String, dynamic>.from(event.snapshot.value);
        linksFromDatabase.forEach((_, link) {
          _setLinksState(LinkModel.convertFromDatabase(link));
        });
      });
    }
  }

  void switchAppBar() {
    if (_links.isNotEmpty) {
      _scrollController.jumpTo(0);
      setState(() {
        _isSearching = !_isSearching;
      });
    }
  }

  void _clearSearchBarInput() {
    _searchInputController.clear();
    setState(() {
      _filteredLinks = _links;
    });
  }

  void _dismissSearchBar() {
    switchAppBar();
    _clearSearchBarInput();
    _searchInputFocusNode.unfocus();
  }

  void _filterLinksBySearchValue(String text) {
    String searchValue = text.toLowerCase();

    setState(() {
      _filteredLinks = _links.where((link) {
        String linkTitle = link.title.toLowerCase();
        String linkUrl = link.url.toLowerCase();
        String linkDate = link.date.toLowerCase();

        return linkTitle.contains(searchValue) ||
            linkUrl.contains(searchValue) ||
            linkDate.contains(searchValue);
      }).toList();
    });
  }

  AppBar _renderCurrentAppBarWidget() {
    if (_isSearching) {
      return AppBar(
        backgroundColor: Theme.of(context).appBarTheme.foregroundColor,
        centerTitle: true,
        actions: <IconButton>[
          IconButton(
            icon: const Icon(
              Icons.clear,
              color: Color(0xFF9E9E9E),
            ),
            onPressed: _clearSearchBarInput,
          ),
        ],
        title: TextField(
          controller: _searchInputController,
          focusNode: _searchInputFocusNode,
          onChanged: _filterLinksBySearchValue,
          autofocus: true,
          style: TextStyle(
            color: Theme.of(context).appBarTheme.titleTextStyle?.color,
            fontSize: 18,
          ),
          decoration: const InputDecoration(
              hintText: 'Title, URL, date...',
              hintStyle: TextStyle(
                color: Color(0xFF9E9E9E),
              ),
              border: InputBorder.none),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Color(0xFF9E9E9E),
          ),
          onPressed: _dismissSearchBar,
        ),
      );
    }
    return AppBar(
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      centerTitle: true,
      actions: <IconButton>[
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: switchAppBar,
        ),
      ],
      title: const TitleWidget(textSize: 24),
    );
  }

  void _navigateToScanScreen() {
    Navigator.of(context).pushNamed(AppRoutes.scan);
  }

  Future<void> _loadData(VoidCallback callback) async {
    final Load load = Load.instance;
    await load.loadUser(context);
    await load.loadFilter(context);
    await load.loadTheme(context).then((_) => callback());
  }

  @override
  void initState() {
    super.initState();
    _loadData(_activateListeners);
  }

  @override
  void deactivate() {
    _dataStreamSubscription.cancel();
    super.deactivate();
  }

  @override
  void dispose() {
    _searchInputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: SafeArea(
        child: Scaffold(
          key: const Key('Links Scaffold'),
          drawer: DrawerWidget(key: const Key('Drawer')),
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(
              left: 32,
            ),
            child: _isSearching
                ? null
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <FloatingActionButton>[
                      FloatingActionButton(
                        heroTag: 'Camera FAB',
                        child: const Icon(Icons.camera_alt),
                        onPressed: _navigateToScanScreen,
                      ),
                      FloatingActionButton(
                        heroTag: 'Add New Link FAB',
                        child: const Icon(Icons.add),
                        onPressed: () {
                          showModalBottomSheet(
                            isScrollControlled: true,
                            context: context,
                            builder: (_) => Padding(
                              padding: MediaQuery.of(context).viewInsets,
                              child: AddLinkModalWidget(
                                key: const Key('Add Link Modal Widget'),
                                userUID: userStore.user.id,
                                filter: filterStore.filter,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
          ),
          appBar: _renderCurrentAppBarWidget(),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: Column(
            children: <Widget>[
              const FilterButtonWidget(),
              Expanded(
                child: _links.isNotEmpty
                    ? StreamBuilder(
                        key: const Key('Link Stream Builder'),
                        stream: _database
                            .child('users')
                            .child(userStore.user.id!)
                            .child('links')
                            .child(filterStore.filter)
                            .onValue,
                        builder: (_, snapshot) => ListView.builder(
                          padding: const EdgeInsets.only(bottom: 80),
                          controller: _scrollController,
                          itemCount: _filteredLinks.length,
                          itemBuilder: (_, index) => LinkItemWidget(
                            key: UniqueKey(),
                            title: _filteredLinks[index].title,
                            url: _filteredLinks[index].url,
                            userUID: userStore.user.id,
                            currentFilter: filterStore.filter,
                            datetime: _filteredLinks[index].datetime,
                            searchInputFocusNode: _searchInputFocusNode,
                          ),
                        ),
                      )
                    : const VoidLinkWidget(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
