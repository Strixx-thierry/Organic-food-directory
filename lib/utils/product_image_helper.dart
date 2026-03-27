class ProductImageHelper {
  static String getAssetPath(String productName) {
    final name = productName.toLowerCase();
    if (name.contains('spinach')) return 'assets/images/spinach.jpeg';
    if (name.contains('tomato')) return 'assets/images/tomato.png';
    if (name.contains('apple')) return 'assets/images/apple.webp';
    if (name.contains('egg')) return 'assets/images/eggs.webp';
    return 'assets/images/placeholder.avif';
  }
}
