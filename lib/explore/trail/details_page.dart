import '../../library.dart';

class TrailDetailsPage extends StatefulWidget {
  final Trail trail;
  final List<TrailLocation> trailLocations;
  const TrailDetailsPage({
    Key key,
    @required this.trail,
    @required this.trailLocations,
  }) : super(key: key);

  @override
  _TrailDetailsPageState createState() => _TrailDetailsPageState();
}

class _TrailDetailsPageState extends State<TrailDetailsPage> {
  bool _init = false;
  final _scrollController = ScrollController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_init) {
      Provider.of<BottomSheetNotifier>(
        context,
        listen: false,
      ).activeScrollController = _scrollController;
      _init = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final height = MediaQuery.of(context).size.height;
    return Material(
      color: Theme.of(context).bottomAppBarColor,
      child: SingleChildScrollView(
        controller: _scrollController,
        physics: NeverScrollableScrollPhysics(),
        child: Column(
          children: <Widget>[
            ValueListenableBuilder(
              valueListenable: Provider.of<BottomSheetNotifier>(
                context,
                listen: false,
              ).animation,
              builder: (context, value, child) {
                double h = 0;
                if (value < height - bottomHeight) {
                  h = (1 - value / (height - bottomHeight)) * topPadding;
                }
                return SizedBox(
                  height: h + 32,
                );
              },
            ),
            Text(
              widget.trail.name,
              style: Theme.of(context).textTheme.display1,
            ),
            SizedBox(
              height: 16,
            ),
            for (var location in widget.trailLocations)
              LocationListRow(
                trail: widget.trail,
                location: location,
              ),
            SizedBox(
              height: 64,
            ),
          ],
        ),
      ),
    );
  }
}

class LocationListRow extends StatelessWidget {
  final Trail trail;
  final TrailLocation location;
  const LocationListRow(
      {Key key, @required this.trail, @required this.location})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var names = location.entityPositions
        .map((position) => position.entity?.name)
        .where((name) => name != null)
        .toList();
    //names = names.sublist(0, min(5, names.length));
    return InkWell(
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: 16,
        ),
        child: Row(
          children: <Widget>[
            const SizedBox(
              width: 14,
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: CustomImage(
                location.smallImage,
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
                    location.name,
                    style: Theme.of(context).textTheme.subhead,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      names.join(', '),
                      style: Theme.of(context).textTheme.caption,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 3,
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(
              width: 14,
            ),
          ],
        ),
      ),
      onTap: () {
        Navigator.push(
          context,
          CrossFadePageRoute(
            builder: (context) {
              return TrailLocationOverviewPage(
                trail: trail,
                trailLocation: location,
              );
            },
          ),
        );
        Provider.of<AppNotifier>(context, listen: false).changeState(
          context,
          1,
        );
      },
    );
  }
}
