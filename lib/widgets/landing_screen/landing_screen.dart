import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:jellywin/api/jellyfin_openapi_stable.swagger.dart';
import 'package:jellywin/blocs/account_cubit.dart';

import 'library_card.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  var selectedIndex = 0;
  Future<BaseItemDtoQueryResult>? libraries;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccountCubit, AccountCubitState>(
      builder: (context, state) => state.user == null
          ? Text('Sign in')
          : FutureBuilder(
              future: libraries,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return Center(child: ProgressRing());
                }
                return ListView(
                  children: [
                    SizedBox(
                      height: 100,
                      child: ListView(
                        padding: EdgeInsets.all(8),
                        scrollDirection: Axis.horizontal,
                        children: [
                          ...?snapshot.data?.items?.map(
                            (e) => LibraryCard(
                              title: e.name!,
                              onTap: (){
                                context.go('/library/${e.id!}');
                              },
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                );
              },
            ),
    );
  }
}
