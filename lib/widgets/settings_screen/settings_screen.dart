import 'dart:convert';
import 'dart:developer';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jellywin/blocs/account_cubit.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final formKey = GlobalKey<FormState>();
  final addressTec = TextEditingController(text: 'http://localhost');
  final userTec = TextEditingController(text: 'admin');
  final pwTec = TextEditingController(text: 'admin');
  final portTec = TextEditingController(text: '8096');

  var enableSignInButton = false;

  String? me;
  JsonEncoder jsonEncoder = JsonEncoder.withIndent('    ');

  String? get mePretty =>
      me == null ? null : jsonEncoder.convert(jsonDecode(me!));

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccountCubit, AccountCubitState>(
      builder: (context, state) {
        return ListView(
          children: [
            Expander(
              header: Text('Account'),
              content: Form(
                key: formKey,
                autovalidateMode: AutovalidateMode.always,
                onChanged: () {
                  setState(() {
                    enableSignInButton = (formKey.currentState!.validate() ||
                        state.userId?.id != null);
                  });
                },
                child: Column(
                  children: [
                    ListTile(
                      title: Text('Address'),
                      trailing: SizedBox(
                        width: 200,
                        child: TextFormBox(
                          controller: addressTec,
                          autovalidateMode: AutovalidateMode.onUnfocus,
                          validator: (value) {
                            var uri = Uri.tryParse(value ?? '');
                            var schemeOk =
                                uri?.scheme == 'https' || uri?.scheme == 'http';
                            var hostOk = uri?.host.isNotEmpty ?? false;

                            if (hostOk && schemeOk) {
                              return null;
                            } else {
                              return 'Please enter a valid URL';
                            }
                          },
                        ),
                      ),
                    ),
                    ListTile(
                      title: Text('Port'),
                      trailing: SizedBox(
                        width: 200,
                        child: TextFormBox(
                          controller: portTec,
                          inputFormatters: [
                            FilteringTextInputFormatter('9-0', allow: false)
                          ],
                          autovalidateMode: AutovalidateMode.onUnfocus,
                          validator: (value) {
                            if (int.tryParse(value ?? '') == null) {
                              return 'Enter a valid number';
                            }
                          },
                        ),
                      ),
                    ),
                    ListTile(
                      title: Text('Username'),
                      trailing: SizedBox(
                        width: 200,
                        child: TextFormBox(
                          controller: userTec,
                          autovalidateMode: AutovalidateMode.onUnfocus,
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Enter a Username';
                            }
                          },
                        ),
                      ),
                    ),
                    ListTile(
                      title: Text('Password'),
                      trailing: SizedBox(
                        width: 200,
                        child: TextFormBox(
                          controller: pwTec,
                          autovalidateMode: AutovalidateMode.onUnfocus,
                          obscureText: true,
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Enter a Password';
                            }
                          },
                        ),
                      ),
                    ),
                    ListTile(
                      trailing: Button(
                        onPressed: enableSignInButton
                            ? () async {
                                var url = Uri.parse(addressTec.text);
                                url =
                                    url.replace(port: int.parse(portTec.text));
                                await context.read<AccountCubit>().signIn(url:url, username: userTec.text, password: pwTec.text);
                              }
                            : null,
                        child: Row(
                          children: [
                            if (state.userId?.id != null) Text('Sign Out'),
                            if (state.userId?.id == null) Text('Sign In'),
                            SizedBox(width: 8),
                            if (state.userId?.id != null)
                              Icon(FluentIcons.sign_out),
                            if (state.userId?.id == null)
                              Icon(FluentIcons.signin),
                          ],
                        ),
                      ),
                    ),
                    ListTile(
                      title: Text(state.lastMessage),
                      trailing: Button(
                        child: Text('hurr'),
                        onPressed: () async {
                          var _me = await context.read<AccountCubit>().me();
                          setState(() {
                            me = _me;
                          });
                          log(me ?? '');
                        },
                      ),
                    ),
                    if (me != null)
                      Expander(
                        header: Text('Me'),
                        content: Text(mePretty!),
                      ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget buildTrailing() {
    return Button(
      onPressed: () {},
      child: Row(
        children: [
          Icon(FluentIcons.signin),
          SizedBox(
            width: 8,
          ),
          Text('Sign In')
        ],
      ),
    );
  }
}
