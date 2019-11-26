import '../library.dart';

/// An [InfoRow] is the top row of elements typically found in [EntityDetailsPage] or [TrailLocationOverviewPage], containing the image of an [Entity] or a [TrailLocation], with its name and additional description.
class InfoRow extends StatelessWidget {
  final String image;
  final String title;
  final String subtitle;
  final bool italicised;
  final double height;
  final bool tapToAnimate;
  const InfoRow({
    Key key,
    @required this.image,
    @required this.title,
    @required this.subtitle,
    this.italicised = false,
    this.height = Sizes.kInfoRowHeight,
    this.tapToAnimate = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bottomSheetNotifier =
        Provider.of<BottomSheetNotifier>(context, listen: false);
    return InkWell(
      onTap: tapToAnimate
          ? () {
              if (bottomSheetNotifier.animation.value < 8) {
                bottomSheetNotifier.animateTo(
                  bottomSheetNotifier.snappingPositions.value.last,
                );
              } else {
                bottomSheetNotifier.animateTo(
                  bottomSheetNotifier.snappingPositions.value.first,
                );
              }
            }
          : null,
      child: Container(
        height: height ?? Sizes.kInfoRowHeight,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: CustomImage(
                image,
                height: 64,
                width: 64,
                placeholderColor: Theme.of(context).dividerColor,
              ),
            ),
            const SizedBox(
              width: 16,
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: Theme.of(context).textTheme.subhead,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  Text(
                    subtitle,
                    style: italicised
                        ? Theme.of(context).textTheme.overline
                        : Theme.of(context).textTheme.caption.copyWith(
                              fontSize: 13.5,
                            ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(
                    height: 2,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
