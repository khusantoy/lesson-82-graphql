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
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Products List"),
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

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: DataTable(
                columns: const [
                  DataColumn(
                    label: Text('ID'),
                  ),
                  DataColumn(
                    label: Text('Title'),
                  ),
                  DataColumn(
                    label: Text('Description'),
                  ),
                  DataColumn(
                    label: Text('Price'),
                  ),
                  DataColumn(
                    label: Text('Actions'),
                  ),
                ],
                rows: List.generate(
                  products.length,
                  (index) {
                    final product = products[index];

                    return DataRow(
                      cells: [
                        DataCell(
                          Text(
                            product['id'].toString(),
                          ),
                        ),
                        DataCell(
                          Text(
                            product['title'],
                          ),
                        ),
                        DataCell(
                          Text(
                            product['description'],
                          ),
                        ),
                        DataCell(
                          Text(
                            product['price'].toString(),
                          ),
                        ),
                        DataCell(Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () {
                                titleController.text = product['title'];
                                descriptionController.text =
                                    product['description'];
                                priceController.text =
                                    product['price'].toString();

                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: const Text("Edit Product"),
                                      content: Form(
                                        key: _formKey,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            TextFormField(
                                              controller: titleController,
                                              decoration: const InputDecoration(
                                                labelText: "Title",
                                              ),
                                              validator: (value) {
                                                if (value!.trim().isEmpty) {
                                                  return "Enter product title";
                                                }
                                                return null;
                                              },
                                            ),
                                            TextFormField(
                                              controller: descriptionController,
                                              decoration: const InputDecoration(
                                                labelText: "Description",
                                              ),
                                              validator: (value) {
                                                if (value!.trim().isEmpty) {
                                                  return "Enter product description";
                                                }
                                                return null;
                                              },
                                            ),
                                            TextFormField(
                                              controller: priceController,
                                              decoration: const InputDecoration(
                                                labelText: "Price",
                                              ),
                                              validator: (value) {
                                                if (value!.trim().isEmpty) {
                                                  return "Enter product price";
                                                }

                                                if (double.tryParse(value) ==
                                                    null) {
                                                  return "Product title must be double";
                                                }
                                                return null;
                                              },
                                            ),
                                            const SizedBox(
                                              height: 15,
                                            ),
                                            const Text("Upload image"),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                CircleAvatar(
                                                  backgroundColor: Colors.black,
                                                  child: IconButton(
                                                    onPressed: () {},
                                                    icon: const Icon(
                                                      Icons.camera,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 15,
                                                ),
                                                CircleAvatar(
                                                  backgroundColor: Colors.black,
                                                  child: IconButton(
                                                    onPressed: () {},
                                                    icon: const Icon(
                                                      Icons.photo,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                )
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: const Text("Cancel"),
                                        ),
                                        FilledButton(
                                          onPressed: () {
                                            if (_formKey.currentState!
                                                .validate()) {
                                              final client =
                                                  GraphQLProvider.of(context)
                                                      .value;

                                              client.mutate(
                                                MutationOptions(
                                                  document: gql(updateProduct),
                                                  variables: {
                                                    'id': product['id'],
                                                    'title':
                                                        titleController.text,
                                                    'price': 10.0,
                                                    'description':
                                                        descriptionController
                                                            .text,
                                                    'categoryId': 2.0,
                                                  },
                                                  onCompleted:
                                                      (dynamic resultData) {
                                                    Navigator.pop(context);
                                                    print(resultData);
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      const SnackBar(
                                                        content: Center(
                                                          child: Text(
                                                              "Updated product"),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              );
                                            }
                                          },
                                          child: const Text("Update"),
                                        )
                                      ],
                                    );
                                  },
                                );
                              },
                              icon: const Icon(
                                Icons.edit,
                                color: Colors.amber,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                final client =
                                    GraphQLProvider.of(context).value;
                                client.mutate(
                                  MutationOptions(
                                    document: gql(deleteProduct),
                                    variables: {'id': product['id']},
                                    onCompleted: (data) {
                                      print(data);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Center(
                                            child: Text("Deleted product"),
                                          ),
                                        ),
                                      );
                                    },
                                    onError: (error) {
                                      print(error);
                                    },
                                  ),
                                );
                              },
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        )),
                      ],
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text("Add Product"),
                content: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: titleController,
                        decoration: const InputDecoration(
                          labelText: "Title",
                        ),
                        validator: (value) {
                          if (value!.trim().isEmpty) {
                            return "Enter product title";
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: descriptionController,
                        decoration: const InputDecoration(
                          labelText: "Description",
                        ),
                        validator: (value) {
                          if (value!.trim().isEmpty) {
                            return "Enter product description";
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: priceController,
                        decoration: const InputDecoration(
                          labelText: "Price",
                        ),
                        validator: (value) {
                          if (value!.trim().isEmpty) {
                            return "Enter product price";
                          }

                          if (double.tryParse(value) == null) {
                            return "Product title must be double";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      const Text("Upload image"),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.black,
                            child: IconButton(
                              onPressed: () {},
                              icon: const Icon(
                                Icons.camera,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 15,
                          ),
                          CircleAvatar(
                            backgroundColor: Colors.black,
                            child: IconButton(
                              onPressed: () {},
                              icon: const Icon(
                                Icons.photo,
                                color: Colors.white,
                              ),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("Cancel"),
                  ),
                  FilledButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        final client = GraphQLProvider.of(context).value;

                        client.mutate(
                          MutationOptions(
                            document: gql(createProduct),
                            variables: {
                              'title': titleController.text,
                              'price': double.parse(priceController.text),
                              'description': descriptionController.text,
                              'categoryId': 2,
                              'images': const [
                                "https://dynamic-media-cdn.tripadvisor.com/media/photo-o/2c/07/a8/2c/caption.jpg?w=1400&h=1400&s=1"
                              ]
                            },
                            onCompleted: (dynamic resultData) {
                              Navigator.pop(context);
                              print(resultData);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Center(child: Text("Added new product")),
                                ),
                              );
                            },
                          ),
                        );
                      }
                    },
                    child: const Text("Add"),
                  )
                ],
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
