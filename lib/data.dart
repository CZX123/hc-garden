import 'library.dart';

abstract class Entity {
  final int id;
  final String name;
  final String sciName;
  final String description;
  final String smallImage;
  final List<String> images;
  final LatLng coordinates;
  final List<Map<int, int>> locations;
  final List<LatLng> area;
  const Entity({
    this.id,
    this.name,
    this.sciName,
    this.description,
    this.smallImage,
    this.images,
    this.coordinates,
    this.locations,
    this.area,
  });
  Entity.fromJson(String key, dynamic parsedJson, [int id])
      : this(
          id: int.parse(key.split('-').last),
          name: parsedJson['name'],
          sciName: parsedJson['sciName'],
          description: parsedJson['description'],
          smallImage: parsedJson['smallImage'],
          images: List<String>.from(parsedJson['imageRef']),
          coordinates: parsedJson.containsKey('latitude')
              ? LatLng(parsedJson['latitude'], parsedJson['longitude'])
              : null,
          locations: List.from(parsedJson['locations'].split(',')).where((value) {
            return value != null && value.isNotEmpty;
          }).map((value) {
            final split = value.split('/');
            return {
              int.tryParse(split.first.split('-').last):
                  int.tryParse(split.last.split('-').last)
            };
          }).toList(),
          // locations: List<String>.from(parsedJson['locations'].split(','))
          //     .map((value) {
          //   final split = value.split('/');
          //   return TrailLocation(
          //       //trailId: int.parse(split.first.split('-').last),
          //       id: int.parse(split.last.split('-').last)
          //       // todo
          //       );
          // }).toList(),
          area: parsedJson.containsKey('area')
              ? List.from(parsedJson['area']).map((position) {
                  return LatLng(position['latitude'], position['longitude']);
                }).toList()
              : null,
        );

  @override
  String toString() {
    return 'Entity(name: $name, sciName: $sciName)';
  }
}

class Fauna extends Entity {
  Fauna.fromJson(String key, dynamic parsedJson, [int id])
      : super.fromJson(key, parsedJson);
}

class Flora extends Entity {
  Flora.fromJson(String key, dynamic parsedJson, [int id])
      : super.fromJson(key, parsedJson);
}

class Trail {
  final int id;
  final String name;
  final String color;
  Trail({this.id, this.name, this.color});
  factory Trail.fromJson(String key, Map<String, dynamic> parsedJson) {
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
    Map<String, dynamic> parsedJson, {
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
    Map<String, dynamic> parsedJson, {
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
  List<Flora> _backupFloraList = [];
  List<Fauna> _backupFaunaList = [];
  List<Flora> _floraList = [];
  List<Flora> get floraList {
    return _floraList.isEmpty ? _backupFloraList : _floraList;
  }
  List<Fauna> _faunaList = [];
  List<Fauna> get faunaList {
    return _faunaList.isEmpty ? _backupFaunaList : _faunaList;
  }
  Map<Trail, List<TrailLocation>> _trails;
  Map<Trail, List<TrailLocation>> get trails => _trails;
  set trails(Map<Trail, List<TrailLocation>> trails) {
    _trails = trails;
    notifyListeners();
  }

  int state = 0;
  // 0: entity list
  // 1: details page for one entity
  Entity entity;
  bool sheetMinimised = true;

  void updateBackupLists(List<Flora> floraList, List<Fauna> faunaList) {
    _backupFloraList = floraList;
    _backupFaunaList = faunaList;
    if (_floraList.isEmpty) notifyListeners();
  }

  void updateLists(List<Flora> floraList, List<Fauna> faunaList) {
    updateBackupLists(floraList, faunaList);
    _floraList = floraList;
    _faunaList = faunaList;
    notifyListeners();
  }

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
