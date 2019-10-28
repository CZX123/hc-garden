import 'library.dart';

// TODO: handle cases of incomplete data
abstract class Entity {
  final int id;
  final String name;
  final String sciName;
  final String description;
  final String smallImage;
  final List<String> images;
  final List<Map<int, int>> locations;

  Entity.fromJson(String key, dynamic parsedJson)
      : this.id = int.parse(key.split('-').last),
        this.name = parsedJson['name'],
        this.sciName = parsedJson['sciName'],
        this.description = parsedJson['description'],
        this.smallImage = parsedJson['smallImage'],
        this.images = List<String>.from(parsedJson['imageRef']),
        this.locations =
            List.from(parsedJson['locations'].split(',')).where((value) {
          return value != null && value.isNotEmpty;
        }).map((value) {
          final split = value.split('/');
          return {
            int.tryParse(split.first.split('-').last):
                int.tryParse(split.last.split('-').last)
          };
        }).toList();

  @override
  String toString() {
    return 'Entity(name: $name, sciName: $sciName)';
  }
}

class Fauna extends Entity {
  // A fauna has 2 extra keys: areas and coordinates. These are most likely not to be used.
  final List<LatLng> area;
  final LatLng coordinates;
  Fauna.fromJson(String key, dynamic parsedJson)
      : this.area = parsedJson.containsKey('area')
            ? List.from(parsedJson['area']).map((position) {
                return LatLng(position['latitude'], position['longitude']);
              }).toList()
            : null,
        this.coordinates = parsedJson.containsKey('latitude')
            ? LatLng(parsedJson['latitude'], parsedJson['longitude'])
            : null,
        super.fromJson(key, parsedJson);
}

class Flora extends Entity {
  Flora.fromJson(String key, dynamic parsedJson)
      : super.fromJson(key, parsedJson);
}

class FirebaseData {
  final List<Flora> floraList;
  final List<Fauna> faunaList;
  final Map<Trail, List<TrailLocation>> trails;
  FirebaseData({this.floraList, this.faunaList, this.trails});
}

class Trail {
  final int id;
  final String name;
  final String color;
  Trail({this.id, this.name, this.color});
  factory Trail.fromJson(String key, dynamic parsedJson) {
    return Trail(
      id: int.parse(key.split('-').last),
      name: parsedJson['name'],
      color: parsedJson['color'],
    );
  }
}

// A TrailLocation is a point on the trail
class TrailLocation {
  final int id;
  final String name;
  final String image;
  final String smallImage;
  final LatLng coordinates;
  final List<EntityPosition> entityPositions;
  TrailLocation({
    this.id,
    this.name,
    this.image,
    this.smallImage,
    this.coordinates,
    this.entityPositions,
  });
  factory TrailLocation.fromJson(
    String key,
    dynamic parsedJson, {
    @required List<Flora> floraList,
    @required List<Fauna> faunaList,
  }) {
    return TrailLocation(
      id: int.parse(key.split('-').last),
      name: parsedJson['title'],
      image: parsedJson['imageRef'],
      smallImage: parsedJson['smallImage'],
      coordinates: parsedJson.containsKey('latitude')
          ? LatLng(parsedJson['latitude'], parsedJson['longitude'])
          : null,
      entityPositions: List.from(parsedJson['points']).map((point) {
        return EntityPosition.fromJson(
          point,
          floraList: floraList,
          faunaList: faunaList,
        );
      }).toList(),
    );
  }
}

class EntityPosition {
  final Entity entity;
  final double left;
  final double top;
  final num pulse;
  final num size;
  EntityPosition({this.entity, this.left, this.top, this.pulse, this.size});
  factory EntityPosition.fromJson(
    dynamic parsedJson, {
    @required List<Flora> floraList,
    @required List<Fauna> faunaList,
  }) {
    final name = parsedJson['params']['name'];
    final id = int.tryParse(name.split('-').last);
    Entity entity;
    if (name.startsWith('flora')) {
      entity = floraList.firstWhere((flora) {
        return flora.id == id;
      }, orElse: () => null);
    } else if (name.startsWith('fauna')) {
      entity = faunaList.firstWhere((fauna) {
        return fauna.id == id;
      }, orElse: () => null);
    }
    return EntityPosition(
      entity: entity,
      left: parsedJson['left'],
      top: parsedJson['top'],
      pulse: parsedJson['pulse'],
      size: parsedJson['size'],
    );
  }
}

class AppNotifier extends ChangeNotifier {
  Animation<double> animation;

  int state = 0;
  // 0: entity list
  // 1: details page for one entity
  Entity entity;
  bool sheetMinimised = true;

  // void updateBackupLists(List<Flora> floraList, List<Fauna> faunaList) {
  //   _backupFloraList = floraList;
  //   _backupFaunaList = faunaList;
  //   if (_floraList.isEmpty) notifyListeners();
  // }

  // void updateLists(List<Flora> floraList, List<Fauna> faunaList) {
  //   updateBackupLists(floraList, faunaList);
  //   _floraList = floraList;
  //   _faunaList = faunaList;
  //   notifyListeners();
  // }

  void updateState(int newState, Entity newEntity) {
    state = newState;
    entity = newEntity;
    notifyListeners();
  }
}

class SearchNotifier extends ChangeNotifier {
  bool _isSearching = false;
  bool get isSearching => _isSearching;
  set isSearching(bool isSearching) {
    if (isSearching == _isSearching) return;
    _isSearching = isSearching;
    notifyListeners();
  }

  String _searchTerm = '';
  String get searchTerm => _searchTerm;
  set searchTerm(String searchTerm) {
    _searchTerm = searchTerm;
    notifyListeners();
  }

  FocusNode focusNode;

  bool _keyboardAppear = false;
  bool get keyboardAppear => _keyboardAppear;
  set keyboardAppear(bool keyboardAppear) {
    if (_keyboardAppear == keyboardAppear) return;
    _keyboardAppear = keyboardAppear;
    if (focusNode == null) return;
    if (keyboardAppear)
      focusNode.requestFocus();
    else
      focusNode.unfocus();
    notifyListeners();
  }

  void keyboardAppearFromFocus() {
    _keyboardAppear = focusNode.hasFocus;
  }
}
