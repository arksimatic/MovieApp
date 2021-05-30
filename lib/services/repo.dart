import 'dart:convert';
import 'dart:async' show Future;
import 'package:http/http.dart' as http;
import 'package:mim2_2/models/movie.dart';

class MovieRepo {
  static final MovieRepo _instance = MovieRepo._();

  factory MovieRepo() {
    return _instance;
  }

  MovieRepo._();

  final domain = 'imdb-internet-movie-database-unofficial.p.rapidapi.com';
  final more = '/film/';

  Future<Movie> getMovie(String name) async {
    final result = await http.Client().get(Uri.https(domain, more + name), headers: {
      'x-rapidapi-key': 'key_here',
      'x-rapidapi-host': 'imdb-internet-movie-database-unofficial.p.rapidapi.com'
    });

    print("code: " + result.statusCode.toString());

    if (result.statusCode != 200)
      return null;

    final response = json.decode(result.body);
    return Movie.fromJson(response);
  }
}
