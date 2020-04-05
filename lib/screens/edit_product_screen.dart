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
  var _editedProduct = Product(
    id: null,
    title: '',
    description: 'null',
    price: 0,
    imgUrl: '',
  );

  var _initValues = {
    'title': '',
    'description': '',
    'price': '',
    'imgUrl': '',
  };
  var _isInit = true;
  var _isLoading = false;

  @override
  void initState() {
    _imageUrlFocusNode.addListener(_updateImageUrl);
    super.initState();
  }

  @override
  void dispose() {
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

  Future<void> _saveForm() async {
    final isValid = _form.currentState.validate();
    if (!isValid) {
      return;
    }
    _form.currentState.save();
    setState(() {
      _isLoading = true;
    });

    if (_editedProduct.id != null) {
      Provider.of<Products>(context, listen: false)
          .updateProduct(_editedProduct.id, _editedProduct);
    } else {
      try {
        await Provider.of<Products>(context, listen: false)
            .addProduct(_editedProduct);
      } catch (error) {
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('Ocorreu um erro!'),
            content: Text('Algo deu errado.'),
            actions: <Widget>[
              FlatButton(
                child: Text('Ok'),
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
              ),
            ],
          ),
        );
      }
    }
    setState(() {
      _isLoading = false;
    });
    Navigator.of(context).pop();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final productId = ModalRoute.of(context).settings.arguments as String;
      if (productId != null) {
        _editedProduct =
            Provider.of<Products>(context, listen: false).findById(productId);
        _initValues = {
          'title': _editedProduct.title,
          'description': _editedProduct.description,
          'price': _editedProduct.price.toString(),
          // 'imgUrl': '',
        };
        _imageUrlControler.text = _editedProduct.imgUrl;
      }
    }
    _isInit = false;
    super.didChangeDependencies();
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
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _form,
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        initialValue: _initValues['title'],
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
                              id: _editedProduct.id,
                              price: _editedProduct.price,
                              description: _editedProduct.description,
                              imgUrl: _editedProduct.imgUrl,
                              isFavorite: _editedProduct.isFavorite);
                        },
                        validator: TitleFieldValidator.validate,
                      ),
                      TextFormField(
                        initialValue: _initValues['price'],
                        decoration: InputDecoration(
                          labelText: 'Preço',
                        ),
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.number,
                        focusNode: _priceFocusNode,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context)
                              .requestFocus(_descriptionFocusNode);
                        },
                        onSaved: (value) {
                          _editedProduct = Product(
                              title: _editedProduct.title,
                              id: _editedProduct.id,
                              price: double.parse(value),
                              description: _editedProduct.description,
                              imgUrl: _editedProduct.imgUrl,
                              isFavorite: _editedProduct.isFavorite);
                        },
                        validator: PriceFieldValidator.validate,
                      ),
                      TextFormField(
                        initialValue: _initValues['description'],
                        decoration: InputDecoration(
                          labelText: 'Descrição',
                        ),
                        focusNode: _descriptionFocusNode,
                        maxLines: 3,
                        keyboardType: TextInputType.multiline,
                        onSaved: (value) {
                          _editedProduct = Product(
                              title: _editedProduct.title,
                              id: _editedProduct.id,
                              price: _editedProduct.price,
                              description: value,
                              imgUrl: _editedProduct.imgUrl,
                              isFavorite: _editedProduct.isFavorite);
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
                                    id: _editedProduct.id,
                                    price: _editedProduct.price,
                                    description: _editedProduct.description,
                                    imgUrl: value,
                                    isFavorite: _editedProduct.isFavorite);
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
