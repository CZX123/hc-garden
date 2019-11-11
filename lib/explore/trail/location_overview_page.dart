import '../../library.dart';

class TrailLocationOverviewPage extends StatefulWidget {
  final Trail trail;
  final TrailLocation trailLocation;
  const TrailLocationOverviewPage({
    Key key,
    @required this.trail,
    @required this.trailLocation,
  }) : super(key: key);

  @override
  _TrailLocationOverviewPageState createState() => _TrailLocationOverviewPageState();
}

class _TrailLocationOverviewPageState extends State<TrailLocationOverviewPage> {
  
  double aspectRatio;
  
  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    //final orientation = MediaQuery.of(context).orientation;
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    return Scaffold(
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                SystemChrome.setPreferredOrientations(
                    [DeviceOrientation.portraitUp]);
                return Navigator.maybePop(context);
              },
              tooltip: 'Back',
            ),
            Expanded(
              child: Text(
                widget.trailLocation.name,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            SizedBox(width: 48),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(top: topPadding),
          constraints: BoxConstraints(
            minHeight: height - 48,
          ),
          alignment: Alignment.center,
          child: Stack(
            children: <Widget>[
              CustomImage(
                lowerRes(widget.trailLocation.image),
                fit: BoxFit.contain,
                onLoad: (double aspectRatio) {
                  setState(() {
                    this.aspectRatio = aspectRatio;
                  });
                },
              ),
              for (var entityPosition in widget.trailLocation.entityPositions) 
                new Positioned(
                  left: entityPosition.left*width,
                  top: imageHeight==null ? height : entityPosition.top*imageHeight,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: Colors.white38,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.yellow,
                        width: 2.0,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class AnimatedPulseCircle extends StatefulWidget {
  AnimatedPulseCircle({Key key}) : super(key: key);

  @override
  _AnimatedPulseCircleState createState() => _AnimatedPulseCircleState();
}

class _AnimatedPulseCircleState extends State<AnimatedPulseCircle> {
  @override
  Widget build(BuildContext context) {
    return Container(
       child: Text("idk"),
    );
  }
}
