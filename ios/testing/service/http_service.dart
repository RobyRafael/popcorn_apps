import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movie.dart';

class HttpService {
  final String apiKey = 'fea44667a60541a443d2262fc3276bf4';
  final String baseUrl = 'https://api.themoviedb.org/3/movie';

  Future<List<Movie>> fetchPopularMovies() async {
    final response = await http.get(Uri.parse('$baseUrl/popular?api_key=$apiKey'));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final List moviesJson = json['results'];
      return moviesJson.map((json) => Movie.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load movies');
    }
  }
}
