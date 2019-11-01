import '../library.dart';

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
            SliverAppBar(
              automaticallyImplyLeading: false,
              expandedHeight: 96 + topPadding,
              backgroundColor: Colors.transparent,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                title: Text(
                  'Historical Photos',
                  style: Theme.of(context).textTheme.title.copyWith(
                        color: Colors.brown,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(16, 24, 16, 24),
              sliver: SliverToBoxAdapter(
                child: Text(
                  'This page is dedicated for all alumni whom may be interested in the brief history of flora in Hwa Chong. Are you able to guess which years were these photos taken?',
                  style: TextStyle(
                    fontSize: 15,
                  ),
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
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                          child: Text(
                            historicalDataList[index].description,
                            style: TextStyle(
                              fontSize: 15,
                            ),
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
