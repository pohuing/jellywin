import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart' as flutter_acrylic;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:jellywin/blocs/account_cubit.dart';
import 'package:system_theme/system_theme.dart';

import 'blocs/library_cubit.dart';
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
      dark: true);

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => LibraryCubit()),
        BlocProvider(create: (context) => AccountCubit(AccountCubitState())),
      ],
      child: MyApp(),
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
    router = buildRouter(context.read<LibraryCubit>().state);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var accentColor = SystemTheme.accentColor.accent.toAccentColor();
    var copyWith = FluentThemeData.dark().copyWith(
      accentColor: accentColor,
      scaffoldBackgroundColor: Colors.transparent,

    );

    return BlocListener<LibraryCubit, LibraryCubitState>(
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
                  path: '/library/:name',
                  name: e.$2,
                  builder: (context, state) =>
                      LibraryPage(state.pathParameters['name']!),
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
