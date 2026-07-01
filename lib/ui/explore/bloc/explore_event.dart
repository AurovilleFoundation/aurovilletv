part of 'explore_bloc.dart';

sealed class ExploreEvent extends Equatable {
  const ExploreEvent();

  @override
  List<Object?> get props => [];
}

/// Load screen
final class LoadExplore extends ExploreEvent {
  const LoadExplore();
}

/// User selected category
final class CategoryChanged extends ExploreEvent {
  final int categoryId;

  const CategoryChanged(this.categoryId);

  @override
  List<Object?> get props => [categoryId];
}

/// Pull to refresh
final class RefreshExplore extends ExploreEvent {
  const RefreshExplore();
}
