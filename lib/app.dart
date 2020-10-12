import 'package:flutter/material.dart';
import 'package:recipe/app_model.dart';
import 'package:recipe/domain/user_state.dart';
import 'package:recipe/presentation/signin/signin_page.dart';
import 'package:recipe/presentation/signup/signup_page.dart';
import 'package:recipe/presentation/splash/splash_page.dart';
import 'package:recipe/presentation/top/top_page.dart';

class App extends StatelessWidget {
  final model = AppModel();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: StreamBuilder(
        stream: model.userState,
        initialData: UserState.signedOut,
        builder: (context, AsyncSnapshot<UserState> snapshot) {
          final UserState state =
              snapshot.connectionState == ConnectionState.waiting
                  ? UserState.waiting
                  : snapshot.data;
          print("App(): userState = $state");
          return _convertPage(state);
        },
      ),
    );
  }

  // UserState => page
  StatelessWidget _convertPage(UserState state) {
    switch (state) {
      case UserState.waiting:
        return SplashPage();
      case UserState.signedOut:
        return SignInPage();
      case UserState.signedIn:
        return TopPage();
      default:
        return SignInPage();
    }
  }
}
