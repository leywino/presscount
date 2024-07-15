part of 'whistle_bloc.dart';

abstract class WhistleState extends Equatable {
  @override
  List<Object> get props => [];
}

class WhistleInitial extends WhistleState {}

class WhistleCountSet extends WhistleState {
  final int count;
  WhistleCountSet(this.count);

  @override
  List<Object> get props => [count];
}

class Listening extends WhistleState {}

class WhistleCountUpdated extends WhistleState {
  final int count;
  WhistleCountUpdated(this.count);

  @override
  List<Object> get props => [count];
}