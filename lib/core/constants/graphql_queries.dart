const String fetchProducts = """
query {
  products(limit: 20, offset: 0) {
    id
    title
    price
    description
    category {
      name
    }
  }
}
""";
