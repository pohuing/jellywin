import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart' as flutter_acrylic;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:jellywin/image_service.dart';
import 'package:jellywin/repositories/image_repository.dart';
import 'package:jellywin/repositories/series_repository.dart';
import 'package:jellywin/repositories/user_repository.dart';
import 'package:jellywin/widgets/series_screen/series_screen.dart';
import 'package:system_theme/system_theme.dart';

import 'blocs/account_cubit.dart';
import 'blocs/libraries_cubit.dart';
import 'jellyfin_service.dart';
import 'widgets/landing_screen/landing_screen.dart';
import 'widgets/library_screen/library_page.dart';
import 'widgets/scaffold_with_nested_navigation.dart';
import 'widgets/settings_screen/settings_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemTheme.accentColor.load();

  await flutter_acrylic.Window.initialize();
  await flutter_acrylic.Window.setEffect(
    effect: flutter_acrylic.WindowEffect.mica,
    color: Colors.transparent,
    dark: true,
  );

  await initDeviceConstants();

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (context) => UserRepository()),
        RepositoryProvider(create: (context) => ImageRepository()),
        RepositoryProvider(create: (context) => SeriesRepository(userRepository: context.read<UserRepository>())),
        RepositoryProvider(
          create: (context) => ImageService(
            userRepository: context.read<UserRepository>(),
            imageRepository: context.read<ImageRepository>(),
          ),
        )
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
              create: (context) =>
                  LibrariesCubit(context.read<UserRepository>())),
          BlocProvider(
            create: (context) => AccountCubit(
              AccountCubitState(),
              context.read<UserRepository>(),
            ),
          ),
        ],
        child: MyApp(),
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late RouterConfig<Object> router;

  @override
  void initState() {
    router = buildRouter(context.read<LibrariesCubit>().state);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var accentColor = SystemTheme.accentColor.accent.toAccentColor();
    var copyWith = FluentThemeData.dark().copyWith(
      accentColor: accentColor,
      scaffoldBackgroundColor: Colors.transparent,
    );

    return BlocListener<LibrariesCubit, LibraryCubitState>(
      listener: (context, state) => setState(() => router = buildRouter(state)),
      child: FluentApp.router(
        key: const Key('value'),
        routerConfig: router,
        title: 'Eine App',
        themeMode: ThemeMode.system,
        darkTheme: copyWith,
        theme: FluentThemeData.light().copyWith(accentColor: Colors.red),
        builder: (context, child) {
          return NavigationPaneTheme(
            data: NavigationPaneThemeData(
              backgroundColor: Colors.transparent,
            ),
            child: child!,
          );
        },
      ),
    );
  }

  static RouterConfig<Object> buildRouter(LibraryCubitState libraries) {
    return GoRouter(
      initialLocation: '/settings',
      routes: [
        ShellRoute(
          builder: (context, state, child) {
            return ScaffoldWithNestedNavigation(
              libraries: libraries,
              child: child,
            );
          },
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => LandingScreen(),
            ),
            ...libraries.map(
              (e) {
                return GoRoute(
                  path: '/library/${e.id}',
                  name: e.name,
                  builder: (context, state) => LibraryPage(e.id!),
                  routes: [
                    GoRoute(
                      path: '/:seriesId',
                      builder: (context, state) => SeriesScreen(id: state.pathParameters['seriesId']! ),
                    ),
                  ],
                );
              },
            ),
            GoRoute(
              path: '/settings',
              builder: (context, state) => SettingsScreen(),
            ),
          ],
        ),
      ],
    );
  }
}
