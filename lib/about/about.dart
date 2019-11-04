import '../library.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({Key key}) : super(key: key);

  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    return Selector<FirebaseData, List<AboutPageData>>(
      selector: (context, firebaseData) => firebaseData.aboutPageDataList,
      builder: (context, aboutPageDataList, child) {
        return CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              actions: [const SizedBox.shrink()],
              automaticallyImplyLeading: false,
              backgroundColor: Colors.transparent,
              expandedHeight: 96 + topPadding,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                title: Text(
                  'About',
                  style: Theme.of(context).textTheme.display1.copyWith(
                        color: Colors.brown,
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
                      aboutPageDataList[index].isExpanded = !isExpanded;
                    });
                  },
                  children: aboutPageDataList.map((aboutPageData) {
                    final List<String> bodyStrings =
                        aboutPageData.body.split('\n');
                    return ExpansionPanel(
                      canTapOnHeader: true,
                      headerBuilder: (BuildContext context, bool isExpanded) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8, left: 24),
                          child: Text(
                            aboutPageData.title,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                      body: Padding(
                          padding: const EdgeInsets.only(bottom: 28),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(24, 0, 24, 8),
                                child: Text(
                                  aboutPageData.quote,
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
                                child: Column(
                                  children: <Widget>[
                                    for (var bodyString in bodyStrings)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 10,
                                        ),
                                        child: Text(
                                          bodyString,
                                          style: TextStyle(
                                            fontSize: 15,
                                          ),
                                          textAlign: aboutPageData.title ==
                                                  'References'
                                              ? TextAlign.left
                                              : TextAlign.justify,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          )),
                      isExpanded: aboutPageData.isExpanded,
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
