import 'package:fluent_ui/fluent_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:jellywin/blocs/library_cubit.dart';

class ScaffoldWithNestedNavigation extends StatelessWidget {
  final Widget child;
  final LibraryCubitState libraries;

  const ScaffoldWithNestedNavigation({
    super.key,
    required this.child,
    required this.libraries,
  });

  int selectedItemIndex(BuildContext context) {
    var routerState = GoRouterState.of(context);
    if (routerState.uri.pathSegments.firstOrNull == 'settings') {
      return libraries.length + 1;
    } else if (routerState.uri.pathSegments.firstOrNull == 'library') {
      return libraries.indexWhere((l) => routerState.topRoute?.name == l.name) +
          1;
    }
    return 0;
  }

  PaneItem buildLibraryPaneItem(BuildContext context, String name, String id) {
    return PaneItem(
      icon: Icon(FluentIcons.library),
      title: Text(name),
      body: SizedBox.shrink(),
      onTap: () => context.go('/library/$id'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return NavigationView(
      pane: NavigationPane(
        selected: selectedItemIndex(context),
        items: [
          PaneItem(
            icon: Icon(FluentIcons.all_apps),
            title: Text('Landing Page'),
            body: const SizedBox.shrink(),
            onTap: () => context.go('/'),
          ),
          ...libraries
              .map((e) => buildLibraryPaneItem(context, e.name!, e.id!)),
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
        return child;
      },
    );
  }
}
