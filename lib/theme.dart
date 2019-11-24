import 'library.dart';

class ThemeNotifier extends ValueNotifier<bool> {
  ThemeNotifier(bool value) : super(value);

  static final lightOverlayStyle = SystemUiOverlayStyle(
    statusBarIconBrightness: Brightness.dark,
    statusBarColor: Colors.white.withOpacity(.5),
    systemNavigationBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.white,
  );
  static final darkOverlayStyle = SystemUiOverlayStyle(
    statusBarIconBrightness: Brightness.light,
    statusBarColor: Colors.grey[850].withOpacity(.5),
    systemNavigationBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Colors.grey[850],
  );

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
  scaffoldBackgroundColor: Colors.grey[100],
  textSelectionHandleColor: Colors.white,
  textTheme: lightText,
);

final ThemeData darkThemeData = ThemeData(
  brightness: Brightness.dark,
  fontFamily: 'Manrope',
  primaryColor: Colors.grey[800],
  primaryColorBrightness: Brightness.dark,
  accentColor: Colors.lightGreenAccent[400],
  accentColorBrightness: Brightness.dark,
  cardColor: Colors.grey[900],
  scaffoldBackgroundColor: Color(0xFF050505),
  canvasColor: Colors.grey[900],
  bottomAppBarColor: Colors.grey[850],
  toggleableActiveColor: Colors.lightGreenAccent[400],
  // indicatorColor: Colors.lightGreenAccent[400],
  textSelectionHandleColor: Colors.lightGreenAccent[400],
  textTheme: darkText,
);

final lightText = textTheme.merge(lightThemeText);
final darkText = textTheme.merge(darkThemeText);

const TextTheme textTheme = TextTheme(
  // History & About headings
  display2: TextStyle(
    height: 1.2,
    fontSize: 32,
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
    height: 1.3,
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
    color: Color(0xFFF5730F), // Light reddish-brown
  ),
  display1: TextStyle(
    color: Colors.white,
  ),
  overline: TextStyle(
    color: Colors.white70,
  ),
);
