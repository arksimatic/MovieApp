class Movie {
  final id;
  final name;
  final year;
  final plot;
  final poster;
  final rating;

  Movie(this.id, this.name, this.year, this.plot,
      this.poster, this.rating);

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      json['id'],
      json['title'],
      (json['year']).isEmpty ? '' : json['year'],
      (json['plot']).isEmpty ? '' : json['plot'],
      json['poster'],
      (json['rating']).isEmpty ? '' : json['rating'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': this.id,
      'name': this.name,
      'year': this.year,
      'plot': this.plot,
      'poster': this.poster,
      'rating': this.rating
    };
  }

  factory Movie.fromDb(Map<dynamic, dynamic> dbRecord, String ref) {
    return Movie(
      dbRecord['id'],
      dbRecord['name'],
      dbRecord['year'],
      dbRecord['plot'],
      dbRecord['poster'],
      dbRecord['rating'],
    );
  }
}
