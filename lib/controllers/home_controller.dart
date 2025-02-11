import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../api/api_client.dart';
import '../models/album.dart';
import '../models/artist.dart';
import '../utils/search_type.dart';

class HomeController extends GetxController {
  var _query = '';
  var isLoading = false.obs;
  var albumSearchResults = <Album>[].obs;
  var artistSearchResults = <Artist>[].obs;
  var searchType = SearchType.album.obs;
  late ApiClient apiClient;
  late String accessToken;

  var artistScrollController = ScrollController();
  var albumScrollController = ScrollController();
  int _artistPage = 0;
  int _albumPage = 0;
  bool _canLoadMoreArtist = true;
  bool _canLoadMoreAlbum = true;
  CancelToken? _cancelToken;

  @override
  Future<void> onInit() async {
    super.onInit();
    apiClient = Get.find<ApiClient>();
    accessToken = await apiClient.getAccessToken();
    artistScrollController.addListener(_artistScrollListener);
    albumScrollController.addListener(_albumScrollListener);
  }

  @override
  void dispose() {
    artistScrollController.removeListener(_artistScrollListener);
    artistScrollController.dispose();
    albumScrollController.removeListener(_albumScrollListener);
    albumScrollController.dispose();
    super.dispose();
  }

  void scrollToTop() {
    artistScrollController.animateTo(
      0.0,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );

    albumScrollController.animateTo(
      0.0,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  Future<void> _artistScrollListener() async {
    if (!_canLoadMoreArtist) return;
    if (artistScrollController.position.atEdge) {
      if (artistScrollController.position.pixels > 0) {
        _artistPage++;

        var artistResults = await fetchResults(SearchType.artist, _cancelToken!,
            currentPage: _artistPage);

        artistSearchResults.addAll(artistResults as Iterable<Artist>);
        update();
      }
    }
  }

  Future<void> _albumScrollListener() async {
    if (!_canLoadMoreAlbum) return;
    if (albumScrollController.position.atEdge) {
      if (albumScrollController.position.pixels > 0) {
        _albumPage++;
        var albumResults = await fetchResults(SearchType.album, _cancelToken!,
            currentPage: _albumPage);

        albumSearchResults.addAll(albumResults as Iterable<Album>);
      }
    }
  }

  void search(String query) async {
    _artistPage = 0;
    _albumPage = 0;
    _canLoadMoreArtist = true;
    _canLoadMoreAlbum = true;
    _query = query.trim();

    _cancelToken?.cancel("New search started!");
    _cancelToken = CancelToken();

    if (_query.isEmpty) {
      albumSearchResults.assignAll([]);
      artistSearchResults.assignAll([]);
    } else {
      var albumResults = await fetchResults(SearchType.album, _cancelToken!);
      var artistResults = await fetchResults(SearchType.artist, _cancelToken!);
      scrollToTop();

      albumSearchResults.assignAll(albumResults as Iterable<Album>);

      artistSearchResults.assignAll(artistResults as Iterable<Artist>);
    }
  }

  Future<List<dynamic>> fetchResults(
      SearchType searchType, CancelToken cancelToken,
      {currentPage = 0}) async {
    if (_query.isEmpty) return [];
    isLoading.value = true;
    var ret = [];
    try {
      var results = await apiClient.search(
          _query, searchType, accessToken, cancelToken, currentPage);

      switch (searchType) {
        case SearchType.album:
          if (results.isEmpty) {
            _canLoadMoreAlbum = false;
            ret = [];
          } else {
            ret = results.map((item) => Album.fromJson(item)).toList();
          }

        case SearchType.artist:
          if (results.isEmpty) {
            _canLoadMoreArtist = false;
            ret = [];
          } else {
            ret = results.map((item) => Artist.fromJson(item)).toList();
          }
      }
    } catch (e) {
      debugPrint('Error searching: $e');
    } finally {
      isLoading.value = false;
    }
    return ret;
  }
}
