part of 'whistle_bloc.dart';

abstract class WhistleEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class SetWhistleCount extends WhistleEvent {
  final int count;
  SetWhistleCount(this.count);

  @override
  List<Object> get props => [count];
}

class StartListening extends WhistleEvent {}
class StopListening extends WhistleEvent {}
class WhistleDetected extends WhistleEvent {}