import 'package:aurovilletv/data/di/service_locator.dart';
import 'package:aurovilletv/data/network/api/video_api_service.dart';
import 'package:aurovilletv/ui/explore/bloc/explore_bloc.dart';
import 'package:aurovilletv/ui/explore/cubit/search_cubit.dart';
import 'package:aurovilletv/ui/main/bloc/navigation_bloc.dart';
import 'package:aurovilletv/ui/main/main_screen.dart';
import 'package:aurovilletv/ui/watchlist/bloc/watchlist_bloc.dart';
import 'package:aurovilletv/utils/dbmanager.dart';
import 'package:aurovilletv/utils/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../utils/values/strings.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => NavigationBloc()),
        BlocProvider(
          create: (_) => ExploreBloc(
            dbManager: getIt<DBManager>(),
            apiService: getIt<VideoApiService>(),
          )..add(const LoadExplore()),
        ),
        BlocProvider(
          create: (_) => SearchCubit(apiService: getIt<VideoApiService>()),
        ),
        BlocProvider(
          create: (_) =>
              WatchListBloc(dbManager: getIt<DBManager>())
                ..add(const LoadWatchList()),
        ),
      ],
      child: MaterialApp(
        title: AppStrings.appName,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.themeColor),
          scaffoldBackgroundColor: AppColors.scaffoldBackgroundColor,
          useMaterial3: true,
          dialogTheme: const DialogThemeData(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
          ),
        ),
        debugShowCheckedModeBanner: false,
        home: MainScreen(),
      ),
    );
  }
}
