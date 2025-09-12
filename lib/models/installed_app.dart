class InstalledApp {
  final int? id;
  final int sourceId;
  final String name;
  final String bundleIdentifier;
  final String iconURL;
  final String version;
  final String versionDate;

  InstalledApp({
    this.id,
    required this.sourceId,
    required this.name,
    required this.bundleIdentifier,
    required this.iconURL,
    required this.version,
    required this.versionDate,
  });

  factory InstalledApp.fromMap(Map<String, dynamic> map) {
    return InstalledApp(
      id: map['id'],
      sourceId: map['sourceId'],
      name: map['name'],
      bundleIdentifier: map['bundleIdentifier'],
      iconURL: map['iconURL'],
      version: map['version'],
      versionDate: map['versionDate'],
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sourceId': sourceId,
      'name': name,
      'bundleIdentifier': bundleIdentifier,
      'iconURL': iconURL,
      'version': version,
      'versionDate': versionDate,
    };
  }
}
