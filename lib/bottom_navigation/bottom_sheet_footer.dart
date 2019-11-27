import '../library.dart';

class BottomSheetFooter extends StatelessWidget {
  final ValueNotifier<int> pageIndex;
  const BottomSheetFooter({
    Key key,
    @required this.pageIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      height: max(Sizes.hBottomBarHeight, Sizes.kBottomBarHeight) +
          MediaQuery.of(context).viewInsets.bottom,
      child: Stack(
        children: <Widget>[
          CustomBottomAppBar(),
          CustomBottomNavBar(
            pageIndex: pageIndex,
          ),
        ],
      ),
    );
  }
}
