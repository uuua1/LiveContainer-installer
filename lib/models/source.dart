class Source {
  final int? id;
  final String name;
  final String identifier;
  final String subtitle;
  final String sourceURL;
  final String iconURL;
  final String website;
  final String? description;
  final String? tintColor;

  Source({
    this.id,
    required this.name,
    required this.identifier,
    required this.subtitle,
    required this.sourceURL,
    required this.iconURL,
    required this.website,
    this.description,
    this.tintColor,
  });

  factory Source.fromMap(Map<String, dynamic> map) {
    return Source(
      id: map['id'],
      name: map['name'],
      identifier: map['identifier'],
      subtitle: map['subtitle'],
      sourceURL: map['sourceURL'],
      iconURL: map['iconURL'],
      website: map['website'],
      description: map['description'],
      tintColor: map['tintColor'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'identifier': identifier,
      'subtitle': subtitle,
      'sourceURL': sourceURL,
      'iconURL': iconURL,
      'website': website,
      'description': description,
      'tintColor': tintColor,
    };
  }
}
