import 'package:hc_garden/src/library.dart';

/// An [Entity] refers to any flora or fauna, and fauna may include any birds, butterflies, etc.
///
/// Implmenting [Comparable] allows [Entities]s in a list to be sorted without a
/// comparator function, i.e. the `sort()` function can be used without arguments.
class Entity implements Comparable {
  final EntityKey key;
  final String name;
  final String sciName;
  final String description;
  final String smallImage;
  final List<String> images;
  final List<EntityLocation> locations;

  const Entity({
    this.key,
    this.name,
    this.sciName,
    this.description,
    this.smallImage,
    this.images,
    this.locations,
  });

  factory Entity.fromJson({
    @required String category,
    @required int id,
    @required dynamic data,
  }) {
    final images = List<String>.from(data['imageRef']);
    List<EntityLocation> locations;

    /// `data['locations']` is in the format of `"trail-01/route-09,trail-02/route-06"`.
    if (data.containsKey('locations')) {
      final List<String> strings = data['locations'].split(',');
      // There may be trailing commas, so need to filter out invalid values.
      strings.removeWhere((value) => value == null || value.isEmpty);
      locations = [];
      strings.forEach((value) {
        final split = value.split('/');
        final trailKey = TrailKey(
          id: int.tryParse(split.first.split('-').last),
        );
        final location = EntityLocation(
          trailLocationKey: TrailLocationKey(
            trailKey: trailKey,
            id: int.tryParse(split.last.split('-').last),
          ),
        );
        if (location.isValid) locations.add(location);
      });
    }

    return Entity(
      key: EntityKey(category: category, id: id),
      name: data['name'],
      sciName: data['sciName'],
      description: data['description'],
      smallImage: data['smallImage'],
      images: images,
      locations: locations,
    );
  }

  /// Returns whether the [Entity] satisfies the `searchTerm`
  bool satisfies(String searchTerm) {
    if (searchTerm.isEmpty || searchTerm == '*') return true;
    return !name.split(' ').every((name) {
          return !name.toLowerCase().startsWith(searchTerm.toLowerCase());
        }) ||
        !sciName.split(' ').every((name) {
          return !name.toLowerCase().startsWith(searchTerm.toLowerCase());
        });
  }

  bool get isValid {
    return key.isValid &&
        name != null &&
        sciName != null &&
        description != null &&
        smallImage != null &&
        images != null &&
        locations != null;
  }

  @override
  int compareTo(other) {
    final Entity typedOther = other;
    return name.compareTo(typedOther.name);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is Entity &&
            key == other.key &&
            name == other.name &&
            sciName == other.sciName &&
            description == other.description &&
            smallImage == other.smallImage &&
            listEquals(images, other.images) &&
            listEquals(locations, other.locations);
  }

  @override
  int get hashCode {
    return hashValues(
      key,
      name,
      sciName,
      description,
      smallImage,
      hashList(images),
      hashList(locations),
    );
  }

  @override
  String toString() {
    return 'Entity(category: ${key.category}, id: ${key.id}, name: $name)';
  }
}

/// Used in [Entity], since each [Entity] can be at multiple [TrailLocation]s.
/// This only serves as a wrapper for [TrailLocationKey].
class EntityLocation {
  final TrailLocationKey trailLocationKey;
  const EntityLocation({@required this.trailLocationKey});

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is EntityLocation && trailLocationKey == other.trailLocationKey;
  }

  @override
  int get hashCode => trailLocationKey.hashCode;

  bool get isValid {
    return trailLocationKey.isValid;
  }
}

/// A [TrailLocation] is a point on the trail
class TrailLocation {
  final TrailLocationKey key;
  final String name;
  final String image;
  final String smallImage;
  final LatLng coordinates;
  final List<EntityPosition> entityPositions;
  const TrailLocation({
    this.key,
    this.name,
    this.image,
    this.smallImage,
    this.coordinates,
    this.entityPositions,
  });
  factory TrailLocation.fromJson({
    @required TrailLocationKey key,
    @required TrailKey trailKey,
    @required dynamic data,
  }) {
    List<EntityPosition> entityPositions;
    if (data.containsKey('points')) {
      entityPositions = [];
      for (dynamic point in data['points']) {
        final entityPosition = EntityPosition.fromJson(point);
        if (entityPosition.isValid) entityPositions.add(entityPosition);
      }
      entityPositions.sort((a, b) => a.left.compareTo(b.left));
    }
    return TrailLocation(
      key: key,
      name: data['title'],
      image: data['imageRef'],
      smallImage: data['smallImage'],
      coordinates: data.containsKey('latitude')
          ? LatLng(data['latitude'], data['longitude'])
          : null,
      entityPositions: entityPositions,
    );
  }

  bool get isValid {
    return key.isValid &&
        name != null &&
        image != null &&
        smallImage != null &&
        coordinates != null &&
        entityPositions != null;
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is TrailLocation &&
            key == other.key &&
            name == other.name &&
            image == other.image &&
            smallImage == other.smallImage &&
            coordinates == other.coordinates &&
            listEquals(entityPositions, other.entityPositions);
  }

  @override
  int get hashCode => hashValues(
        key,
        name,
        image,
        smallImage,
        coordinates,
        hashList(entityPositions),
      );
}

class EntityPosition {
  final EntityKey entityKey;
  final double left;
  final double top;
  final num size;
  const EntityPosition({
    this.entityKey,
    this.left,
    this.top,
    this.size,
  });

  factory EntityPosition.fromJson(dynamic data) {
    return EntityPosition(
      entityKey: EntityKey(
        category: data['params']['category'],
        id: data['params']['id'],
      ),
      left: data['left'],
      top: data['top'],
      size: data['size'],
    );
  }

  bool get isValid {
    return entityKey.isValid && left != null && top != null && size != null;
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is EntityPosition &&
            entityKey == other.entityKey &&
            left == other.left &&
            top == other.top &&
            size == other.size;
  }

  @override
  int get hashCode => hashValues(entityKey, left, top, size);
}

class HistoricalData {
  final int id;
  final String description;
  final String image;
  final String newImage;
  final String name;
  final num height;
  final num width;

  const HistoricalData({
    this.id,
    this.description,
    this.image,
    this.newImage,
    this.name,
    this.height,
    this.width,
  });

  factory HistoricalData.fromJson(dynamic key, dynamic data) {
    return HistoricalData(
      id: key,
      description: data['description'],
      image: data['imageRef'],
      newImage: data['newImageRef'],
      name: data['name'],
      height: data['height'],
      width: data['width'],
    );
  }

  bool get isValid {
    return id != null &&
        description != null &&
        image != null &&
        newImage != null &&
        name != null &&
        height != null &&
        width != null;
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is HistoricalData &&
            id == other.id &&
            description == other.description &&
            image == other.image &&
            newImage == other.newImage &&
            name == other.name &&
            height == other.height &&
            width == other.width;
  }

  @override
  int get hashCode => hashValues(id, description, image, name, height, width);

  @override
  String toString() {
    return 'HistoricalData(id: $id, description: $description, imageURL: $image)';
  }
}

class AboutPageData {
  final String body;
  final List<AboutPageDropdown> dropdowns;
  final int id;
  final String quote;
  final String title;
  bool isExpanded = false;

  AboutPageData({
    this.body,
    this.dropdowns,
    this.id,
    this.quote,
    this.title,
    this.isExpanded,
  });

  factory AboutPageData.fromJson(int key, dynamic data) {
    return AboutPageData(
      body: data['body'],
      dropdowns: data['dropdowns'] != null
          ? List.from(data['dropdowns'])
              .map((data) {
                return AboutPageDropdown.fromJson(data);
              })
              .where((dropdown) => dropdown.isValid)
              .toList()
          : null,
      id: key,
      quote: data['quote'],
      title: data['title'],
      isExpanded: false,
    );
  }

  bool get isValid {
    return body != null && id != null && title != null;
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is AboutPageData &&
            body == other.body &&
            id == other.id &&
            quote == other.quote &&
            title == other.title &&
            isExpanded == other.isExpanded;
  }

  @override
  int get hashCode => hashValues(body, id, quote, title, isExpanded);
}

class AboutPageDropdown {
  final String title;
  final String body;

  const AboutPageDropdown({this.title, this.body});

  factory AboutPageDropdown.fromJson(dynamic data) {
    return AboutPageDropdown(
      title: data['title'],
      body: data['body'],
    );
  }

  bool get isValid {
    return title != null && body != null;
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is AboutPageData && title == other.title && body == other.body;
  }

  @override
  int get hashCode => hashValues(title, body);
}
