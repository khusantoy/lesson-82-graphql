import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:lesson_82_graphql/core/constants/graphql_mutations.dart';
import 'package:lesson_82_graphql/core/constants/graphql_queries.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home Screen"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final client = GraphQLProvider.of(context).value;

          client.mutate(
            MutationOptions(
              document: gql(createProduct),
              variables: const {
                'title': "Space X Company Rocket",
                'price': 10.0,
                'description': "Rocket build by Elon",
                'categoryId': 2,
                'images': [
                  "https://dynamic-media-cdn.tripadvisor.com/media/photo-o/2c/07/a8/2c/caption.jpg?w=1400&h=1400&s=1"
                ]
              },
              onCompleted: (dynamic resultData) {
                print(resultData);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Mahsulot qo'shildi"),
                  ),
                );
              },
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: Query(
        options: QueryOptions(document: gql(fetchProducts)),
        builder: (result, {fetchMore, refetch}) {
          if (result.hasException) {
            return Center(
              child: Text(result.exception.toString()),
            );
          }

          if (result.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          List products = result.data!['products'];

          print(products.length);

          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];

              return ListTile(
                title: Text(product['title']),
                subtitle: Text(product['description']),
              );
            },
          );
        },
      ),
    );
  }
}
