import 'library.dart';

class ThemeNotifier extends ValueNotifier<bool> {
  ThemeNotifier(bool value) : super(value);
  @override
  set value(bool newValue) {
    if (super.value != newValue) {
      SharedPreferences.getInstance().then((prefs) {
        prefs.setBool('isDark', newValue);
      });
      super.value = newValue;
    }
  }
}

final ThemeData themeData = ThemeData(
  fontFamily: 'Manrope',
  primaryColor: Color(0xFF27B50E), // Green
  primaryColorBrightness: Brightness.dark,
  accentColor: Color(0xFF27B50E),
  accentColorBrightness: Brightness.dark,
  textTheme: textTheme.merge(lightThemeText),
);

final ThemeData darkThemeData = ThemeData(
  brightness: Brightness.dark,
  fontFamily: 'Manrope',
  primaryColor: Colors.grey[800],
  primaryColorBrightness: Brightness.dark,
  accentColor: Colors.lightGreenAccent[400],
  accentColorBrightness: Brightness.dark,
  canvasColor: Colors.grey[900],
  bottomAppBarColor: Colors.grey[850],
  textTheme: textTheme.merge(darkThemeText),
  toggleableActiveColor: Colors.lightGreenAccent[400],
);

const TextTheme textTheme = TextTheme(
  // History & About headings
  display2: TextStyle(
    height: 1.2,
    fontSize: 22,
    fontWeight: FontWeight.bold,
  ),
  // 'Explore HC Garden' and entity name in details page
  display1: TextStyle(
    fontSize: 20,
    height: 1.2,
  ),
  // title: TextStyle(
  //   fontWeight: FontWeight.bold,
  // ),
  // Use for 'Flora' & 'Fauna' buttons
  headline: TextStyle(
    fontSize: 18,
    height: 1.5,
    fontWeight: FontWeight.bold,
  ),
  // Used for each entity's name in entity list page
  subhead: TextStyle(
    fontSize: 16,
  ),
  // Used for each entity's description in entity list page
  caption: TextStyle(
    height: 1.5,
  ),
  subtitle: TextStyle(
    fontSize: 14.2,
    fontWeight: FontWeight.bold,
  ),
  // Main paragraph text
  body1: TextStyle(
    fontSize: 14.2,
  ),
  body2: TextStyle(
    fontSize: 14.2,
  ),
  // For latin names
  overline: TextStyle(
    fontSize: 15.5,
    fontStyle: FontStyle.italic,
    height: 1.5,
    letterSpacing: 0.05,
  ),
);

const TextTheme lightThemeText = TextTheme(
  display2: TextStyle(
    color: Color(0xFF7A3735), // Dark reddish-brown
  ),
  display1: TextStyle(
    color: Colors.black87,
  ),
  overline: TextStyle(
    color: Colors.black54,
  ),
);

const TextTheme darkThemeText = TextTheme(
  display2: TextStyle(
    color: Color(0xFFF5730F), // Very light green
  ),
  display1: TextStyle(
    color: Colors.white,
  ),
  overline: TextStyle(
    color: Colors.white70,
  ),
);
