import 'library.dart';

class EntityListPage extends StatelessWidget {
  final ScrollController scrollController; // From the bottom sheet
  final ScrollController extraScrollController; // For the details page;
  final List<Entity> entityList;
  const EntityListPage({
    Key key,
    @required this.scrollController,
    @required this.extraScrollController,
    @required this.entityList,
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
    final bool isFlora = entityList[0] is Flora;
    return Selector<AppNotifier, String>(
      selector: (context, appNotifier) => appNotifier.searchTerm,
      builder: (context, searchTerm, child) {
        List<Entity> _list = [];
        entityList.forEach((entity) {
          if (_isValid(entity, searchTerm)) {
            _list.add(entity);
          }
        });
        if (isFlora)
          floraIcons.shuffle();
        else
          faunaIcons.shuffle();
        return CustomAnimatedSwitcher(
          child: _list.length == 0
              ? Padding(
                  key: ValueKey(searchTerm + '-i'),
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
                        style: Theme.of(context).textTheme.body1.copyWith(
                              color: Theme.of(context).disabledColor,
                            ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  key: ValueKey(searchTerm),
                  padding: const EdgeInsets.fromLTRB(0, 16, 0, 96),
                  controller: scrollController,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: _list.length,
                  itemExtent: 104,
                  itemBuilder: (context, index) {
                    return EntityListRow(
                      entity: _list[index],
                      scrollController: extraScrollController,
                    );
                  },
                ),
        );
      },
    );
  }
}

class EntityListRow extends StatelessWidget {
  final Entity entity;
  final ScrollController scrollController;
  const EntityListRow({
    Key key,
    @required this.entity,
    @required this.scrollController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final key = GlobalKey();
    return Container(
      key: key,
      height: 104,
      child: InkWell(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
          child: Row(
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: CustomImage(
                  entity.smallImage,
                  height: 64,
                  width: 64,
                  placeholderColor: Theme.of(context).dividerColor,
                  fadeInDuration: const Duration(milliseconds: 300),
                ),
              ),
              const SizedBox(
                width: 16,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      entity.name,
                      style: Theme.of(context).textTheme.subhead,
                    ),
                    Text(
                      entity.description,
                      style: Theme.of(context).textTheme.caption.copyWith(
                            height: 1.5,
                          ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 3,
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        onTap: () {
          Provider.of<AppNotifier>(context, listen: false)
              .updateState(1, entity);
          final oldChild = Container(
            height: 104,
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
            child: Row(
              children: <Widget>[
                const SizedBox(
                  width: 80,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        entity.name,
                        style: Theme.of(context).textTheme.subhead,
                      ),
                      Text(
                        entity.description,
                        style: Theme.of(context).textTheme.caption.copyWith(
                              height: 1.5,
                            ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 3,
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
          final persistentOldChild = Container(
            height: 104,
            padding: const EdgeInsets.fromLTRB(14, 18, 14, 18),
            child: Row(
              children: <Widget>[
                ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: CustomImage(
                    entity.smallImage,
                    height: 64,
                    width: 64,
                    placeholderColor: Theme.of(context).dividerColor,
                    fadeInDuration: null,
                  ),
                ),
              ],
            ),
          );
          Navigator.of(context).push(
            ExpandPageRoute<void>(
              builder: (context) => DetailsPage(
                entity: entity,
                scrollController: scrollController,
              ),
              sourceKey: key,
              oldChild: oldChild,
              persistentOldChild: persistentOldChild,
              scrollController: scrollController,
            ),
          );
        },
      ),
    );
  }
}
