import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

part 'whistle_event.dart';
part 'whistle_state.dart';

class WhistleBloc extends Bloc<WhistleEvent, WhistleState> {
  int _currentCount = 0;
  final int maxWhistleCount;

  WhistleBloc(this.maxWhistleCount) : super(WhistleInitial()) {
    on<SetWhistleCount>(_onSetWhistleCount);
    on<StartListening>(_onStartListening);
    on<WhistleDetected>(_onWhistleDetected);
    on<StopListening>(_onStopListening);
  }

  void _onSetWhistleCount(SetWhistleCount event, Emitter<WhistleState> emit) {
    emit(WhistleCountSet(event.count));
  }

  void _onStartListening(StartListening event, Emitter<WhistleState> emit) {
    emit(Listening());
  }

  void _onWhistleDetected(WhistleDetected event, Emitter<WhistleState> emit) {
    _currentCount++;
    if (_currentCount <= maxWhistleCount) {
      emit(WhistleCountUpdated(_currentCount));
    } else {
      emit(WhistleInitial());
    }
  }

  void _onStopListening(StopListening event, Emitter<WhistleState> emit) {
    _currentCount = 0;
    emit(WhistleInitial());
  }
}
