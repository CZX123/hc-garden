import '../../library.dart';

class EntityListPage extends StatelessWidget {
  final List<Entity> entityList;
  final ScrollController scrollController;
  const EntityListPage({
    Key key,
    @required this.entityList,
    @required this.scrollController,
  }) : super(key: key);

  static bool _isValid(Entity entity, String searchTerm) {
    return !entity.name.split(' ').every((name) {
          return !name.toLowerCase().startsWith(searchTerm.toLowerCase());
        }) ||
        !entity.sciName.split(' ').every((name) {
          return !name.toLowerCase().startsWith(searchTerm.toLowerCase());
        });
  }

  @override
  Widget build(BuildContext context) {
    final floraIcons = [
      Icons.nature_people,
      Icons.filter_vintage,
      Icons.spa,
    ];
    final faunaIcons = [
      Icons.bug_report,
      Icons.pets,
    ];
    if (entityList.length == 0) return SizedBox.shrink();
    final isFlora = entityList[0] is Flora;
    return NotificationListener(
      onNotification: (notification) {
        if (notification is ScrollUpdateNotification &&
            notification.depth == 0) {
          Provider.of<SearchNotifier>(context).keyboardAppear = false;
        }
        return false;
      },
      child: Selector<FilterNotifier, List<Trail>>(
        selector: (context, sortNotifier) {
          return sortNotifier.selectedTrails;
        },
        builder: (context, selectedTrails, child) {
          if (selectedTrails == null) {
            selectedTrails = List.from(
                Provider.of<FirebaseData>(context, listen: false)
                    ?.trails
                    ?.keys);
            if (selectedTrails == null) return const SizedBox.shrink();
            Provider.of<FilterNotifier>(context, listen: false)
                .updateSelectedTrailsDiscreetly(selectedTrails);
          }
          List<Entity> updatedEntityList = entityList;
          if (selectedTrails.length != 3) {
            updatedEntityList = entityList.where((entity) {
              return !entity.locations.every((location) {
                return selectedTrails.every((trail) {
                  return trail.id != location[0];
                });
              });
            }).toList();
          }
          return Selector<SearchNotifier, String>(
            selector: (context, searchNotifier) => searchNotifier.searchTerm,
            builder: (context, searchTerm, child) {
              List<Entity> _list = [];
              if (searchTerm != '*') {
                updatedEntityList.forEach((entity) {
                  if (_isValid(entity, searchTerm)) {
                    _list.add(entity);
                  }
                });
              } else {
                _list = updatedEntityList;
              }
              if (isFlora)
                floraIcons.shuffle();
              else
                faunaIcons.shuffle();
              return CustomAnimatedSwitcher(
                child: _list.length == 0
                    ? Padding(
                        key: ValueKey(searchTerm + '!'),
                        padding: const EdgeInsets.fromLTRB(0, 16, 0, 64),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(
                              isFlora ? floraIcons[0] : faunaIcons[0],
                              size: 64,
                              color: Theme.of(context).disabledColor,
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            Text(
                              'No matching ${isFlora ? 'flora' : 'fauna'}',
                              style: TextStyle(
                                color: Theme.of(context).disabledColor,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        key: ValueKey(
                            searchTerm + updatedEntityList.length.toString()),
                        padding: EdgeInsets.fromLTRB(0, 16, 0, searchTerm.isEmpty ? 80 : 64),
                        controller: scrollController,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: _list.length,
                        itemExtent: searchTerm.isEmpty ? 104 : 84,
                        itemBuilder: (context, index) {
                          return EntityListRow(
                            searchTerm: searchTerm,
                            entity: _list[index],
                            index: index,
                            scrollController: scrollController,
                          );
                        },
                      ),
              );
            },
          );
        },
      ),
    );
  }
}

class EntityListRow extends StatefulWidget {
  final String searchTerm;
  final Entity entity;
  final int index;
  final ScrollController scrollController; // For getting scroll position
  const EntityListRow({
    Key key,
    @required this.searchTerm,
    @required this.entity,
    @required this.index,
    @required this.scrollController,
  }) : super(key: key);

  @override
  _EntityListRowState createState() => _EntityListRowState();
}

class _EntityListRowState extends State<EntityListRow> {
  final hidden = ValueNotifier(false);
  Animation<double> secondaryAnimation;

  void listener() {
    if (secondaryAnimation.value > 0) {
      hidden.value = true;
    } else if (secondaryAnimation.isDismissed) {
      if (mounted) hidden.value = false;
      secondaryAnimation.removeListener(listener);
    }
  }

  @override
  void dispose() {
    hidden.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rowHeight = widget.searchTerm.isEmpty ? 104.0 : 84.0;
    final topPadding = MediaQuery.of(context).padding.top;
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final thumbnail = ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: CustomImage(
        widget.entity.smallImage,
        height: 64,
        width: 64,
        placeholderColor: Theme.of(context).dividerColor,
        fadeInDuration: const Duration(milliseconds: 300),
      ),
    );
    final rightColumn = Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            widget.entity.name,
            style: Theme.of(context).textTheme.subhead.copyWith(
                  fontSize: widget.searchTerm.isEmpty ? 16 : 17,
                ),
          ),
          if (widget.searchTerm.isEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                widget.entity.description,
                style: Theme.of(context).textTheme.caption,
                overflow: TextOverflow.ellipsis,
                maxLines: 3,
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(
                widget.entity.sciName,
                style: Theme.of(context).textTheme.overline,
              ),
            ),
        ],
      ),
    );
    return InkWell(
      child: ValueListenableBuilder<bool>(
        valueListenable: hidden,
        builder: (context, value, child) {
          return Visibility(
            visible: !value,
            child: child,
          );
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
          child: Row(
            children: <Widget>[
              thumbnail,
              const SizedBox(
                width: 16,
              ),
              rightColumn,
            ],
          ),
        ),
      ),
      onTap: () async {
        final searchNotifier =
            Provider.of<SearchNotifier>(context, listen: false);
        if (searchNotifier.keyboardAppear) {
          searchNotifier.keyboardAppear = false;
          await Future.delayed(const Duration(milliseconds: 100));
        }
        final oldChild = Container(
          height: rowHeight,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: <Widget>[
              const SizedBox(
                width: 80,
              ),
              rightColumn,
            ],
          ),
        );
        final persistentOldChild = Container(
          height: rowHeight,
          padding: const EdgeInsets.only(left: 14),
          child: Row(
            children: <Widget>[
              thumbnail,
            ],
          ),
        );
        final startContentOffset =
            ValueNotifier(Offset(0, (rowHeight - 64) / 2));
        final endContentOffset = ValueNotifier(Offset(0, topPadding + 16));
        final sourceRect = Rect.fromLTWH(0, 69, width, rowHeight);
        final anim = Tween<double>(
          begin: 0,
          end: 1 / (height - Sizes.kBottomHeight),
        ).animate(
          Provider.of<BottomSheetNotifier>(context, listen: false).animation,
        );
        final topSpace = Tween(
          begin: Sizes.hEntityButtonHeightCollapsed + 24 + topPadding,
          end: Sizes.kBottomHeight - Sizes.hBottomBarHeight + 8,
        ).animate(anim);
        secondaryAnimation = ModalRoute.of(context).secondaryAnimation
          ..addListener(listener);
        Provider.of<AppNotifier>(context, listen: false).push(
          context: context,
          route: ExpandPageRoute(
            builder: (context) => EntityDetailsPage(
              endContentOffset: endContentOffset,
              entity: widget.entity,
            ),
            sourceRect: sourceRect,
            oldChild: oldChild,
            startContentOffset: startContentOffset,
            endContentOffset: endContentOffset,
            persistentOldChild: persistentOldChild,
            rowOffset: rowHeight * widget.index,
            oldScrollController: widget.scrollController,
            topSpace: topSpace,
          ),
          routeInfo: RouteInfo(
            name: widget.entity.name,
            data: widget.entity,
          ),
        );
      },
    );
  }
}
