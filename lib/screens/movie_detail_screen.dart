import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:movtalog/models/movie.dart';
import 'package:movtalog/widgets/movie_detail_card.dart';
import 'package:movtalog/widgets/favorite_button.dart';
import 'package:movtalog/services/api_service.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class MovieDetailScreen extends StatefulWidget {
  final Movie movie;

  const MovieDetailScreen({super.key, required this.movie});

  @override
  _MovieDetailScreenState createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  bool isFavorite = false;
  String? trailerKey;

  @override
  void initState() {
    super.initState();
    _loadFavoriteStatus();
    _loadTrailer();
  }

  Future<void> _loadFavoriteStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isFavorite = prefs.getBool(widget.movie.title) ?? false;
    });
  }

  Future<void> _toggleFavorite() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isFavorite = !isFavorite;
      prefs.setBool(widget.movie.title, isFavorite);

      if (isFavorite) {
        prefs.setStringList(
          'favorite_${widget.movie.id}',
          [
            widget.movie.id.toString(),
            widget.movie.title,
            widget.movie.overview,
            widget.movie.posterPath,
            widget.movie.releaseDate,
            widget.movie.rating.toString(),
          ],
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.movie.title} added to favorites!'),
            duration: const Duration(seconds: 1),
          ),
        );
      } else {
        prefs.remove('favorite_${widget.movie.id}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.movie.title} removed from favorites!'),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    });
  }

  Future<void> _loadTrailer() async {
    String? key = await ApiService().fetchMovieTrailer(widget.movie.id);
    setState(() {
      trailerKey = key;
    });
  }

  void _showTrailerDialog() {
    if (trailerKey == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Trailer not available!')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: YoutubePlayerBuilder(
            player: YoutubePlayer(
              controller: YoutubePlayerController(
                initialVideoId: trailerKey!,
                flags: const YoutubePlayerFlags(autoPlay: true),
              ),
            ),
            builder: (context, player) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    child: player,
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.movie.title),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 600) {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            widget.movie.posterPath,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MovieDetailCard(movie: widget.movie),
                          const SizedBox(height: 16.0),
                          Card(
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                widget.movie.overview,
                                style: const TextStyle(
                                  fontSize: 16.0,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16.0),
                          FavoriteButton(
                            isFavorite: isFavorite,
                            onPressed: _toggleFavorite,
                          ),
                          const SizedBox(height: 16.0),
                          Center(
                            child: ElevatedButton.icon(
                              onPressed: _showTrailerDialog,
                              icon: const Icon(Icons.play_arrow),
                              label: const Text('Play Trailer'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          widget.movie.posterPath,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    MovieDetailCard(movie: widget.movie),
                    const SizedBox(height: 16.0),
                    Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          widget.movie.overview,
                          style: const TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    FavoriteButton(
                      isFavorite: isFavorite,
                      onPressed: _toggleFavorite,
                    ),
                    const SizedBox(height: 16.0),
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: _showTrailerDialog,
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Play Trailer'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
