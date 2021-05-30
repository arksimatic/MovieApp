import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mim2_2/models/movie.dart';
import 'package:mim2_2/services/repo.dart';

class MovieEvent extends Equatable{
  @override
  List<Object> get props => [];
}

class FetchMovie extends MovieEvent{
  final _city;

  FetchMovie(this._city);

  @override
  List<Object> get props => [_city];
}

class ResetMovie extends MovieEvent{}

class MovieState extends Equatable{
  @override
  List<Object> get props => [];
}

class MovieIsNotSearched extends MovieState{}

class MovieIsLoading extends MovieState{}

class MovieIsLoaded extends MovieState{
  final _movie;

  MovieIsLoaded(this._movie);

  Movie get getMovie => _movie;

  @override
  List<Object> get props => [_movie];
}

class MovieIsNotLoaded extends MovieState{ }

class MovieBloc extends Bloc<MovieEvent, MovieState>{

  MovieRepo movieRepo;

  MovieBloc(MovieState initialState, this.movieRepo) : super(initialState);
  @override
  Stream<MovieState> mapEventToState(MovieEvent event) async*{
    if(event is FetchMovie){
      yield MovieIsLoading();
      try{
        Movie movie = await movieRepo.getMovie(event._city); //name!
        yield MovieIsLoaded(movie);
      }catch(_){
        print(_);
        yield MovieIsNotLoaded();
      }
    }else if(event is ResetMovie){
      yield MovieIsNotSearched();
    }
  }
}