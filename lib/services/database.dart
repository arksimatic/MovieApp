import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mim2_2/models/movie.dart';
import 'package:mim2_2/models/user.dart';

class DatabaseService {

  final Firestore db = Firestore.instance;
  final String uid;
  DatabaseService({ this.uid });

  List<Movie> _movieListFromSnapshot(QuerySnapshot snapshot) {

    return snapshot.documents.map((doc) {
      return Movie(doc.data['id'], doc.data['movie'], doc.data['year'], doc.data['plot'], doc.data['poster'], doc.data['rating']
      );
    }).toList();
  }

  final CollectionReference userCollection = Firestore.instance.collection('userCollection');
  final CollectionReference movieCollection = Firestore.instance.collection('movieCollection');

  Future updateMovieData(Movie movie, User user) async {
    return await movieCollection.document(uid).setData({
      'id' : movie.id,
      'name': movie.name,
      'year': movie.year,
      'plot' : movie.plot,
      'poster': movie.poster,
      'rating': movie.rating,
      'user' : user.uid,
    });
  }

  Future deleteMovieOfId(String id, User user) {
    var query = db.collection('movieCollection').where('id', isEqualTo: id).where('user', isEqualTo: user.uid.toString());
    query.getDocuments().then((querySnapshot) => {
      querySnapshot.documents.forEach((element) {
        element.reference.delete();
        print(element.data['name'] + 'deleted');
      }),
    });
  }

  Stream<List<Movie>> get movieData {
    return movieCollection.snapshots()
        .map(_movieListFromSnapshot);
  }

  Future updateUserData(int movieId) async {
    return await userCollection.document(uid).setData({
      'movieId': movieId
    });
  }
}