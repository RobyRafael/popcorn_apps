class Movie {
  final int id;
  final String title;
  final String? overview;
  final String? releaseDate;
  final String? posterPath;
  final double? voteAverage;
  final int? voteCount;

  Movie({
    required this.id,
    required this.title,
    this.overview,
    this.releaseDate,
    this.posterPath,
    this.voteAverage,
    this.voteCount,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'No Title',
      overview: json['overview'],
      releaseDate: json['release_date'],
      posterPath: json['poster_path'],
      voteAverage: json['vote_average'] != null
          ? (json['vote_average'] as num).toDouble()
          : null,
      voteCount: json['vote_count'] ?? 0,
    );
  }
}
