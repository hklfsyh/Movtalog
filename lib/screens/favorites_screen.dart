import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:movtalog/models/movie.dart';
import 'package:movtalog/screens/movie_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<Movie> favoriteMovies = [];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();

    List<Movie> loadedMovies = [];

    for (String key in keys) {
      if (key.startsWith('favorite_')) {
        final movieDetails = prefs.getStringList(key);
        if (movieDetails != null && movieDetails.length >= 6) {
          try {
            int movieId = int.tryParse(movieDetails[0]) ?? -1;
            if (movieId != -1) {
              loadedMovies.add(
                Movie(
                  id: movieId,
                  title: movieDetails[1],
                  overview: movieDetails[2],
                  posterPath: movieDetails[3],
                  releaseDate: movieDetails[4],
                  rating: double.tryParse(movieDetails[5]) ?? 0.0,
                ),
              );
            }
          } catch (e) {
            print('Error parsing movie: $e');
          }
        }
      }
    }

    setState(() {
      favoriteMovies = loadedMovies;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Favorites list refreshed!'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadFavorites,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: favoriteMovies.length,
        itemBuilder: (context, index) {
          final movie = favoriteMovies[index];
          return ListTile(
            leading: Image.network(movie.posterPath),
            title: Text(movie.title),
            subtitle: Text('Rating: ${movie.rating}'),
            onTap: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      MovieDetailScreen(movie: movie),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    return FadeTransition(
                      opacity: animation,
                      child: child,
                    );
                  },
                  transitionDuration: const Duration(milliseconds: 500),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
