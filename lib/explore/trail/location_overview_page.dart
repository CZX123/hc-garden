import '../../library.dart';

class TrailLocationOverviewPage extends StatelessWidget {
  final Trail trail;
  final TrailLocation trailLocation;
  const TrailLocationOverviewPage({
    Key key,
    @required this.trail,
    @required this.trailLocation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final height = MediaQuery.of(context).size.height;
    final orientation = MediaQuery.of(context).orientation;
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight
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
              child: Text(trailLocation.name),
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
          child: CustomImage(
            trailLocation.image,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
