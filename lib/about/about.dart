import '../library.dart';

List<String> aboutPageTitles = [
  'Message from Committee',
  'Acknowledgements',
  'References',
];

List<String> aboutPageQuotes = [
  '\'If you truly love Nature, you will find beauty everywhere.\' \n- Vincent van Gogh',
  '\'If I have seen further, it is by standing on the shoulders of giants.\' \n- Sir Isaac Newton',
  '\'The larger the island of knowledge, the longer the shoreline of wonder.\' \n- Ralph W. Sockman',
];

List<String> aboutPageDes = [
  'As a group of nature lovers in Hwa Chong, we set out to discover the legacy of beauty in the greenery of our garden campus. Identifying the plethora of flora and fauna seemed daunting at first, but we ended up deeply enthralled by the boundless biodiversity in our school and the rich history behind it. \n \nWe were also amazed by the amount of devotion behind the landscape of Hwa Chong - some plants are donations from alumni, while others are selections by teachers for biology classes. The healthy ecosystem created by the artfully designed green spaces allowed a great variety of birds and insects to thrive on campus, bringing us closer to nature. \n \nIndeed, the excitement of identifying species and learning about the intriguing characteristics of each of them drove us to become more curious and observant each time we wander around in school. Every time we pause and marvel at the plants around us, we become more determined to inspire our friends to appreciate the beauty around us. With our website and mobile app that present selected flora and fauna on campus, we hope that you would also take the time to wander, and pay attention to the hidden gems on our garden campus. ',
  'Praesent ac dolor vestibulum, egestas erat nec, vestibulum velit. Mauris ut mauris at orci gravida dapibus. Morbi posuere nulla est, ac interdum arcu semper sit amet. Cras porttitor gravida mi, non condimentum turpis accumsan eu. Ut laoreet nisi at est convallis sodales. Donec lacinia, dolor rhoncus molestie consectetur, felis ex imperdiet nulla, nec rhoncus dui massa sed lacus. Nunc a interdum sapien. Morbi imperdiet tellus ut nulla placerat maximus. Maecenas facilisis urna ut consectetur fermentum. Etiam elementum tristique quam, non fermentum quam euismod eu. Quisque cursus faucibus metus at egestas.',
  'Cras sem ipsum, efficitur vitae cursus sed, molestie ac sem. Donec non vulputate arcu. Duis efficitur gravida ullamcorper. Nunc orci ligula, efficitur eu maximus ac, molestie ut elit. Nullam eu nisl nec lacus ultricies fringilla a sed justo. In enim purus, pretium nec tempus id, elementum nec elit. Aliquam hendrerit mi quis est tincidunt fringilla. In condimentum lorem gravida ex luctus, non interdum magna tempus. Vestibulum ut ante suscipit, imperdiet enim ac, vestibulum sem. Sed sit amet tempus eros. Proin eget sodales velit, et rutrum nisi.',
];

class AboutPageItem {
  final String title;
  final String body;
  final String quote;
  bool isExpanded = false;
  AboutPageItem({this.title, this.quote, this.body, this.isExpanded});
}

List<AboutPageItem> generateItems(
    List<String> aboutPageTitles, List<String> aboutPageDes) {
  return List.generate(aboutPageTitles.length, (int index) {
    return AboutPageItem(
      title: aboutPageTitles[index],
      quote: aboutPageQuotes[index],
      body: aboutPageDes[index],
      isExpanded: index == 0,
    );
  });
}

List<AboutPageItem> _aboutPageData =
    generateItems(aboutPageTitles, aboutPageDes);

class AboutPage extends StatefulWidget {
  const AboutPage({Key key}) : super(key: key);

  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    return CustomScrollView(
      slivers: <Widget>[
        SliverAppBar(
          actions: [const SizedBox.shrink()],
          backgroundColor: Colors.transparent,
          expandedHeight: 96 + topPadding,
          flexibleSpace: FlexibleSpaceBar(
            centerTitle: true,
            title: Text(
              'About',
              style: Theme.of(context).textTheme.display1.copyWith(
                    //color: Colors.brown,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.only(bottom: 16),
          sliver: SliverToBoxAdapter(
            child: ExpansionPanelList(
              expansionCallback: (int index, bool isExpanded) {
                setState(() {
                  _aboutPageData[index].isExpanded = !isExpanded;
                });
              },
              children: _aboutPageData.map((item) {
                return ExpansionPanel(
                  canTapOnHeader: true,
                  headerBuilder: (BuildContext context, bool isExpanded) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8, left: 24),
                      child: Text(
                        item.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                  body: Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding:
                                const EdgeInsets.fromLTRB(24, 0, 24, 8),
                            child: Text(
                              item.quote,
                              style: TextStyle(
                                fontSize: 16.0,
                                color: Colors.grey,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.fromLTRB(24, 8, 24, 0),
                            child: Text(
                              item.body,
                              style: TextStyle(
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ],
                      )),
                  isExpanded: item.isExpanded,
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
    return ListView(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            'About',
            style: Theme.of(context).textTheme.display1.copyWith(
                  color: Colors.brown,
                  fontSize: 32,
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
          children: _aboutPageData.map((item) {
            return ExpansionPanel(
              canTapOnHeader: true,
              headerBuilder: (BuildContext context, bool isExpanded) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8, left: 16),
                  child: Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
              body: Padding(
                  padding: const EdgeInsets.only(bottom: 26.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(26.0, 0, 26.0, 8.0),
                        child: Text(
                          item.quote,
                          style: TextStyle(
                            fontSize: 16.0,
                            color: Colors.grey,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20.0, 8.0, 20.0, 0),
                        child: Text(
                          item.body,
                          style: TextStyle(
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  )),
              isExpanded: item.isExpanded,
            );
          }).toList(),
        ),
      ],
    );
  }
}
