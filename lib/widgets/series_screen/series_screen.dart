import 'dart:convert';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jellywin/api/jellyfin_openapi_stable.swagger.dart';
import 'package:jellywin/repositories/series_repository.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

class SeriesScreen extends StatefulWidget {
  final String id;

  const SeriesScreen({super.key, required this.id});

  @override
  State<SeriesScreen> createState() => _SeriesScreenState();
}

class _SeriesScreenState extends State<SeriesScreen> {
  late Future<BaseItemDtoQueryResult?> seriesFuture;
  late Future<BaseItemDtoQueryResult?> nextUpFuture;

  JsonEncoder jsonEncoder = JsonEncoder.withIndent('    ');

  String? selectedVideoId;

  @override
  void initState() {
    seriesFuture = context.read<SeriesRepository>().loadInfo(widget.id);
    nextUpFuture = context.read<SeriesRepository>().loadNextUp(widget.id);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: seriesFuture,
      builder: (context, snapshot) {
        return ListView(
          children: [
            FutureBuilder(
              future: nextUpFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return ProgressRing();
                }

                return Button(
                  child: Text('Play'),
                  onPressed: () => pressPlay(snapshot),
                );
              },
            ),
            Expander(
              header: Text('Player'),
              content: FutureBuilder(
                future: nextUpFuture,
                builder: (context, snapshot) => Text(
                  jsonEncoder.convert(
                    jsonDecode(
                      snapshot.data.toString(),
                    ),
                  ),
                ),
              ),
            ),
            Expander(
              header: Text('Series Info'),
              content: Text(
                jsonEncoder.convert(
                  jsonDecode(
                    snapshot.data.toString(),
                  ),
                ),
              ),
            ),
            if (selectedVideoId != null)
              SizedBox(
                width: 500,
                height: 500,
                child: JellywinVideoPlayer(videoId: selectedVideoId!),
              ),
          ],
        );
      },
    );
  }

  void pressPlay(AsyncSnapshot<BaseItemDtoQueryResult?> snapshot) {
    setState(() {
      selectedVideoId = snapshot.data?.items?.firstOrNull?.id;
    });
  }
}

class JellywinVideoPlayer extends StatefulWidget {
  final String videoId;

  const JellywinVideoPlayer({super.key, required this.videoId});

  @override
  State<JellywinVideoPlayer> createState() => _JellywinVideoPlayerState();
}

class _JellywinVideoPlayerState extends State<JellywinVideoPlayer> {
  late VideoController controller;
  late Player player;

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  void initState() {
    final seriesRepo = context.read<SeriesRepository>();
    var resource = seriesRepo.generateStreamUrl(widget.videoId)!;

    player = Player(
      configuration: PlayerConfiguration(
        title: 'a',
        ready: () {
          player.open(Media(resource));
        },
      ),
    );
    controller = VideoController(
      player,
      configuration: VideoControllerConfiguration(),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Video(
          controller: controller,
        ),
      ],
    );
  }
}
