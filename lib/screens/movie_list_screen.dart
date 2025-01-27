import 'package:flutter/material.dart';
import 'package:movtalog/models/movie.dart';
import 'package:movtalog/screens/movie_detail_screen.dart';
import 'package:movtalog/screens/favorites_screen.dart';
import 'package:movtalog/services/api_service.dart';

class MovieListScreen extends StatefulWidget {
  const MovieListScreen({super.key});

  @override
  _MovieListScreenState createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  late Future<List<Movie>> futureMovies;
  List<Movie> filteredMovies = [];
  TextEditingController searchController = TextEditingController();
  bool isSearching = false;

  @override
  void initState() {
    super.initState();
    futureMovies = ApiService().fetchPopularMovies();
    searchController.addListener(_searchMovies);
  }

  void _searchMovies() {
    setState(() {
      isSearching = searchController.text.isNotEmpty;
      if (isSearching) {
        _performSearch(searchController.text);
      } else {
        futureMovies = ApiService().fetchPopularMovies();
      }
    });
  }

  Future<void> _performSearch(String query) async {
    final results = await ApiService().searchMovies(query);
    setState(() {
      filteredMovies = results;
    });
  }

  @override
  void dispose() {
    searchController.removeListener(_searchMovies);
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Movtalog'),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const FavoritesScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Container(
                width: MediaQuery.of(context).size.width *
                    0.5, // Menyesuaikan lebar menjadi 2/4 dari layar
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    labelText: 'Search',
                    suffixIcon: searchController.text.isEmpty
                        ? const Icon(Icons.search)
                        : IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              searchController.clear();
                              _searchMovies();
                            },
                          ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: isSearching
                ? _buildMovieList(filteredMovies)
                : FutureBuilder<List<Movie>>(
                    future: futureMovies,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return const Center(
                            child: Text('Failed to load movies'));
                      } else {
                        final movies = snapshot.data!;
                        return _buildMovieList(movies);
                      }
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildMovieList(List<Movie> movies) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          return ListView.builder(
            itemCount: movies.length,
            itemBuilder: (context, index) {
              final movie = movies[index];
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
                    ),
                  );
                },
              );
            },
          );
        } else {
          int crossAxisCount = 5; // Default value

          // Menyesuaikan jumlah kolom berdasarkan lebar layar
          if (constraints.maxWidth >= 1200) {
            crossAxisCount = 5;
          } else if (constraints.maxWidth >= 1000) {
            crossAxisCount = 4;
          } else if (constraints.maxWidth >= 800) {
            crossAxisCount = 3;
          } else {
            crossAxisCount = 2;
          }

          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 4.0, // Kurangi jarak antar kolom
              mainAxisSpacing: 4.0, // Kurangi jarak antar baris
              childAspectRatio:
                  0.55, // Menyesuaikan rasio agar gambar lebih tinggi
            ),
            itemCount: movies.length,
            itemBuilder: (context, index) {
              final movie = movies[index];
              return GestureDetector(
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
                    ),
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                            10), // Bagian bawah gambar juga melengkung
                        child: AspectRatio(
                          aspectRatio:
                              0.7, // Sesuaikan rasio agar gambar lebih besar
                          child: Image.network(
                            movie.posterPath,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                          8.0, 4.0, 8.0, 2.0), // Kurangi padding di sini
                      child: Text(
                        movie.title,
                        maxLines: 2, // Batasi jumlah baris pada teks judul
                        overflow: TextOverflow
                            .ellipsis, // Tambahkan ellipsis untuk judul yang terlalu panjang
                        style: TextStyle(
                          fontSize: constraints.maxWidth >= 1200
                              ? 14.0
                              : 16.0, // Ukuran font berdasarkan lebar layar
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        'Rating: ${movie.rating}',
                        style: TextStyle(
                          fontSize: constraints.maxWidth >= 1200
                              ? 12.0
                              : 14.0, // Ukuran font berdasarkan lebar layar
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                          8.0, 2.0, 8.0, 2.0), // Kurangi padding di sini
                      child: Text(
                        'Release Date: ${movie.releaseDate}',
                        style: TextStyle(
                          fontSize: constraints.maxWidth >= 1200
                              ? 12.0
                              : 14.0, // Ukuran font berdasarkan lebar layar
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        }
      },
    );
  }
}
