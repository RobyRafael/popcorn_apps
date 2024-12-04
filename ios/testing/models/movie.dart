class Movie {
  final String title;
  final String releaseDate;
  final String overview;
  final String posterPath;

  Movie({
    required this.title,
    required this.releaseDate,
    required this.overview,
    required this.posterPath,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      title: json['title'],
      releaseDate: json['release_date'],
      overview: json['overview'],
      posterPath: json['poster_path'],
    );
  }
}
