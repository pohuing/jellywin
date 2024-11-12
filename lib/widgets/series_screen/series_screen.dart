
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jellywin/api/jellyfin_openapi_stable.swagger.dart';
import 'package:jellywin/repositories/series_repository.dart';

class SeriesScreen extends StatefulWidget {
  final String id;
  const SeriesScreen({super.key, required this.id });

  @override
  State<SeriesScreen> createState() => _SeriesScreenState();
}

class _SeriesScreenState extends State<SeriesScreen> {
  late Future<BaseItemDtoQueryResult?> seriesFuture;

  @override
  void initState() {
    seriesFuture = context.read<SeriesRepository>().loadInfo(widget.id);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: seriesFuture,
      builder:(context, snapshot) => Column(
        children: [
          Text("asdkasdkasdk"),
          Button(child: Text('Play'), onPressed: pressPlay),
          Text(snapshot.data.toString()),
        ],
      ),
    );
  }

  void pressPlay(){

  }
}


class JellywinVideoPlayer extends StatefulWidget {
  const JellywinVideoPlayer({super.key});

  @override
  State<JellywinVideoPlayer> createState() => _JellywinVideoPlayerState();
}

class _JellywinVideoPlayerState extends State<JellywinVideoPlayer> {
  @override
  Widget build(BuildContext context) {
    return Stack(children: [

    ],);
  }
}
