import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:movtalog/models/movie.dart';

class ApiService {
  static const String apiKey = 'e87581e253265a2d97ea07722d4afe2b';
  static const String baseUrl = 'https://api.themoviedb.org/3';

  Future<List<Movie>> fetchPopularMovies() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/movie/popular?api_key=$apiKey'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> results = data['results'];

        return results.map((json) => Movie.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load movies');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Failed to load movies');
    }
  }

  Future<List<Movie>> searchMovies(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/search/movie?api_key=$apiKey&query=$query'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> results = data['results'];

        return results.map((json) => Movie.fromJson(json)).toList();
      } else {
        throw Exception('Failed to search movies');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Failed to search movies');
    }
  }

  Future<String?> fetchMovieTrailer(int movieId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/movie/$movieId/videos?api_key=$apiKey'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> results = data['results'];

        if (results.isNotEmpty) {
          final trailer = results.firstWhere(
            (video) => video['type'] == 'Trailer' && video['site'] == 'YouTube',
            orElse: () => null,
          );
          return trailer != null ? trailer['key'] : null;
        }
      }
    } catch (e) {
      print('Error fetching trailer: $e');
    }
    return null;
  }
}
