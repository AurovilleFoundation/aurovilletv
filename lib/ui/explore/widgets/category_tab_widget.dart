// ignore_for_file: unnecessary_underscores

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/explore_bloc.dart';
import 'package:aurovilletv/utils/theme/colors.dart';

class CategoryTabWidget extends StatelessWidget {
  const CategoryTabWidget({super.key});

  // Only required tabs
  static const _tabs = ["All", "Live", "Upcoming", "Ended"];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExploreBloc, ExploreState>(
      buildWhen: (previous, current) =>
          previous.selectedCategory != current.selectedCategory,
      builder: (context, state) {
        return SizedBox(
          height: 55,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: _tabs.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final label = _tabs[index];
              final selected = state.selectedCategory == label;

              return ChoiceChip(
                label: Text(label),
                selected: selected,
                showCheckmark: true,
                checkmarkColor: AppColors.lightColor,
                onSelected: (_) {
                  if (!selected) {
                    context.read<ExploreBloc>().add(
                      FilterByCategory(label),
                    );
                  }
                },
                labelStyle: TextStyle(
                  color: selected ? AppColors.lightColor : AppColors.darkColor,
                  fontWeight: FontWeight.w600,
                ),
                backgroundColor: AppColors.lightColor,
                selectedColor: AppColors.themeColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                  side: BorderSide(
                    color: selected
                        ? AppColors.themeColor
                        : const Color.fromARGB(255, 240, 237, 235),
                    width: 1.5,
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              );
            },
          ),
        );
      },
    );
  }
}
