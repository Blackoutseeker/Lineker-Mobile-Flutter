import '../interfaces/utils/database_codification.dart';

class DatabaseCodification implements DatabaseCodificationMethods {
  @override
  String encodeToDatabase({required String text}) {
    final String encodedText = text
        .replaceAll('.', '_P')
        .replaceAll('\$', '_S')
        .replaceAll('#', '_H')
        .replaceAll('[', '_LB')
        .replaceAll(']', '_RB')
        .replaceAll('/', '_B');
    return encodedText;
  }

  @override
  String decodeFromDatabase({required String text}) {
    final String decodedText = text
        .replaceAll('_P', '.')
        .replaceAll('_S', '\$')
        .replaceAll('_H', '#')
        .replaceAll('_LB', '[')
        .replaceAll('_RB', ']')
        .replaceAll('_B', '/');
    return decodedText;
  }
}
