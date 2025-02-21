class Movie {
  final int id;
  final String title;
  final String overview;
  final String posterPath;
  final String releaseDate;
  final double rating;

  Movie({
    required this.id,
    required this.title,
    required this.overview,
    required this.posterPath,
    required this.releaseDate,
    required this.rating,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    String posterPath = json['poster_path'] != null
        ? 'https://image.tmdb.org/t/p/w500${json['poster_path']}'
        : 'https://via.placeholder.com/500x750?text=No+Image+Available';

    return Movie(
      id: json['id'],
      title: json['title'] ?? 'No Title',
      overview: json['overview'] ?? 'No Overview',
      posterPath: posterPath,
      releaseDate: json['release_date'] ?? 'Unknown Release Date',
      rating: (json['vote_average'] != null)
          ? json['vote_average'].toDouble()
          : 0.0,
    );
  }
}
