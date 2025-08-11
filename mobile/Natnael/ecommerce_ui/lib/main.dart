import 'package:flutter/material.dart';
import 'features/authentication/presentation/pages/splash_page.dart';
import 'injection_container.dart' as di;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'features/chat/presentation/bloc/chat_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  
  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: di.sl<ChatBloc>(),
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Product App',
        home: SplashPage(),
      ),
    );
  }
}
