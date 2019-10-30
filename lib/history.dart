import 'library.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    return Selector<FirebaseData, List<HistoricalData>>(
      selector: (context, firebaseData) => firebaseData.historicalDataList,
      builder: (context, historicalDataList, child) {
        print(historicalDataList);
        return ListView(
          padding: EdgeInsets.only(top: topPadding + 24),
          children: <Widget>[
            Text(
              'Historical Photos',
              style: Theme.of(context).textTheme.display1.copyWith(
                    color: Colors.black87,
                    fontSize: 34.0,
                    fontWeight: FontWeight.w400,
                  ),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 8.0,
            ),
            for (var historicalData in historicalDataList) Column(
              children: <Widget>[
                if (historicalData.description!='') SizedBox(
                  height: 6.0,
                ),
                CustomImage(historicalData.image),
                if (historicalData.description!='') SizedBox(
                  height: 6.0,
                ),
                if (historicalData.description!='') Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    historicalData.description,
                  ),
                )
              ],
            ),
          ],
        );
      },
    );
  }
}
