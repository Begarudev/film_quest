class Movies {
  final String? title;
  final String? year;
  final String? imdbId;
  bool isFavourite;

  Movies(
      {required this.title,
      required this.year,
      required this.imdbId,
      this.isFavourite = false});

  factory Movies.fromJson(Map<String, dynamic> json) {
    return Movies(
      title: json["title"],
      year: json["year"],
      imdbId: json["imdb_id"],
      isFavourite: false,
    );
  }
}
