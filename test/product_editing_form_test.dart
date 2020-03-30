import 'package:flutter_test/flutter_test.dart';
import '../lib/screens/edit_product_screen.dart';

void main() {
  test('Título', () {
    var result = TitleFieldValidator.validate('');
    expect(result, 'Informe um título para o produto.');
  });

  test('Preço vazio', () {
    var result = PriceFieldValidator.validate('');
    expect(result, 'Informe um preço.');
  });

  test('Preço não numérico', () {
    var result = PriceFieldValidator.validate('oi');
    expect(result, 'Informe um número válido.');
  });

  test('Preço negativo', () {
    var result = PriceFieldValidator.validate('-50');
    expect(result, 'Informe um número maior que zero.');
  });

  test('Descrição vazia', () {
    var result = DescriptionFieldValidator.validate('');
    expect(result, 'Informe uma descrição para o produto.');
  });

  test('Url vazia', () {
    var result = ImageUrlFieldValidator.validate('');
    expect(result, 'Informe a Url de uma imagem.');
  });

  test('Url não começa com http ou https', () {
    var result = ImageUrlFieldValidator.validate('image.png');
    expect(result, 'Informe uma Url válida.');
  });

  test('Url não termina com .png ou .jpg ou .jpeg', () {
    var result = ImageUrlFieldValidator.validate('https://google.com');
    expect(result, 'Informe uma Url válida.');
  });
}
