import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:get_it/get_it.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../controllers/services/load.dart';
import '../../controllers/services/localization.dart';
import '../../controllers/stores/user_store.dart';
import '../../controllers/stores/filter_store.dart';
import '../../controllers/stores/localization_store.dart';

import '../../models/utils/constants.dart';
import '../../models/routes/app_routes.dart';
import '../../models/database/link_model.dart';

import '../widgets/drawer_widget.dart';
import '../widgets/title_widget.dart';
import '../widgets/main/link_item_widget.dart';
import '../widgets/main/add_modal_widget.dart';
import '../widgets/main/void_link_widget.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final DatabaseReference _database = FirebaseDatabase.instance.reference();
  late StreamSubscription<Event> _dataStreamSubscription;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchInputController = TextEditingController();
  final FocusNode _searchInputFocusNode = FocusNode();
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

  final UserStore userStore = GetIt.I.get<UserStore>();
  final FilterStore filterStore = GetIt.I.get<FilterStore>();

  List<LinkModel> _links = [];
  List<LinkModel> _filteredLinks = [];
  bool _isSearching = false;

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

  void _navigateToFiltersScreen(BuildContext context) {
    Navigator.of(context).pushReplacementNamed(AppRoutes.filters);
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
          decoration: InputDecoration(
              hintText: _localization.translation.placeholder['search'],
              hintStyle: const TextStyle(
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
          icon: const Icon(Icons.filter_alt),
          onPressed: () => _navigateToFiltersScreen(context),
        ),
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
    if (mounted) {
      await load.loadFilter(context);
      if (mounted) {
        await load.loadTheme(context).then((_) => callback());
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadData(_activateListeners);
    _bannerAd.load();
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
    _bannerAd.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: SafeArea(
        child: Scaffold(
          key: const Key('Links Scaffold'),
          drawer: const DrawerWidget(key: Key('Drawer')),
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(left: 32),
            child: _isSearching
                ? null
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <FloatingActionButton>[
                      FloatingActionButton(
                        heroTag: 'Camera FAB',
                        onPressed: _navigateToScanScreen,
                        child: const Icon(Icons.camera_alt),
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
              _isSearching
                  ? const SizedBox()
                  : SizedBox(
                      width: _bannerAd.size.width.toDouble(),
                      height: _bannerAd.size.height.toDouble() + 5,
                      child: AdWidget(ad: _bannerAd),
                    ),
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
                          padding: const EdgeInsets.only(top: 5, bottom: 80),
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
                    : VoidLinkWidget(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
