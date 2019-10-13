import 'package:flutter/widgets.dart';

// TODO: Edit this to contain more information about each Entity in Firebase Database
abstract class Entity {
  final String name;
  final String sciName;
  final String description;
  final String smallImage;
  final List<String> images;
  const Entity({this.name, this.sciName, this.description, this.smallImage, this.images});
  Entity.fromJson(Map<String, dynamic> parsedJson)
      : this(
          name: parsedJson['name'],
          sciName: parsedJson['sciName'],
          description: parsedJson['description'],
          smallImage: parsedJson['smallImage'],
          images: List<String>.from(parsedJson['imageRef']),
        );
}

class Fauna extends Entity {
  Fauna.fromJson(Map<String, dynamic> parsedJson) : super.fromJson(parsedJson);
}

class Flora extends Entity {
  Flora.fromJson(Map<String, dynamic> parsedJson) : super.fromJson(parsedJson);
}

class AppNotifier extends ChangeNotifier {
  List<Flora> floraList = [];
  List<Fauna> faunaList = [];
  int state = 0;
  // 0: entity list
  // 1: details page for one entity
  Entity entity;
  bool sheetMinimised = true;

  void updateLists(List<Flora> _floraList, List<Fauna> _faunaList) {
    floraList = _floraList;
    faunaList = _faunaList;
    notifyListeners();
  }

  void updateState(int newState, Entity newEntity) {
    state = newState;
    entity = newEntity;
    notifyListeners();
  }
}
