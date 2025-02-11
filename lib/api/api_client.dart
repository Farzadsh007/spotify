import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../utils/app_strings.dart';
import '../utils/search_type.dart';

class ApiClient {
  final Dio _dio;

  ApiClient({Dio? dio})
      : _dio = dio ??
            Dio(
              // Allow passing a mock Dio
              BaseOptions(
                baseUrl: 'https://api.spotify.com/v1/',
                connectTimeout: Duration(seconds: 10),
                receiveTimeout: Duration(seconds: 10),
              ),
            );

  Future<String> getAccessToken() async {
    try {
      String clientId = '3af8e17840684c5bb3325a5e8b8e808d';
      String clientSecret = 'e46b037b7f76416ca7e3ac9676f557f7';
      final response = await _dio.post(
        'https://accounts.spotify.com/api/token',
        options: Options(headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization':
              'Basic ${base64Encode(utf8.encode('$clientId:$clientSecret'))}',
        }),
        data: {'grant_type': 'client_credentials'},
      );
      if (response.data == null || !response.data.containsKey('access_token')) {
        throw DioException(
            message: 'Invalid response: access_token not found',
            requestOptions: RequestOptions());
      }
      return response.data['access_token'];
    } on DioException catch (e) {
      debugPrint('Error getting access token: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('Other error: ${e.toString()}');
      rethrow;
    }
  }

  Future<List<dynamic>> search(String query, SearchType type, String token,
      CancelToken cancelToken, int currentPage) async {
    try {
      final response = await _dio.get(
        'search',
        queryParameters: {
          'q': query,
          'type': type.value,
          'limit': 20,
          'offset': currentPage * 20
        },
        options: Options(headers: {
          'Authorization': 'Bearer $token',
        }),
        cancelToken: cancelToken,
      );

      if (response.statusCode == 200) {
        var data = response.data;

        if (data == null || !data.containsKey('${type.value}s')) {
          debugPrint(AppStrings.noResultsFound);

          return [];
        }

        var items = data['${type.value}s']['items'];
        if (items == null || items.isEmpty) {
          debugPrint(AppStrings.noResultsFound);

          return [];
        }

        return items;
        //return response.data['${type.value}s']['items'];
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        debugPrint(AppStrings.tokenExpired);

        var newToken = await getAccessToken();
        return search(query, type, newToken, cancelToken,
            currentPage); // Retry after refreshing token
      } else {
        debugPrint('Server Error: ${e.message}');
        return [];
      }
    } catch (e) {
      debugPrint('${AppStrings.errorFetchingData} \n ${e.toString()}');
    }
    return [];
  }
}
