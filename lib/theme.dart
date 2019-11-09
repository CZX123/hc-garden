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
  textTheme: textTheme,
);

const TextTheme textTheme = TextTheme(
  // History & About headings
  display2: TextStyle(
    height: 1.2,
    fontSize: 22,
    color: Color(0xFF7A3735), // Dark reddish-brown
    fontWeight: FontWeight.bold,
  ),
  // 'Explore HC Garden' and entity name in details page
  display1: TextStyle(
    fontSize: 20,
    height: 1.2,
    color: Colors.black87,
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
    height: 1.7,
  ),
  // Main paragraph text
  body1: TextStyle(
    fontSize: 14.2,
    height: 1.7,
  ),
  // For latin names
  body2: TextStyle(
    color: Colors.black54,
    fontSize: 15.5,
    height: 1.7,
    fontStyle: FontStyle.italic,
  ),
);
