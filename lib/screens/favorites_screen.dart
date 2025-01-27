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
    setState(() {
      final keys = prefs.getKeys();
      favoriteMovies =
          keys.where((key) => key.startsWith('favorite_')).map((key) {
        final movieDetails = prefs.getStringList(key);
        return Movie(
          title: movieDetails![0],
          overview: movieDetails[1],
          posterPath: movieDetails[2],
          releaseDate: movieDetails[3],
          rating: double.parse(movieDetails[4]),
        );
      }).toList();
    });

    // Tampilkan SnackBar sebagai feedback
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
                MaterialPageRoute(
                  builder: (context) => MovieDetailScreen(movie: movie),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
