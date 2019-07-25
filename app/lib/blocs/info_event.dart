import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
abstract class InfoEvent extends Equatable {
  InfoEvent([List props = const []]) : super(props);
}

class Entered extends InfoEvent {
  final String query;
  Entered({this.query});
}

class InfoErrorEvent extends InfoEvent {}
