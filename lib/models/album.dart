class Album {
  final String name;
  final String imageUrl;
  final String artist;
  final String releaseDate;
  final String albumType;

  Album(
      {required this.name,
      required this.imageUrl,
      required this.artist,
      required this.releaseDate,
      required this.albumType});

  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
      name: json['name'] ?? 'Unknown',
      imageUrl: json['images'] != null && json['images'].isNotEmpty
          ? json['images'][0]['url']
          : '',
      artist: json['artists'] != null && json['artists'].isNotEmpty
          ? json['artists'][0]['name']
          : 'Unknown Artist',
      releaseDate: json['release_date'] ?? 'Unknown',
      albumType: json['album_type'] ?? '',
    );
  }

  String get albumTypeText {
    String year = releaseDate.isNotEmpty && releaseDate.length >= 4
        ? releaseDate.substring(0, 4)
        : 'Unknown';

    if (albumType.isNotEmpty) {
      return "${albumType.substring(0, 1).toUpperCase() + albumType.substring(1)} · $year";
    } else {
      return year;
    }
  }
}
