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
    final width = MediaQuery.of(context).size.width;
    List<String> newImages = [];
    for (var image in widget.entity.images) {
      var split = image.split('.');
      final end = '.' + split.removeLast();
      newImages.add(split.join('.') + 'h' + end);
    }
    return Selector<AppNotifier, int>(
      selector: (context, appNotifier) => appNotifier.state,
      builder: (context, state, child) {
        return SingleChildScrollView(
          physics: NeverScrollableScrollPhysics(),
          controller: state == 1
              ? widget.scrollController
              : ScrollController(),
          child: child,
        );
      },
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
                  for (var image in newImages)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: CustomImage(
                        image,
                        height: 216,
                        width: newImages.length == 1 ? width - 32 : 324,
                        fit: BoxFit.cover,
                        placeholderColor: Theme.of(context).dividerColor,
                        saveInCache: false,
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
