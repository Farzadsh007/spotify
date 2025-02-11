class Artist {
  final String name;
  final String imageUrl;

  Artist({required this.name, required this.imageUrl});

  factory Artist.fromJson(Map<String, dynamic> json) {
    return Artist(
      name: json['name'] ?? 'Unknown',
      imageUrl: json['images'] != null && json['images'].isNotEmpty
          ? json['images'][0]['url']
          : '',
    );
  }
}
