import 'package:ecommerce_ui/add_update_page.dart';
import 'package:ecommerce_ui/detail_page.dart';
import 'package:ecommerce_ui/search_page.dart';
import 'package:flutter/material.dart';
import 'home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ecommerce UI',
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/DetailPage': (context) => const DetailPage(),
        '/AddUpdatePage': (context) => const AddUpdatePage(),
        '/SearchPage' : (context) => const SearchPage(),
      },
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      
    );
  }
}












// for learning purpose


// import 'package:ecommerce_ui/add_update_page.dart';
// import 'package:ecommerce_ui/detail_page.dart';
// import 'package:ecommerce_ui/search_page.dart';
// import 'package:flutter/material.dart';
// import 'home_page.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Ecommerce UI',
//       initialRoute: '/',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         pageTransitionsTheme: const PageTransitionsTheme(
//           builders: {
//             TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
//             TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
//           },
//         ),
//       ),
//       onGenerateRoute: (settings) {
//         switch (settings.name) {
//           case '/':
//             return MaterialPageRoute(builder: (_) => const HomePage());
//           case '/DetailPage':
//             final args = settings.arguments;
//             return PageRouteBuilder(
//               pageBuilder: (_, __, ___) => DetailPage(),
//               settings: settings,
//               transitionsBuilder: (context, animation, secondaryAnimation, child) {
//                 return FadeTransition(
//                   opacity: animation,
//                   child: child,
//                 );
//               },
//             );
//           case '/AddUpdatePage':
//             final args = settings.arguments;
//             return PageRouteBuilder(
//               pageBuilder: (_, __, ___) => AddUpdatePage(),
//               settings: settings,
//               transitionsBuilder: (context, animation, secondaryAnimation, child) {
//                 return SlideTransition(
//                   position: Tween<Offset>(
//                     begin: const Offset(1, 0),
//                     end: Offset.zero,
//                   ).animate(animation),
//                   child: child,
//                 );
//               },
//             );
//           case '/SearchPage':
//             return MaterialPageRoute(builder: (_) => const SearchPage());
//           default:
//             return MaterialPageRoute(
//               builder: (_) => const Scaffold(
//                 body: Center(child: Text('Page not found')),));
//         }
//       },
//     );
//   }
// }