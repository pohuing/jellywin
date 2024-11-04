import 'package:fluent_ui/fluent_ui.dart';

class LibraryCard extends StatelessWidget {
  final String title;
  final Function? onTap;

  const LibraryCard({super.key, required this.title, this.onTap});

  @override
  Widget build(BuildContext context) {
    return TapRegion(
      onTapInside: onTap != null ? (d) => onTap!() : null,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            title,
            style: FluentTheme.of(context).typography.title,
          ),
        ),
      ),
    );
  }
}
