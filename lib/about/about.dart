import '../library.dart';

List<String> aboutPageTitles = [
  'Message from Committee',
  'Acknowledgements',
  'References',
];

List<String> aboutPageQuotes = [
  '\'If you truly love Nature, you will find beauty everywhere.\' - Vincent van Gogh',
  '\'If I have seen further, it is by standing on the shoulders of giants.\' - Sir Isaac Newton',
  '',
];

List<String> aboutPageDes = [
  'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec fermentum enim quis vehicula posuere. Nullam eget mi semper, rutrum dolor ac, dictum est. Pellentesque tempor et metus sed hendrerit. Sed vel suscipit nunc. Vivamus rutrum eleifend ligula. Praesent dictum feugiat est, ac facilisis purus varius ut. Nunc sit amet malesuada leo. Aenean ut lacus dapibus, cursus tortor ut, mollis magna. Cras mollis ligula lorem, eget scelerisque quam gravida ac.',
  'Praesent ac dolor vestibulum, egestas erat nec, vestibulum velit. Mauris ut mauris at orci gravida dapibus. Morbi posuere nulla est, ac interdum arcu semper sit amet. Cras porttitor gravida mi, non condimentum turpis accumsan eu. Ut laoreet nisi at est convallis sodales. Donec lacinia, dolor rhoncus molestie consectetur, felis ex imperdiet nulla, nec rhoncus dui massa sed lacus. Nunc a interdum sapien. Morbi imperdiet tellus ut nulla placerat maximus. Maecenas facilisis urna ut consectetur fermentum. Etiam elementum tristique quam, non fermentum quam euismod eu. Quisque cursus faucibus metus at egestas.',
  'Cras sem ipsum, efficitur vitae cursus sed, molestie ac sem. Donec non vulputate arcu. Duis efficitur gravida ullamcorper. Nunc orci ligula, efficitur eu maximus ac, molestie ut elit. Nullam eu nisl nec lacus ultricies fringilla a sed justo. In enim purus, pretium nec tempus id, elementum nec elit. Aliquam hendrerit mi quis est tincidunt fringilla. In condimentum lorem gravida ex luctus, non interdum magna tempus. Vestibulum ut ante suscipit, imperdiet enim ac, vestibulum sem. Sed sit amet tempus eros. Proin eget sodales velit, et rutrum nisi.',
];

class AboutPageItem {
  final String title;
  final String body;
  final String quote;
  bool isExpanded = false;
  AboutPageItem({this.title, this.quote, this.body});
}

List<AboutPageItem> generateItems(List<String> aboutPageTitles, List<String> aboutPageDes){
  return List.generate(aboutPageTitles.length, (int index) {
    return AboutPageItem(
      title: aboutPageTitles[index],
      quote: aboutPageQuotes[index],
      body: aboutPageDes[index],
    );
  });
}

List<AboutPageItem> _aboutPageData = generateItems(aboutPageTitles, aboutPageDes);

class AboutPage extends StatefulWidget {
  const AboutPage({Key key}) : super(key: key);

  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'About',
            style: Theme.of(context).textTheme.display1.copyWith(
                  color: Colors.black87,
                  fontSize: 32.0,
                  fontWeight: FontWeight.w700,
                ),
            textAlign: TextAlign.center,
          ),
        ),
        ExpansionPanelList(
          expansionCallback: (int index, bool isExpanded) {
            setState(() {
              _aboutPageData[index].isExpanded = !isExpanded;
            });
          },
          children: _aboutPageData.map<ExpansionPanel>((AboutPageItem item) {
            return ExpansionPanel(
              headerBuilder: (BuildContext context, bool isExpanded) {
                return ListTile(
                  title: Text(item.title),
                  subtitle: item.quote!=null ? Text(item.quote) : null, 
                );
              },
              body: ListTile(
                  title: Text(item.body),
              ),
              isExpanded: item.isExpanded,
            );
          }).toList(),
        )
      ],
    );
  }
}
