import '../library.dart';

String ackParas = "This project would certainly not have been possible without the generous assistance of many of our Hwa Chong teachers, alumni and students. \n \n"
      "We would like to express our heartfelt appreciation and sincere gratitude to our Principal, Mr. Pang Choon How, and Deputy Principals for their support, in particular: Deputy Principal/Special Projects, Mr Tan Pheng Tiong, for sharing with us more about Hwa Chong's rich history and landscaping, as well as the historical photographs of the school; "
      "Dean of Research Studies, Dr Chia Hui Ping, for sharing her expertise and knowledge in botany with us; Dr Lim Jit Ning, for his endless encouragement; Dr Adeline Chia, for her guidance and mentorship throughout this entire journey; Dr Sandra Tan, for her invaluable recommendations and assistance in the publicity of the project, as well as vetting of write-ups; "
      "Mr Tang Koon Loon and Mr Lau Soo Yen, for sharing their passion for birds and vivid photographs of fauna in the school with us; Mr Mark Tan, for his innovative suggestions, comprehensive proofreading of the write-ups and training us as trail guides; together with Ms Tan Wei Qian, for her constructive suggestions concerning the write-ups. \n \n"
      "We would also like to extend our gratitude to school alumni who have contributed to our school landscape. In particular to Mr. Mak Chin On, for the contributions of fauna that he has made over the past few decades, and for sharing his wealth of knowledge on the great variety of trees in the school with us. \n \n"
      "The estate staff and school gardeners are our unsung heroes - working tirelessly over many years to shape the landscape in school, and making it the thriving Garden Campus it is today. \n \n"
      "Last but not least, we would like to thank the school for providing us with the opportunity to work on this very meaningful project. This journey has taught us to appreciate Hwa Chong from a different perspective, and proves that this hundred year-old campus still has many surprises waiting to be uncovered. \n\n"
      "This work is dedicated to all the giants in our lives.";
String refsPara = "We would also like to acknowledge the following key sources of information for our writeups. We declare that no photographs from these sources have been used by us. \n \n"
      "Chin, Jacquelin, and John Chin. John&Jacq\'s Garden. 2011. Accessed 2019. https://jaycjayc.com/ \n \n"
      "Fern, Ken et al. \"Useful Tropical Plants.\" Useful Tropical Plants. Accessed 2019. http://tropical.theferns.info/ \n \n"
      "Flowers of India. Accessed 2019. http://flowersofindia.net/ \n \n"
      "Master Gardener Program. 2019. Accessed 2019. https://wimastergardener.org/ \n \n"
      "Missouri Botanical Garden. Accessed 2019. http://www.missouribotanicalgarden.org/ \n \n"
      "Mound, Laurence A, Dom W Collins and Anne Hastings. Thysanoptera Britannica et Hibernica - Thrips of The British Isles. Lucidcentral.org, Identic Pty Ltd, Queensland, Australia. 2018. Accessed 2019. https://keys.lucidcentral.org \n \n"
      "National Center for Biotechnology Information (NCBI). Accessed 2019. https://www.ncbi.nlm.nih.gov/ \n \n"
      "National Library Board Singapore eResources. 2019. Accessed 2019. http://eresources.nlb.gov.sg/ \n \n"
      "National Parks Board (NParks). Accessed 2019. https://www.nparks.gov.sg/ \n \n"
      "Plants For A Future. 2012. Accessed 2019. https://pfaf.org/user/Default.aspx \n \n"
      "Silk, Ferry et al. Plants of Southeast Asia. 2009. Accessed 2019. http://www.asianplant.net/ \n \n"
      "Stuart, Godofredo U. StuartXchange. 2018. Accessed 2019. http://www.stuartexchange.org/ \n \n"
      "Wikipedia. Accessed 2019. https://en.wikipedia.org/";

List<String> aboutPageTitles = [
  'Message from Committee',
  'Acknowledgements',
  'References',
];

List<String> aboutPageQuotes = [
  '\'If you truly love Nature, you will find beauty everywhere.\' ~Vincent van Gogh',
  '\'If I have seen further, it is by standing on the shoulders of giants.\' ~Sir Isaac Newton',
  '\'The larger the island of knowledge, the longer the shoreline of wonder.\' \n~Ralph W. Sockman',
];

List<String> aboutPageDes = [
  'As a group of nature lovers in Hwa Chong, we set out to discover the legacy of beauty in the greenery of our garden campus. Identifying the plethora of flora and fauna seemed daunting at first, but we ended up deeply enthralled by the boundless biodiversity in our school and the rich history behind it. \n \nWe were also amazed by the amount of devotion behind the landscape of Hwa Chong - some plants are donations from alumni, while others are selections by teachers for biology classes. The healthy ecosystem created by the artfully designed green spaces allowed a great variety of birds and insects to thrive on campus, bringing us closer to nature. \n \nIndeed, the excitement of identifying species and learning about the intriguing characteristics of each of them drove us to become more curious and observant each time we wander around in school. Every time we pause and marvel at the plants around us, we become more determined to inspire our friends to appreciate the beauty around us. With our website and mobile app that present selected flora and fauna on campus, we hope that you would also take the time to wander, and pay attention to the hidden gems on our garden campus. ',
  ackParas,
  refsPara,
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
  }
}
