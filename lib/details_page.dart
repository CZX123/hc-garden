import 'package:bottom_sheet/library.dart';
import 'package:transparent_image/transparent_image.dart';

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
                CircleAvatar(
                  radius: 32,
                  backgroundImage: NetworkImage(widget.entity.smallImage),
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
            height: 256,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: PageView(
                children: <Widget>[
                  for (var image in widget.entity.images)
                    Container(
                      height: 256,
                      color: Theme.of(context).dividerColor,
                      child: FadeInImage.memoryNetwork(
                        fadeInDuration: Duration(milliseconds: 300),
                        placeholder: kTransparentImage,
                        fit: BoxFit.cover,
                        image: image,
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
