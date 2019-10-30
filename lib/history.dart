import 'library.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final width = MediaQuery.of(context).size.width;
    return Selector<FirebaseData, List<HistoricalData>>(
      selector: (context, firebaseData) => firebaseData.historicalDataList,
      builder: (context, historicalDataList, child) {
        final newImages = historicalDataList.map((h) {
          var split = h.image.split('.');
          final end = '.' + split.removeLast();
          return split.join('.') + 'h' + end;
        }).toList();
        return CustomScrollView(
          slivers: <Widget>[
            SliverPadding(
              padding: EdgeInsets.fromLTRB(16, topPadding + 24, 16, 16),
              sliver: SliverToBoxAdapter(
                child: Text(
                  'Historical Photos',
                  style: Theme.of(context).textTheme.display1.copyWith(
                        color: Colors.black87,
                        fontSize: 32.0,
                        fontWeight: FontWeight.w700,
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final height = width *
                      historicalDataList[index].height /
                      historicalDataList[index].width;
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      CustomImage(
                        newImages[index],
                        height: height,
                        width: width,
                        placeholderColor: Theme.of(context).dividerColor,
                      ),
                      if (historicalDataList[index].description != '')
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
                          child: Text(
                            historicalDataList[index].description,
                          ),
                        ),
                    ],
                  );
                },
                childCount: historicalDataList.length,
              ),
            ),
          ],
        );
      },
    );
  }
}
