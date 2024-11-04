import 'package:fluent_ui/fluent_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:jellywin/blocs/library_cubit.dart';

class ScaffoldWithNestedNavigation extends StatefulWidget {
  final Widget child;
  final LibraryCubitState libraries;

  const ScaffoldWithNestedNavigation({
    super.key,
    required this.child,
    required this.libraries,
  });

  @override
  State<ScaffoldWithNestedNavigation> createState() =>
      _ScaffoldWithNestedNavigationState();
}

class _ScaffoldWithNestedNavigationState
    extends State<ScaffoldWithNestedNavigation> {
  int selectedItemIndex() {
    var routerState = GoRouterState.of(context);
    if (routerState.uri.pathSegments.firstOrNull == 'settings') {
      return widget.libraries.length + 1;
    } else if (routerState.uri.pathSegments.firstOrNull == 'library') {
      return widget.libraries.indexWhere(
            (element) => routerState.pathParameters['name'] == element.$2,
          ) +
          1;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return NavigationView(
        appBar: NavigationAppBar(),
        pane: NavigationPane(
          selected: selectedItemIndex(),
          items: [
            PaneItem(
              icon: Icon(FluentIcons.all_apps),
              title: Text('Landing Page'),
              body: const SizedBox.shrink(),
              onTap: () => context.go('/'),
            ),
            ...widget.libraries.map((e) => buildLibraryPaneItem(e.$2, e.$1)),
          ],
          footerItems: [
            PaneItem(
              icon: const Icon(FluentIcons.settings),
              title: const Text('Settings'),
              body: const SizedBox.shrink(),
              onTap: () => context.go('/settings'),
            ),
          ],
        ),
        paneBodyBuilder: (item, body) {
          return widget.child;
        },
      );
  }

  PaneItem buildLibraryPaneItem(String name, int index) {
    return PaneItem(
      icon: Icon(FluentIcons.library),
      title: Text(name),
      body: SizedBox.shrink(),
      onTap: () => context.go('/library/$name'),
    );
  }
}
