class App {
  final int sourceId;
  final String name;
  final String bundleIdentifier;
  final String developerName;
  final String subTitle;
  final List<Versions> versions;
  final String localizedDescription;
  final String iconURL;
  final String tintColor;
  final List<Screenshots> screenshots;

  App({
    required this.sourceId,
    required this.name,
    required this.bundleIdentifier,
    this.developerName = '',
    this.subTitle = '',
    this.versions = const [],
    required this.localizedDescription,
    required this.iconURL,
    this.tintColor = '',
    this.screenshots = const [],
  });

  factory App.fromMap(Map<String, dynamic> map) {
    return App(
      sourceId: map['source_id'],
      name: map['name'],
      bundleIdentifier: map['bundleIdentifier'],
      developerName: map['developerName'] ?? '',
      subTitle: map['subTitle'] ?? '',
      versions: map['versions'] != null
          ? List<Versions>.from(
              (map['versions'] as List).map((x) => Versions.fromMap(x)),
            )
          : [],
      localizedDescription: map['localizedDescription'],
      iconURL: map['iconURL'],
      tintColor: map['tintColor'] ?? '',
      screenshots: map['screenshots'] != null
          ? List<Screenshots>.from(
              (map['screenshots'] as List).map((x) => Screenshots.fromMap(x)),
            )
          : [],
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'source_id': sourceId,
      'name': name,
      'bundleIdentifier': bundleIdentifier,
      'developerName': developerName,
      'subTitle': subTitle,
      'versions': versions.map((x) => x.toMap()).toList(),
      'localizedDescription': localizedDescription,
      'iconURL': iconURL,
      'tintColor': tintColor,
      'screenshots': screenshots.map((x) => x.toMap()).toList(),
    };
  }
}

class Versions {
  final String version;
  final String date;
  final int size;
  final String downloadURL;
  final String localizedDescription;

  Versions({
    required this.version,
    required this.date,
    required this.size,
    required this.downloadURL,
    required this.localizedDescription,
  });

  factory Versions.fromMap(Map<String, dynamic> map) {
    return Versions(
      version: map['version'],
      date: map['date'],
      size: map['size'],
      downloadURL: map['downloadURL'],
      localizedDescription: map['localizedDescription'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'version': version,
      'date': date,
      'size': size,
      'downloadURL': downloadURL,
      'localizedDescription': localizedDescription,
    };
  }
}

class Screenshots {
  final String imageURL;
  final String height;
  final String width;

  Screenshots({required this.imageURL, this.height = '0', this.width = '0'});

  factory Screenshots.fromMap(dynamic map) {
    if (map is String) {
      return Screenshots(imageURL: map, height: '0', width: '0');
    } else if (map is Map<String, dynamic>) {
      return Screenshots(
        imageURL: map['imageURL'] ?? '',
        height: '${map['height'] ?? 0}',
        width: '${map['width'] ?? 0}',
      );
    } else {
      return Screenshots(imageURL: '', height: '0', width: '0');
    }
  }

  Map<String, dynamic> toMap() {
    return {'imageURL': imageURL, 'height': height, 'width': width};
  }
}

class AppWithSourceIcon extends App {
  final String sourceIconURL;

  AppWithSourceIcon({
    required super.sourceId,
    required super.name,
    required super.bundleIdentifier,
    required super.versions,
    required super.localizedDescription,
    required super.iconURL,
    required this.sourceIconURL,
    super.developerName,
    super.subTitle,
    super.tintColor,
    super.screenshots,
  });

  factory AppWithSourceIcon.fromMap(Map<String, dynamic> map) {
    return AppWithSourceIcon(
      sourceId: map['source_id'],
      name: map['name'],
      bundleIdentifier: map['bundleIdentifier'],
      developerName: map['developerName'] ?? '',
      subTitle: map['subTitle'] ?? '',
      versions: map['versions'] != null
          ? List<Versions>.from(
              (map['versions'] as List).map((x) => Versions.fromMap(x)),
            )
          : [],
      localizedDescription: map['localizedDescription'],
      iconURL: map['iconURL'],
      tintColor: map['tintColor'] ?? '',
      screenshots: map['screenshots'] != null
          ? List<Screenshots>.from(
              (map['screenshots'] as List).map((x) => Screenshots.fromMap(x)),
            )
          : [],
      sourceIconURL: map['sourceIconURL'],
    );
  }

  Versions get latestVersion {
    if (versions.isEmpty) {
      return Versions(
        version: 'N/A',
        date: 'N/A',
        size: 0,
        downloadURL: '',
        localizedDescription: 'No versions available',
      );
    }
    versions.sort((a, b) => b.date.compareTo(a.date));
    return versions.first;
  }
}
