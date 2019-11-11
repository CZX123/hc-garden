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
      Provider.of<AppNotifier>(context).changeState(
        context,
        0,
        activeScrollController: _scrollController,
        trail: widget.trail,
        rebuild: false,
      );
      _init = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final animation = ModalRoute.of(context).animation;
    final topPadding = MediaQuery.of(context).padding.top;
    final height = MediaQuery.of(context).size.height;
    return ScaleTransition(
      scale: Tween(
        begin: 0.96,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.fastOutSlowIn,
      )),
      child: FadeTransition(
        opacity: Tween(
          begin: -1.0,
          end: 1.0,
        ).animate(animation),
        child: Material(
          type: MaterialType.transparency,
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: NeverScrollableScrollPhysics(),
            child: Column(
              children: <Widget>[
                ValueListenableBuilder(
                  valueListenable:
                      Provider.of<BottomSheetNotifier>(context, listen: false)
                          .animation,
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
                  height: 24,
                ),
                for (var location in widget.trailLocations)
                  InkWell(
                    child: Container(
                      height: 64,
                      child: Row(
                        children: <Widget>[
                          const SizedBox(
                            width: 16,
                          ),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: CustomImage(
                              location.smallImage,
                              height: 40,
                              width: 40,
                              placeholderColor: Theme.of(context).dividerColor,
                              fadeInDuration: const Duration(milliseconds: 300),
                            ),
                          ),
                          const SizedBox(
                            width: 16,
                          ),
                          Expanded(
                            child: Text(
                              location.name,
                              style: Theme.of(context).textTheme.subhead,
                            ),
                          )
                        ],
                      ),
                    ),
                    onTap: () {},
                  ),
                SizedBox(
                  height: 64,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
