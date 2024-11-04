import 'package:flutter_bloc/flutter_bloc.dart';


typedef LibraryCubitState = List<(int, String)>;

class LibraryCubit extends Cubit<LibraryCubitState>{
  LibraryCubit() : super(['a', 'b', 'c','d'].indexed.toList());


  void setRoutes(LibraryCubitState routes){
    emit(List.from(routes));
  }
}