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
    return NotificationListener(
      onNotification: (notification) {
        if (notification is ScrollUpdateNotification &&
            notification.depth == 0) {
          Provider.of<SearchNotifier>(context).keyboardAppear = false;
        }
        return false;
      },
      child: Selector<SearchNotifier, String>(
        selector: (context, searchNotifier) => searchNotifier.searchTerm,
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
                    itemExtent: searchTerm.isEmpty ? 104 : 88,
                    itemBuilder: (context, index) {
                      return EntityListRow(
                        searchTerm: searchTerm,
                        entity: _list[index],
                        scrollController: extraScrollController,
                      );
                    },
                  ),
          );
        },
      ),
    );
  }
}

class EntityListRow extends StatefulWidget {
  final String searchTerm;
  final Entity entity;
  final ScrollController scrollController;
  const EntityListRow({
    Key key,
    @required this.searchTerm,
    @required this.entity,
    @required this.scrollController,
  }) : super(key: key);

  @override
  _EntityListRowState createState() => _EntityListRowState();
}

class _EntityListRowState extends State<EntityListRow> {
  final _key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
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
                style: Theme.of(context).textTheme.caption.copyWith(
                      height: 1.5,
                    ),
                overflow: TextOverflow.ellipsis,
                maxLines: 3,
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                widget.entity.sciName,
                style: Theme.of(context).textTheme.caption.copyWith(
                      fontSize: 15,
                      fontStyle: FontStyle.italic,
                    ),
              ),
            ),
        ],
      ),
    );
    return Container(
      key: _key,
      child: InkWell(
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
        onTap: () async {
          final searchNotifier =
              Provider.of<SearchNotifier>(context, listen: false);
          if (searchNotifier.keyboardAppear) {
            searchNotifier.keyboardAppear = false;
            await Future.delayed(const Duration(milliseconds: 200));
          }
          Provider.of<AppNotifier>(context, listen: false)
              .updateState(1, widget.entity);
          searchNotifier.isSearching = false;
          final oldChild = Container(
            height: widget.searchTerm.isEmpty ? 104 : 88,
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
            height: widget.searchTerm.isEmpty ? 104 : 88,
            padding: const EdgeInsets.only(left: 14),
            child: Row(
              children: <Widget>[
                thumbnail,
              ],
            ),
          );
          final oldTopPadding = ValueNotifier(((widget.searchTerm.isEmpty ? 104 : 88) - 64) / 2);
          final newTopPadding = ValueNotifier(topPadding + 16);
          Navigator.of(context).push(
            ExpandPageRoute<void>(
              oldTopPadding: oldTopPadding,
              newTopPadding: newTopPadding,
              builder: (context) => EntityDetailsPage(
                newTopPadding: newTopPadding,
                entity: widget.entity,
                scrollController: widget.scrollController,
              ),
              sourceKey: _key,
              oldChild: oldChild,
              persistentOldChild: persistentOldChild,
            ),
          );
        },
      ),
    );
  }
}
