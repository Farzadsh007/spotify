import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:spotify/api/api_client.dart';
import 'package:spotify/utils/search_type.dart';

import 'api_client_test.mocks.dart';



@GenerateMocks([Dio])
void main() {
  late ApiClient apiClient;
  late MockDio mockDio;

  setUp(() {
    mockDio = MockDio();
    apiClient = ApiClient(dio: mockDio);
  });

  group('ApiClient - getAccessToken', () {
    test('returns access token on successful request', () async {
      const accessToken = 'test_access_token';
      when(mockDio.post(any,
          options: anyNamed('options'),
          data: anyNamed('data')))
          .thenAnswer((_) async =>
          Response(
            data: {'access_token': accessToken},
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ));

      final token = await apiClient.getAccessToken();

      expect(token, accessToken);
      verify(mockDio.post(any,
          options: anyNamed('options'),
          data: anyNamed('data'))).called(1);
    });

    test('throws exception on error', () async {
      when(mockDio.post(any,
          options: anyNamed('options'),
          data: anyNamed('data')))
          .thenAnswer((_) async => Response(
        data: {'error': 'invalid_client'},
        statusCode: 400,
        requestOptions: RequestOptions(path: ''),
      ));

      expect(() => apiClient.getAccessToken(), throwsA(isA<DioException>()));
    });

    });


  group('ApiClient - search', () {

    test('retries with new token on 401 error', () async {
      const oldToken = 'old_token';
      const newToken = 'new_token';
      const query = 'test_query';
      const type = SearchType.album;
      const currentPage = 0;
      final mockResponse = {
        'albums': {
          'items': [
            {'name': 'Rihana'},
          ]
        }
      };
      final cancelToken = CancelToken();
      // Mock the initial request to return a 401
      when(mockDio.get(any, queryParameters: anyNamed('queryParameters'), options: argThat(
        predicate<Options>((opts) =>
        opts.headers?['Authorization'] == 'Bearer $oldToken'
        ),
        named: 'options',
      ),cancelToken: anyNamed('cancelToken'),))
          .thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ''),
          response: Response(
            data: {'error': 'Unauthorized'},
            statusCode: 401,
            requestOptions: RequestOptions(path: ''),
          ),
        ),
      );

      // Mock the token refresh request
      when(mockDio.post(any, options: anyNamed('options'), data: anyNamed('data')))
          .thenAnswer((_) async => Response(
        data: {'access_token': newToken},
        statusCode: 200,
        requestOptions: RequestOptions(path: ''),
      ));

      // Mock the successful request *after* token refresh
      when(mockDio.get(any, queryParameters: anyNamed('queryParameters'), options: argThat(
        predicate<Options>((opts) =>
        opts.headers?['Authorization'] == 'Bearer $newToken'
        ),
        named: 'options',
      ), cancelToken: anyNamed('cancelToken'),))
          .thenAnswer((_) async => Response(
        data: mockResponse,
        statusCode: 200,
        requestOptions: RequestOptions(path: ''),
      ));

      final results = await apiClient.search(query, type, oldToken,cancelToken, currentPage);

      expect(results.isNotEmpty, true);
      verify(mockDio.get(any, queryParameters: anyNamed('queryParameters'), options: anyNamed('options'), cancelToken: anyNamed('cancelToken'))).called(2); // Called twice (initial and retry)
      verify(mockDio.post(any, options: anyNamed('options'), data: anyNamed('data'))).called(1); // getAccessToken called
    });




  });


}