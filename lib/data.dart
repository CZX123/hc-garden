import 'library.dart';

abstract class Entity {
  final String id;
  final String name;
  final String sciName;
  final String description;
  final String smallImage;
  final List<String> images;
  final LatLng coordinates;
  final List<TrailLocation> locations;
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
          id: key,
          name: parsedJson['name'],
          sciName: parsedJson['sciName'],
          description: parsedJson['description'],
          smallImage: parsedJson['smallImage'],
          images: List<String>.from(parsedJson['imageRef']),
          coordinates: parsedJson.containsKey('latitude')
              ? LatLng(parsedJson['latitude'], parsedJson['longitude'])
              : null,
          locations: List<String>.from(parsedJson['locations'].split(','))
              .map((value) {
            final split = value.split('/');
            return TrailLocation(
              trail: split[0],
              // todo
            );
          }).toList(),
          area: parsedJson.containsKey('area')
              ? List.from(parsedJson['area'])
                  .map((position) {
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
  Fauna.fromJson(String key, dynamic parsedJson, [int id]) : super.fromJson(key, parsedJson);
}

class Flora extends Entity {
  Flora.fromJson(String key, dynamic parsedJson, [int id]) : super.fromJson(key, parsedJson);
}

// A TrailLocation is a point on the trail
class TrailLocation {
  final String trail;
  final String name;
  final String image;
  final String smallImage;
  final LatLng coordinates;
  final List<EntityPosition> entityPositions;
  TrailLocation({
    this.trail,
    this.name,
    this.image,
    this.smallImage,
    this.coordinates,
    this.entityPositions,
  });
}

class EntityPosition {
  final Entity entity;
  final double left;
  final double top;
  final num pulse;
  final num size;
  EntityPosition({this.entity, this.left, this.top, this.pulse, this.size});
}

class AppNotifier extends ChangeNotifier {
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
  int state = 0;
  // 0: entity list
  // 1: details page for one entity
  Entity entity;
  bool _isSearching = false;
  bool get isSearching => _isSearching;
  set isSearching(bool isSearching) {
    if (isSearching == false) _searchTerm = '';
    _isSearching = isSearching;
    notifyListeners();
  }

  String _searchTerm = '';
  String get searchTerm => _searchTerm;
  set searchTerm(String searchTerm) {
    _searchTerm = searchTerm;
    notifyListeners();
  }

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

// TODO
class SearchNotifier extends ChangeNotifier {
  bool _isSearching = false;
  bool get isSearching => _isSearching;
  set isSearching(bool isSearching) {
    if (isSearching == false) _searchTerm = '';
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
    _keyboardAppear = keyboardAppear;
    if (focusNode == null) return;
    if (keyboardAppear) focusNode.requestFocus();
    else focusNode.unfocus();
    notifyListeners();
  }

}
