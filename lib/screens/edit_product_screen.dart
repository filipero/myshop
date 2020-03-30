import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/product.dart';
import '../providers/products.dart';

class TitleFieldValidator {
  static String validate(String value) {
    if (value.isEmpty) {
      return 'Informe um título para o produto.';
    }
    return null;
  }
}

class PriceFieldValidator {
  static String validate(String value) {
    if (value.isEmpty) {
      return 'Informe um preço.';
    }
    if (double.tryParse(value) == null) {
      return 'Informe um número válido.';
    }
    if (double.parse(value) <= 0) {
      return 'Informe um número maior que zero.';
    }
    return null;
  }
}

class DescriptionFieldValidator {
  static String validate(String value) {
    if (value.isEmpty) {
      return 'Informe uma descrição para o produto.';
    }
    return null;
  }
}

class ImageUrlFieldValidator {
  static String validate(String value) {
    if (value.isEmpty) {
      return 'Informe a Url de uma imagem.';
    }
    if (!value.startsWith('http') && !value.startsWith('https')) {
      return 'Informe uma Url válida.';
    }
    if (!value.endsWith('.png') &&
        !value.endsWith('.jpg') &&
        !value.endsWith('.jpeg')) {
      return 'Informe uma Url válida.';
    }

    return null;
  }
}

class EditProductScreen extends StatefulWidget {
  static const routeName = '/editproduct';
  EditProductScreen({Key key}) : super(key: key);

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlFocusNode = FocusNode();
  final _imageUrlControler = TextEditingController();
  final _form = GlobalKey<FormState>();
  var _editedProduct =
      Product(id: null, title: '', description: 'null', price: 0, imgUrl: '');
  @override
  void initState() {
    // TODO: implement initState
    _imageUrlFocusNode.addListener(_updateImageUrl);
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    _imageUrlControler.dispose();
    _priceFocusNode.dispose();
    _imageUrlFocusNode.dispose();
    _descriptionFocusNode.dispose();
    super.dispose();
  }

  void _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      if (_imageUrlControler.text.isEmpty ||
          (!_imageUrlControler.text.startsWith('http') &&
              !_imageUrlControler.text.startsWith('https')) ||
          (!_imageUrlControler.text.endsWith('.png') &&
              !_imageUrlControler.text.endsWith('.jpg') &&
              !_imageUrlControler.text.endsWith('.jpeg'))) {
        return;
      }

      setState(() {});
    }
  }

  void _saveForm() {
    final isValid = _form.currentState.validate();
    if (!isValid) {
      return;
    }
    _form.currentState.save();
    Provider.of<Products>(context, listen: false).addProduct(_editedProduct);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Novo produto'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveForm,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _form,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Título',
                  ),
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) {
                    FocusScope.of(context).requestFocus(_priceFocusNode);
                  },
                  onSaved: (value) {
                    _editedProduct = Product(
                      title: value,
                      id: null,
                      price: _editedProduct.price,
                      description: _editedProduct.description,
                      imgUrl: _editedProduct.imgUrl,
                    );
                  },
                  validator: TitleFieldValidator.validate,
                ),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Preço',
                  ),
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.number,
                  focusNode: _priceFocusNode,
                  onFieldSubmitted: (_) {
                    FocusScope.of(context).requestFocus(_descriptionFocusNode);
                  },
                  onSaved: (value) {
                    _editedProduct = Product(
                      title: _editedProduct.title,
                      id: null,
                      price: double.parse(value),
                      description: _editedProduct.description,
                      imgUrl: _editedProduct.imgUrl,
                    );
                  },
                  validator: PriceFieldValidator.validate,
                ),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Descrição',
                  ),
                  focusNode: _descriptionFocusNode,
                  maxLines: 3,
                  keyboardType: TextInputType.multiline,
                  onSaved: (value) {
                    _editedProduct = Product(
                      title: _editedProduct.title,
                      id: null,
                      price: _editedProduct.price,
                      description: value,
                      imgUrl: _editedProduct.imgUrl,
                    );
                  },
                  validator: DescriptionFieldValidator.validate,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Container(
                      width: 100,
                      height: 100,
                      margin: EdgeInsets.only(
                        top: 8,
                        right: 10,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 1,
                          color: Colors.grey,
                        ),
                      ),
                      child: _imageUrlControler.text.isEmpty
                          ? Text('Adicione uma imagem')
                          : FittedBox(
                              child: Image.network(
                                _imageUrlControler.text,
                                fit: BoxFit.cover,
                              ),
                            ),
                    ),
                    Expanded(
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Url da imagem',
                        ),
                        keyboardType: TextInputType.url,
                        textInputAction: TextInputAction.done,
                        focusNode: _imageUrlFocusNode,
                        controller: _imageUrlControler,
                        onSaved: (value) {
                          _editedProduct = Product(
                            title: _editedProduct.title,
                            id: null,
                            price: _editedProduct.price,
                            description: _editedProduct.description,
                            imgUrl: value,
                          );
                        },
                        validator: ImageUrlFieldValidator.validate,
                        onFieldSubmitted: (_) => _saveForm(),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
