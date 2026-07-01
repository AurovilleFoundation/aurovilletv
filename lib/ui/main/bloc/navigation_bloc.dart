import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
part 'navigation_event.dart';
part 'navigation_state.dart';

class NavigationBloc extends Bloc<NavigationEvent, NavigationState> {
  NavigationBloc() : super(const NavigationState()) {
    on<TabChanged>(_onTabChanged);
  }

  void _onTabChanged(TabChanged event, Emitter<NavigationState> emit) {
    if (event.index == state.currentIndex) return;

    emit(state.copyWith(currentIndex: event.index));
  }
}
