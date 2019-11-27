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

// This is just for a much smoother gradient
class GradientWidget extends StatelessWidget {
  final Color color;
  final double size;
  final Alignment begin;
  final Alignment end;
  const GradientWidget({
    Key key,
    @required this.color,
    this.size = 32,
    this.begin = Alignment.topCenter,
    this.end = Alignment.bottomCenter,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        height: begin == Alignment.centerLeft || begin == Alignment.centerRight
            ? null
            : size,
        width: begin == Alignment.centerLeft || begin == Alignment.centerRight
            ? size
            : null,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: begin,
            end: end,
            colors: [
              color.withOpacity(1),
              color.withOpacity(.738),
              color.withOpacity(.541),
              color.withOpacity(.382),
              color.withOpacity(.278),
              color.withOpacity(.194),
              color.withOpacity(.126),
              color.withOpacity(.075),
              color.withOpacity(.042),
              color.withOpacity(.021),
              color.withOpacity(.008),
              color.withOpacity(.002),
              color.withOpacity(0),
            ],
            stops: [
              0,
              .19,
              .34,
              .45,
              .565,
              .65,
              .73,
              .802,
              .861,
              .91,
              .952,
              .982,
              1,
            ],
          ),
        ),
      ),
    );
  }
}

/// A widget that has a height of the [MediaQuery]'s bottom padding
class BottomPadding extends StatelessWidget {
  const BottomPadding({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).padding.bottom,
    );
  }
}

/// A widget that has a height of the [MediaQuery]'s bottom view inset
class BottomInset extends StatelessWidget {
  const BottomInset({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).viewInsets.bottom,
    );
  }
}
