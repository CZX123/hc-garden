import 'library.dart';

class DetailsPage extends StatefulWidget {
  final Entity entity;
  final ScrollController scrollController;
  DetailsPage({
    Key key,
    @required this.entity,
    @required this.scrollController,
  }) : super(key: key);

  _DetailsPageState createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final appNotifier = Provider.of<AppNotifier>(context);
    return SingleChildScrollView(
      physics: NeverScrollableScrollPhysics(),
      controller:
          appNotifier.state == 1 ? widget.scrollController : ScrollController(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.fromLTRB(14, topPadding + 16, 14, 8),
            child: Row(
              children: <Widget>[
                ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: CustomImage(
                    widget.entity.smallImage,
                    height: 64,
                    width: 64,
                    placeholderColor: Theme.of(context).dividerColor,
                    fadeInDuration: null,
                  ),
                ),
                const SizedBox(
                  width: 16,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      widget.entity.name,
                      style: Theme.of(context).textTheme.title.copyWith(
                            height: 1,
                          ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Text(
                      widget.entity.sciName,
                      style: Theme.of(context).textTheme.subhead.copyWith(
                            height: 1,
                            color: Theme.of(context).hintColor,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          Container(
            height: 216,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 0, 8, 0),
              scrollDirection: Axis.horizontal,
              child: Row(
                children: <Widget>[
                  for (var image in widget.entity.images)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: CustomImage(
                        image,
                        height: 216,
                        width: 324,
                        fit: BoxFit.cover,
                        placeholderColor: Theme.of(context).dividerColor,
                      ),
                    ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Text(
              widget.entity.description,
              style: Theme.of(context).textTheme.subtitle,
            ),
          ),
          const SizedBox(
            height: 100,
          ),
        ],
      ),
    );
  }
}
