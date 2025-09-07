class App {
  final int? id;
  final int sourceId;
  final String name;
  final String bundleIdentifier;
  final String version;
  final String versionDate;
  final String downloadURL;
  final String localizedDescription;
  final String iconURL;
  final int size;

  App({
    this.id,
    required this.sourceId,
    required this.name,
    required this.bundleIdentifier,
    required this.version,
    required this.versionDate,
    required this.downloadURL,
    required this.localizedDescription,
    required this.iconURL,
    required this.size,
  });

  factory App.fromMap(Map<String, dynamic> map) {
    return App(
      id: map['id'],
      sourceId: map['source_id'],
      name: map['name'],
      bundleIdentifier: map['bundleIdentifier'],
      version: map['version'],
      versionDate: map['versionDate'],
      downloadURL: map['downloadURL'],
      localizedDescription: map['localizedDescription'],
      iconURL: map['iconURL'],
      size: map['size'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'source_id': sourceId,
      'name': name,
      'bundleIdentifier': bundleIdentifier,
      'version': version,
      'versionDate': versionDate,
      'downloadURL': downloadURL,
      'localizedDescription': localizedDescription,
      'iconURL': iconURL,
      'size': size,
    };
  }
}

class AppWithSourceIcon extends App {
  final String sourceIconURL;

  AppWithSourceIcon({
    super.id,
    required super.sourceId,
    required super.name,
    required super.bundleIdentifier,
    required super.version,
    required super.versionDate,
    required super.downloadURL,
    required super.localizedDescription,
    required super.iconURL,
    required super.size,
    required this.sourceIconURL,
  });

  factory AppWithSourceIcon.fromMap(Map<String, dynamic> map) {
    return AppWithSourceIcon(
      id: map['id'],
      sourceId: map['source_id'],
      name: map['name'],
      bundleIdentifier: map['bundleIdentifier'],
      version: map['version'],
      versionDate: map['versionDate'],
      downloadURL: map['downloadURL'],
      localizedDescription: map['localizedDescription'],
      iconURL: map['iconURL'],
      size: map['size'],
      sourceIconURL: map['sourceIconURL'] ?? '',
    );
  }
}
