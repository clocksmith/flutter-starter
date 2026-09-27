import 'package:flutter/material.dart';

/// Layout roles that can be replaced by each app's design system.
@immutable
final class UiSpacing extends ThemeExtension<UiSpacing> {
  const UiSpacing({this.gap = 12, this.inset = 24, this.contentWidth = 720});

  final double gap;
  final double inset;
  final double contentWidth;

  static UiSpacing of(BuildContext context) =>
      Theme.of(context).extension<UiSpacing>() ?? const UiSpacing();

  @override
  UiSpacing copyWith({double? gap, double? inset, double? contentWidth}) =>
      UiSpacing(
        gap: gap ?? this.gap,
        inset: inset ?? this.inset,
        contentWidth: contentWidth ?? this.contentWidth,
      );

  @override
  UiSpacing lerp(covariant UiSpacing? other, double t) => other == null
      ? this
      : UiSpacing(
          gap: gap + (other.gap - gap) * t,
          inset: inset + (other.inset - inset) * t,
          contentWidth: contentWidth + (other.contentWidth - contentWidth) * t,
        );
}

ThemeData createUiTheme({
  required Color seedColor,
  Brightness brightness = Brightness.light,
  UiSpacing spacing = const UiSpacing(),
}) => ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: seedColor,
    brightness: brightness,
  ),
  extensions: [spacing],
);

class ContentArea extends StatelessWidget {
  const ContentArea({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final spacing = UiSpacing.of(context);
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: spacing.contentWidth),
        child: Padding(padding: EdgeInsets.all(spacing.inset), child: child),
      ),
    );
  }
}
