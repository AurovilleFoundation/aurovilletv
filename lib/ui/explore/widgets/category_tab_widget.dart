import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/explore_bloc.dart';

class CategoryTabWidget extends StatelessWidget {
  const CategoryTabWidget({super.key});

  static const _tabs = ["All", "Live", "Upcoming", "Ended"];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExploreBloc, ExploreState>(
      buildWhen: (previous, current) =>
          previous.selectedCategory != current.selectedCategory,
      builder: (context, state) {
        return SizedBox(
          height: 48,
          child: Row(
            children: _tabs.map((label) {
              final isSelected = state.selectedCategory == label;

              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    if (!isSelected) {
                      context.read<ExploreBloc>().add(
                            FilterByCategory(label),
                          );
                    }
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(),
                      // Instant Text (No animation delay)
                      Text(
                        label,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected
                              ? const Color(0xFFC85A17)
                              : Colors.black,
                        ),
                      ),
                      const Spacer(),

                      // Instant Underline (0ms delay)
                      Container(
                        height: 2.5,
                        width: isSelected ? 36 : 0,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFC85A17)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}