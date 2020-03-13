import 'package:hc_garden/src/library.dart';

export 'animation/cross_fade_page_route.dart';
export 'animation/custom_animation_switcher.dart';
export 'animation/sliding_up_page_route.dart';
export 'bottom_sheet/custom_bottom_sheet.dart';
export 'image/before_after.dart';
export 'image/custom_image.dart';
export 'image/image_gallery.dart';

/// An [InfoRow] is the top row of elements typically found in [EntityDetailsPage] or [TrailLocationOverviewPage], containing the image of an [Entity] or a [TrailLocation], with its name and additional description.
class InfoRow extends StatelessWidget {
  final Object heroTag;
  final String image;
  final String title;
  final TextStyle titleStyle;
  final String subtitle;
  final TextStyle subtitleStyle;
  final bool isThreeLine;
  final double height;

  /// Whether tapping the [InfoRow] should open or close the [CustomBottomSheet]
  final bool tapToAnimate;

  const InfoRow({
    Key key,
    this.heroTag,
    @required this.image,
    @required this.title,
    this.titleStyle,
    @required this.subtitle,
    this.subtitleStyle,
    this.isThreeLine = false,
    this.height = Sizes.kInfoRowHeight,
    this.tapToAnimate = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final avatar = ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: CustomImage(
        image,
        height: 64,
        width: 64,
        placeholderColor: Theme.of(context).dividerColor,
      ),
    );
    final bottomSheetNotifier = context.provide<BottomSheetNotifier>(listen: false);
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
            if (heroTag != null) Hero(tag: heroTag, child: avatar) else avatar,
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
                    style: titleStyle ?? Theme.of(context).textTheme.subhead,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  Text(
                    subtitle,
                    style: subtitleStyle ?? Theme.of(context).textTheme.caption,
                    overflow: TextOverflow.ellipsis,
                    maxLines: isThreeLine ? 3 : 1,
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

/// Space that animates from 0 to window's `topPadding` for the bottom sheet,
/// depending on the animation of the [CustomBottomSheet]
class TopPaddingSpace extends StatelessWidget {
  const TopPaddingSpace({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final b = context.provide<BottomSheetNotifier>(listen: false);

    return ValueListenableBuilder<double>(
      valueListenable: b.animation,
      builder: (context, value, child) {
        double h = 0;
        final paddingBreakpoint = b.snappingPositions.value[1];
        if (value < paddingBreakpoint) {
          h = (1 - value / paddingBreakpoint) * topPadding;
        }
        return SizedBox(
          height: h,
        );
      },
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
