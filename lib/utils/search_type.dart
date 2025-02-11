enum SearchType {
  album,
  artist,
}

extension SearchTypeExtension on SearchType {
  String get value {
    switch (this) {
      case SearchType.album:
        return 'album';
      case SearchType.artist:
        return 'artist';
    }
  }
}
