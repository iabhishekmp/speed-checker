/// Design tokens for spacing used throughout the app
abstract class AppSpacing {
  // Base spacing unit (4.0)
  static const double unit = 4.0;

  // Spacing values
  static const double xs = unit * 1; // 4
  static const double sm = unit * 2; // 8
  static const double md = unit * 4; // 16
  static const double lg = unit * 6; // 24
  static const double xl = unit * 10; // 40
  static const double xxl = unit * 15; // 60

  // Padding
  static const double paddingXS = xs;
  static const double paddingSM = sm;
  static const double paddingMD = md;
  static const double paddingLG = lg;

  // Border Radius
  static const double radiusXS = 4.0;
  static const double radiusSM = 8.0;
  static const double radiusMD = 12.0;
  static const double radiusLG = 20.0;
  static const double radiusXL = 30.0;

  // Icon Sizes
  static const double iconSM = 20.0;
  static const double iconMD = 24.0;
  static const double iconLG = 48.0;
}
