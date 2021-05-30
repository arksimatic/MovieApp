import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mim2_2/bloc/movie_bloc.dart';
import 'package:mim2_2/models/movie.dart';
import 'package:mim2_2/models/user.dart';
import 'package:mim2_2/services/auth.dart';
import 'package:mim2_2/services/database.dart';
import 'package:mim2_2/services/repo.dart';
import 'package:mim2_2/shared/constants.dart';
import 'package:provider/provider.dart';

class Home extends StatelessWidget {

  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: Colors.grey[900],
          body: BlocProvider(
            create: (context) =>
                MovieBloc(MovieIsNotSearched(), MovieRepo()),
            child: ChooseModeScreen(),
          ),
          appBar: AppBar(
            title: Text('Filmoteka'),
            backgroundColor: Color.fromARGB(255, 0, 102, 204),
            elevation: 0.0,
            actions: <Widget>[
              FlatButton.icon(
                icon: Icon(Icons.person),
                label: Text('Wyloguj'),
                onPressed: () async {
                  await _auth.signOut();
                },
              )
            ],
          ),
        )
    );
  }
}

class ChooseModeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(children: <Widget>[
          Expanded(
            child: Container(
              width: double.infinity,
              height: 50,
              child: FlatButton(
                onPressed: () {
                  navigateToMovieSearch(context);
                },
                color: Colors.blue,
                child: Text(
                  "Szukaj film",
                  style: TextStyle(color: Colors.white70, fontSize: 36),
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              height: 50,
              child: FlatButton(
                onPressed: () {
                  navigateToMovieList(context);
                },
                color: Colors.blue,
                child: Text(
                  "Lista filmów",
                  style: TextStyle(color: Colors.white70, fontSize: 64),
                ),
              ),
            ),
          ),
        ])
    );
  }

  void navigateToMovieSearch(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: BlocProvider.of<MovieBloc>(context),
          child: MovieSearchPage(),
        )
      ),
    );
  }

  void navigateToMovieList(BuildContext context) {
    Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: BlocProvider.of<MovieBloc>(context),
            child: MovieListPage(),
          )
        )
    );
  }
}

class MovieListPage extends StatelessWidget {

  DatabaseService _db = DatabaseService();

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.blue,
      floatingActionButton: null,
      body: StreamBuilder(
        stream: Firestore.instance.collection('movieCollection').where('user', isEqualTo: Provider.of<User>(context, listen: false).uid).snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if(!snapshot.hasData) {
            return Center(
            );
          }
          else{
            return ListView(
              children: snapshot.data.documents.map((document) {
                return GestureDetector(
                  child: Center(
                    child: Container(
                      margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                      child: Row(
                        children: [
                          Container(
                            child: Image.network(
                              document.data['poster'] ?? '', //no image?
                              scale: 0.05,
                              width: MediaQuery.of(context).size.width / 4,
                            ),
                          ),
                          Column(
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width * 3 / 4 - 20,
                                padding: EdgeInsets.only(left: 10.0, right: 3.0),
                                child: Text(
                                  '${document.data['name'] ?? ''} ${document.data['year']}',
                                  style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w400
                                  ),
                                ),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width * 3 / 4 - 20,
                                padding: EdgeInsets.only(left: 10.0, right: 3.0),
                                child: Text(
                                  '${trim(180, document.data['plot'] ?? '')}',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w300
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  onTap: () {
                    print("trying to delete");
                    _db.deleteMovieOfId(document.data['id'],  Provider.of<User>(context, listen: false));
                  },
                );
              }).toList(),
            );
          }
        },
      ) ,
    );
  }
}

class MovieSearchPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final movieBloc = BlocProvider.of<MovieBloc>(context);
    var cityController = TextEditingController();

    return Scaffold(
      backgroundColor: Colors.blue,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          BlocBuilder<MovieBloc, MovieState>(
            builder: (context, state) {
              if (state is MovieIsNotSearched)
                return Container(
                  padding: EdgeInsets.only(
                    left: 32,
                    right: 32,
                  ),
                  child: Column(
                    children: <Widget>[
                      Text(
                        "Wpisz tytuł filmu",
                        style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w400,
                            color: Colors.white70),
                      ),
                      SizedBox(
                        height: 80,
                      ),
                      TextFormField(
                        controller: cityController,
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.search,
                            color: Colors.white70,
                          ),
                          enabledBorder: OutlineInputBorder(
                              borderRadius:
                              BorderRadius.all(Radius.circular(10)),
                              borderSide: BorderSide(
                                  color: Colors.white70,
                                  style: BorderStyle.solid)
                          ),
                          focusedBorder: OutlineInputBorder(
                              borderRadius:
                              BorderRadius.all(Radius.circular(10)),
                              borderSide: BorderSide(
                                  color: Colors.blue,
                                  style: BorderStyle.solid)
                          ),
                          hintText: "Wpisz tytuł filmu!",
                          hintStyle: TextStyle(color: Colors.white70),
                        ),
                        style: TextStyle(color: Colors.white70),
                      ),
                      SizedBox(
                        height: 102,
                      ),
                      Container(
                        width: double.infinity,
                        height: 50,
                        child: FlatButton(
                          shape: new RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.all(Radius.circular(25))),
                          onPressed: () {
                            movieBloc.add(FetchMovie(cityController.text));
                          },
                          color: Colors.lightBlue,
                          child: Text(
                            "Szukaj",
                            style:
                            TextStyle(color: Colors.white70, fontSize: 16),
                          ),
                        ),
                      )
                    ],
                  ),
                );
              else if (state is MovieIsLoading)
                return Center(child: CircularProgressIndicator());
              else if (state is MovieIsLoaded)
                return ShowMovie(state.getMovie, cityController.text);
              else
                return Container(
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          "Przepraszamy, nie znaleziono podanego tytułu",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white, fontSize: 24),
                        ),
                      ),
                      SizedBox(
                        height: 300,
                      ),
                      Container(
                        width: double.infinity,
                        height: 50,
                        child: FlatButton(
                          shape: new RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.all(Radius.circular(10))),
                          onPressed: () {
                            BlocProvider.of<MovieBloc>(context)
                                .add(ResetMovie());
                          },
                          color: Colors.lightBlue,
                          child: Text(
                            "Szukaj ponownie",
                            style:
                            TextStyle(color: Colors.white70, fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
            },
          )
        ],
      ),
    );
  }
}

class ShowMovie extends StatelessWidget {
  Movie movie;
  final city;

  ShowMovie(this.movie, this.city);

  @override
  Widget build(BuildContext context) {
    final DatabaseService _db = DatabaseService();

    return Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: new EdgeInsets.symmetric(horizontal: 20.0),
              padding: EdgeInsets.all(10.0),
              child: Center(
                 child: Text(
                   movie.name + movie.year,
                  style: TextStyle(
                      color: Colors.white70, fontSize: 40, fontWeight: FontWeight.bold),
                ),
              ),

            ),
            Image.network(
              movie.poster,
              scale: 0.5,
              height: 350,
            ),
            SizedBox(height: 20.0),
            Container(
              margin: new EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                movie.plot,
                style: TextStyle(
                    color: Colors.white70, fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 20.0),
            Container(
              width: 400,
              height: 50,
              child: FlatButton(
                shape: new RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20))),
                onPressed: () {
                  BlocProvider.of<MovieBloc>(context).add(ResetMovie());
                },
                color: Colors.lightBlue,
                child: Text(
                  "Wyszukaj ponownie",
                  style: TextStyle(color: Colors.white70, fontSize: 24),
                ),
              ),
            ),
            SizedBox(height: 20.0),
            Container(
              width: 400,
              height: 50,
              child: FlatButton(
                shape: new RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20))),
                onPressed: () {
                  dynamic result = _db.updateMovieData(movie, Provider.of<User>(context, listen: false));
                },
                color: Colors.lightBlue,
                child: Text(
                  "Zapisz film",
                  style: TextStyle(color: Colors.white70, fontSize: 24),
                ),
              ),
            )
          ],
        )
    );
  }
}