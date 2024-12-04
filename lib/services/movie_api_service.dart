import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:popcorn_apps/models/movie.dart';

class MovieApiService {
  static const _baseUrl = 'https://api.themoviedb.org/3';
  static const _apiKey = 'fea44667a60541a443d2262fc3276bf4';

  Future<Map<String, dynamic>> getMovies({
    required int page,
    String? category = 'popular',
  }) async {
    final url =
        Uri.parse('$_baseUrl/movie/$category').replace(queryParameters: {
      'api_key': _apiKey,
      'page': page.toString(),
    });
    print('Fetching movies from URL: $url'); // Debugging
    final response = await http.get(url);
    print('Response status: ${response.statusCode}'); // Debugging
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final movies = (data['results'] as List)
          .map((json) => Movie.fromJson(json))
          .toList();
      print('Number of movies fetched: ${movies.length}'); // Debugging
      return {'movies': movies, 'totalPages': data['total_pages']};
    } else {
      print('Failed to load movies: ${response.body}'); // Debugging
      throw Exception('Failed to load movies');
    }
  }

  Future<Map<String, dynamic>> searchMovies({
    required int page,
    required String query,
  }) async {
    final url = Uri.parse('$_baseUrl/search/movie').replace(queryParameters: {
      'api_key': _apiKey,
      'page': page.toString(),
      'query': query,
    });
    print('Searching movies with URL: $url'); // Debugging
    final response = await http.get(url);
    print('Response status: ${response.statusCode}'); // Debugging
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final movies = (data['results'] as List)
          .map((json) => Movie.fromJson(json))
          .toList();
      print('Number of search results: ${movies.length}'); // Debugging
      return {'movies': movies, 'totalPages': data['total_pages']};
    } else {
      print('Failed to search movies: ${response.body}'); // Debugging
      throw Exception('Failed to search movies');
    }
  }
}
