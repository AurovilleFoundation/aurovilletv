// ignore_for_file: unnecessary_underscores

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/explore_bloc.dart';

class CategoryTabWidget extends StatelessWidget {
  const CategoryTabWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExploreBloc, ExploreState>(
      buildWhen: (previous, current) =>
          previous.categories != current.categories ||
          previous.selectedCategoryId != current.selectedCategoryId,
      builder: (context, state) {
        if (state.categories.isEmpty) {
          return const SizedBox.shrink();
        }

        return SizedBox(
          height: 55,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: state.categories.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final category = state.categories[index];

              final selected = category.id == state.selectedCategoryId;

              return FilterChip(
                label: Text(category.name),

                selected: selected,

                showCheckmark: false,

                onSelected: (_) {
                  if (state.isLoading) return;
                  if (!selected) {
                    context.read<ExploreBloc>().add(
                      CategoryChanged(category.id),
                    );
                  }
                },

                labelStyle: TextStyle(
                  color: selected ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w600,
                ),

                backgroundColor: Colors.grey.shade200,

                selectedColor: Theme.of(context).primaryColor,

                side: BorderSide.none,

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),

                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
              );
            },
          ),
        );
      },
    );
  }
}
