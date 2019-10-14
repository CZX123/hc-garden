import 'library.dart';

class EntityListPage extends StatelessWidget {
  final ScrollController scrollController; // From the bottom sheet
  final List<Entity> entityList;
  const EntityListPage({
    Key key,
    @required this.scrollController,
    @required this.entityList,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Selector<AppNotifier, int>(
      selector: (context, appNotifier) => appNotifier.state,
      builder: (context, state, child) {
        return Scrollbar(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(0, 16, 0, 72),
            controller: state == 0 ? scrollController : ScrollController(),
            physics: NeverScrollableScrollPhysics(),
            itemCount: entityList.length,
            itemBuilder: (context, index) {
              return EntityListRow(
                key: ObjectKey(entityList[index]),
                entity: entityList[index],
                scrollController: scrollController,
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
          final oldChild = Padding(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
            child: Row(
              children: <Widget>[
                const SizedBox(
                  width: 80,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
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
          final persistentOldChild = Padding(
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
            ),
          );
        },
      ),
    );
  }
}
