import '../../library.dart';

class EntityListPage extends StatelessWidget {
  final bool isFlora;
  final ScrollController scrollController;

  const EntityListPage({
    Key key,
    @required this.isFlora,
    @required this.scrollController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final searchTerm = Provider.of<SearchNotifier>(context).searchTerm;
    // TODO: Only update when no. of categories change
    final entities = Provider.of<FirebaseData>(context)?.entities;
    if (entities == null) return const SizedBox.shrink();
    final faunaCategories = entities.keys.where((category) {
      return category != 'flora';
    }).toList()
      ..sort();
    return CustomAnimatedSwitcher(
      child: CustomScrollView(
        key: ValueKey(searchTerm),
        controller: scrollController,
        physics: NeverScrollableScrollPhysics(),
        slivers: <Widget>[
          const SliverToBoxAdapter(
            child: SizedBox(
              height: 16,
            ),
          ),
          if (isFlora)
            EntityCategoryWidget(
              category: 'flora',
              scrollController: scrollController,
            )
          else
            for (final category in faunaCategories)
              EntityCategoryWidget(
                category: category,
                scrollController: scrollController,
              ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: bottomPadding + Sizes.kBottomBarHeight + 8,
            ),
          ),
        ],
      ),
    );
  }
}

class EntityCategoryWidget extends StatelessWidget {
  final String category;
  final ScrollController scrollController;
  const EntityCategoryWidget({
    Key key,
    @required this.category,
    @required this.scrollController,
  }) : super(key: key);

  static const floraIcons = [
    Icons.nature_people,
    Icons.filter_vintage,
    Icons.spa,
  ];
  static const faunaIcons = [
    Icons.bug_report,
    Icons.pets,
  ];

  @override
  Widget build(BuildContext context) {
    final isFlora = category == 'flora';
    final filterNotifier = Provider.of<FilterNotifier>(context);
    final searchTerm = Provider.of<SearchNotifier>(context).searchTerm;
    final firebaseData = Provider.of<FirebaseData>(context);
    var selectedTrailKeys = filterNotifier.selectedTrailKeys;
    List<Entity> entityList;

    // Sort by distance and does filtering based on trails and search inside as well
    if (filterNotifier.isSortedByDistance) {
      entityList = [];
      for (final entityDistance in filterNotifier.entitiesByDist[category]) {
        if (selectedTrailKeys.contains(entityDistance.key)) {
          final entity = firebaseData.entities[category][entityDistance.key.id];
          if (entity.satisfies(searchTerm)) entityList.add(entity);
        }
      }
    }
    // Filter by trail, no sorting by distance
    else {
      if (selectedTrailKeys.length == 3) {
        entityList = firebaseData.entities[category].where((entity) {
          return entity.satisfies(searchTerm);
        }).toList();
      } else {
        entityList = firebaseData.entities[category].where((entity) {
          return selectedTrailKeys.contains(entity.key) &&
              entity.satisfies(searchTerm);
        }).toList();
      }
      entityList.sort();
    }

    if (entityList.isEmpty) {
      return SliverPadding(
        padding: EdgeInsets.symmetric(vertical: isFlora ? 24 : 12),
        sliver: SliverToBoxAdapter(
          child: Row(
            children: <Widget>[
              Container(
                width: 94,
                alignment: Alignment.center,
                child: Icon(
                  isFlora
                      ? floraIcons[Random().nextInt(floraIcons.length)]
                      : faunaIcons[Random().nextInt(faunaIcons.length)],
                  size: 36,
                  color: Theme.of(context).disabledColor,
                ),
              ),
              Text(
                'No matching $category',
                style: TextStyle(
                  color: Theme.of(context).disabledColor,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (isFlora) {
      return SliverFixedExtentList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return EntityListRow(
              searchTerm: searchTerm,
              entity: entityList[index],
              index: index,
              scrollController: scrollController,
            );
          },
          childCount: entityList.length,
        ),
        itemExtent: searchTerm.isEmpty ? 104 : 84,
      );
    }
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index == 0) {
            return Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              alignment: Alignment.centerLeft,
              child: Text(
                category[0].toUpperCase() + category.substring(1),
                style: Theme.of(context).textTheme.subtitle,
              ),
            );
          }
          return SizedBox(
            height: searchTerm.isEmpty ? 104 : 84,
            child: EntityListRow(
              searchTerm: searchTerm,
              entity: entityList[index - 1],
              index: index,
              scrollController: scrollController,
            ),
          );
        },
        childCount: entityList.length + 1,
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
  EntityMap _entities;
  double _rowHeight;
  Animation<double> _bottomSheetAnimation;
  Tween<double> _topSpaceTween;
  Tween<double> _contentOffsetTween;

  /// Needed for fauna, where the space for previous categories also\
  /// needs to be correctly calculated
  double _previousCategoriesHeight = 0;

  double _getSourceTop() {
    return _topSpaceTween.evaluate(_bottomSheetAnimation) +
        _rowHeight * widget.index -
        widget.scrollController.offset +
        _previousCategoriesHeight;
  }

  double _getContentOffset() {
    return _contentOffsetTween.evaluate(_bottomSheetAnimation);
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final height = MediaQuery.of(context).size.height;

    _rowHeight = widget.searchTerm.isEmpty ? 104 : 84;
    _entities = Provider.of<FirebaseData>(context).entities;
    if (widget.entity.key.category != 'flora') {
      _previousCategoriesHeight += 48;
      final faunaCategories = _entities.keys.where((category) {
        return category != 'flora';
      }).toList()
        ..sort();
      final previousCategories = faunaCategories.takeWhile((category) {
        return category != widget.entity.key.category;
      });
      for (final category in previousCategories) {
        _previousCategoriesHeight += 48 + _rowHeight * _entities[category].length;
      }
    }

    _bottomSheetAnimation = Tween<double>(
      begin: 0,
      end: 1 / (height - Sizes.kBottomHeight),
    ).animate(
      Provider.of<BottomSheetNotifier>(context, listen: false).animation,
    );
    _topSpaceTween = Tween(
      begin: Sizes.hEntityButtonHeightCollapsed + 24 + topPadding,
      end: Sizes.kBottomHeight - Sizes.hBottomBarHeight + 8,
    );
    _contentOffsetTween = Tween(
      begin: topPadding + 16 - (_rowHeight - 64) / 2,
      end: 16 - (_rowHeight - 64) / 2,
    );

    final heroTag = widget.entity.key;
    return InkWell(
      child: InfoRow(
        height: _rowHeight,
        heroTag: heroTag,
        image: widget.entity.smallImage,
        title: widget.entity.name,
        titleStyle: widget.searchTerm.isEmpty
            ? Theme.of(context).textTheme.subhead.copyWith(
                  fontSize: 16,
                )
            : null,
        subtitle: widget.searchTerm.isEmpty
            ? widget.entity.description
            : widget.entity.sciName,
        subtitleStyle: widget.searchTerm.isEmpty
            ? null
            : Theme.of(context).textTheme.overline,
        tapToAnimate: false,
        isThreeLine: widget.searchTerm.isEmpty,
      ),
      onTap: () {
        Provider.of<AppNotifier>(context, listen: false).push(
          context: context,
          routeInfo: RouteInfo(
            name: widget.entity.name,
            dataKey: widget.entity.key,
            route: SlidingUpPageRoute(
              getSourceTop: _getSourceTop,
              sourceHeight: _rowHeight,
              getContentOffset: _getContentOffset,
              builder: (context) => EntityDetailsPage(
                entityKey: widget.entity.key,
              ),
            ),
          ),
        );
      },
    );
  }
}
