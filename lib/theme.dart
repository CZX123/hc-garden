import 'library.dart';

// TODO: Create dark theme
// https://colors.muz.li/palette/4caf50/357a3a/dbffdd/af4f4c/7a3735

final ThemeData themeData = ThemeData(
  fontFamily: 'Manrope',
  primaryColor: Colors.green,
  primaryColorDark: Color(0xFF357A3A),
  primaryColorLight: Color(0xFF5FDE65),
  primaryColorBrightness: Brightness.dark,
  accentColor: Color(0xFFAF4F4C), // Light reddish-brown
  accentColorBrightness: Brightness.dark,
  textTheme: textTheme.merge(lightThemeText),
);

final ThemeData darkThemeData = ThemeData(
  brightness: Brightness.dark,
  fontFamily: 'Manrope',
  primaryColor: Colors.green[700],
  // primaryColorDark: Color(0xFF357A3A),
  // primaryColorLight: Color(0xFF5FDE65),
  primaryColorBrightness: Brightness.dark,
  accentColor: Colors.greenAccent,
  accentColorBrightness: Brightness.light,
  canvasColor: Colors.blueGrey[900],
  bottomAppBarColor: Colors.blueGrey[800],
  textTheme: textTheme.merge(darkThemeText),
  toggleableActiveColor: Colors.greenAccent[400],
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
    height: 1.7,
  ),
  // Used for each entity's description in entity list page
  caption: TextStyle(
    height: 1.5,
  ),
  subtitle: TextStyle(
    fontSize: 14.2,
    fontWeight: FontWeight.bold,
    height: 1.7,
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
    height: 1.7,
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
    color: Color(0xFFDBFFDD), // Very light green
  ),
  display1: TextStyle(
    color: Colors.white,
  ),
  overline: TextStyle(
    color: Colors.white70,
  ),
);
