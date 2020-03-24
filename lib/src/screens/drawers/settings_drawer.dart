import 'package:hc_garden/src/library.dart';

class SettingsDrawer extends StatefulWidget {
  const SettingsDrawer({Key key}) : super(key: key);

  @override
  _SettingsDrawerState createState() => _SettingsDrawerState();
}

class _SettingsDrawerState extends State<SettingsDrawer> {
  void _changeMapType(MapType newType) {
    final mapNotifier = context.provide<MapNotifier>(listen: false);
    mapNotifier.mapType = newType;
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final height = MediaQuery.of(context).size.height;
    return Drawer(
      child: Scrollbar(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(0, topPadding + 16, 0, 16),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: height - topPadding - 32,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox.shrink(),
                const SizedBox.shrink(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    'Preferences',
                    style: Theme.of(context).textTheme.display2,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 28, 16, 12),
                      child: Text(
                        'App Theme',
                        style: Theme.of(context).textTheme.subtitle,
                      ),
                    ),
                    Consumer<ThemeNotifier>(
                      builder: (context, themeNotifier, child) {
                        return ListTile(
                          dense: true,
                          contentPadding:
                              const EdgeInsets.fromLTRB(16, 0, 8, 0),
                          title: Text(
                            'Dark Mode',
                            style: Theme.of(context).textTheme.body1,
                          ),
                          trailing: Switch(
                            value: themeNotifier.value,
                            onChanged: (value) => themeNotifier.value = value,
                          ),
                          onTap: () =>
                              themeNotifier.value = !themeNotifier.value,
                        );
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 28, 16, 12),
                      child: Text(
                        'Map Type',
                        style: Theme.of(context).textTheme.subtitle,
                      ),
                    ),
                    Selector<MapNotifier, MapType>(
                      selector: (context, m) => m.mapType,
                      builder: (context, mapType, child) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            RadioListTile<MapType>(
                              dense: true,
                              controlAffinity: ListTileControlAffinity.trailing,
                              groupValue: mapType,
                              value: MapType.normal,
                              title: Text(
                                'Normal',
                                style: Theme.of(context).textTheme.body1,
                              ),
                              onChanged: _changeMapType,
                            ),
                            RadioListTile<MapType>(
                              dense: true,
                              controlAffinity: ListTileControlAffinity.trailing,
                              groupValue: mapType,
                              value: MapType.hybrid,
                              title: Text(
                                'Satellite',
                                style: Theme.of(context).textTheme.body1,
                              ),
                              onChanged: _changeMapType,
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox.shrink(),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Product of',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).hintColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Padding(
                              padding: const EdgeInsets.only(left: 0.5),
                              child: Image.asset(
                                'assets/images/irs.png',
                                height: 24,
                              ),
                            ),
                            const SizedBox(height: 2),
                          ],
                        ),
                        Spacer(),
                        IconButton(
                          icon: const Icon(Icons.help),
                          color: Theme.of(context).hintColor,
                          tooltip: 'Help',
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              CrossFadePageRoute(
                                builder: (context) => OnboardingPage(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 8),
                      ],
                    ),
                    const BottomPadding(),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
