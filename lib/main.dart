import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:lesson_82_graphql/config/graphql_config.dart';
import 'package:lesson_82_graphql/ui/screens/home_screen.dart';

void main() {
  final client = GraphQLConfig.initializeClient();

  runApp(
    MyApp(
      client: client,
    ),
  );
}

class MyApp extends StatelessWidget {
  final ValueNotifier<GraphQLClient> client;
  const MyApp({super.key, required this.client});

  @override
  Widget build(BuildContext context) {
    return GraphQLProvider(
      client: client,
      child: const CacheProvider(
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: HomeScreen(),
        ),
      ),
    );
  }
}
