import 'library.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
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
      ],
    );
  }
}
