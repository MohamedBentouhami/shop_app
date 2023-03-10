import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/product.dart';
import '../providers/products.dart';

// ignore: use_key_in_widget_constructors
class EditProductScreen extends StatefulWidget {
  static const routeName = '/edit-product';

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _imageUrlController = TextEditingController();
  final _imageUrlFocusNode = FocusNode();
  final _form = GlobalKey<FormState>();
  var _editProduct = Product(
    id: null,
    title: '',
    description: '',
    price: 0,
    imageUrl: '',
  );

  var _initValues = {
    'title': '',
    'description': '',
    'price': '',
    'imageUrl': ''
  };

  var _isInit = true;
  var _isLoading = false;

  void _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      setState(() {});
    }
  }

  Future<void> _saveForm() async {
    var isValid = _form.currentState?.validate() as bool;
    if (!isValid) {
      return;
    }
    _form.currentState?.save();
    setState(() {
      _isLoading = true;
    });
    if (_editProduct.id != null) {
      await Provider.of<Products>(context, listen: false)
          .updateProduct(_editProduct.id.toString(), _editProduct);
    } else {
      try {
        await Provider.of<Products>(context, listen: false)
            .addProduct(_editProduct);
      } catch (error) {
        await showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
                  title: const Text('An error ocurred'),
                  content: const Text('Something went wrong'),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                        },
                        child: const Text('Okay'))
                  ],
                ));
      }
    }
    setState(() {
      _isLoading = false;
    });
    Navigator.of(context).pop();
  }

  @override
  void initState() {
    super.initState();
    _imageUrlFocusNode.addListener(_updateImageUrl);
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final productId = ModalRoute.of(context)?.settings.arguments;
      if (productId != null) {
        _editProduct = Provider.of<Products>(context, listen: false)
            .findById(productId as String);
        _initValues = {
          'title': _editProduct.title,
          'description': _editProduct.description,
          'price': _editProduct.price.toString(),
          //'imageUrl': _editProduct.imageUrl
        };
        _imageUrlController.text = _editProduct.imageUrl;
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    _imageUrlFocusNode.dispose();
    _imageUrlController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit title'),
        actions: [
          IconButton(
            onPressed: _saveForm,
            icon: const Icon(Icons.save),
          )
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                  key: _form,
                  child: ListView(
                    children: [
                      TextFormField(
                        initialValue: _initValues['title'],
                        decoration: const InputDecoration(labelText: 'Title'),
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please provide a correct value';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _editProduct = Product(
                              id: _editProduct.id,
                              title: value as String,
                              description: _editProduct.description,
                              price: _editProduct.price,
                              imageUrl: _editProduct.imageUrl,
                              isFavorite: _editProduct.isFavorite);
                        },
                      ),
                      TextFormField(
                          initialValue: _initValues['price'],
                          decoration: const InputDecoration(labelText: 'Price'),
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Please enter a price";
                            }
                            var price = double.tryParse(value);
                            if (price == null) {
                              return "Enter a valid number";
                            }
                            if (price <= 0) {
                              return "Please enter a number greater than 0";
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _editProduct = Product(
                                id: _editProduct.id,
                                title: _editProduct.title,
                                description: _editProduct.description,
                                price: double.parse(value.toString()),
                                imageUrl: _editProduct.imageUrl,
                                isFavorite: _editProduct.isFavorite);
                          }),
                      TextFormField(
                          initialValue: _initValues['description'],
                          decoration:
                              const InputDecoration(labelText: 'Description'),
                          maxLines: 3,
                          keyboardType: TextInputType.multiline,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter a description';
                            }
                            if (value.length < 10) {
                              return 'Should be at least 10 characters long.';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _editProduct = Product(
                                id: _editProduct.id,
                                title: _editProduct.title,
                                description: value as String,
                                price: _editProduct.price,
                                imageUrl: _editProduct.imageUrl,
                                isFavorite: _editProduct.isFavorite);
                          }),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            height: 100,
                            width: 100,
                            margin: const EdgeInsets.only(top: 8, right: 10),
                            decoration: BoxDecoration(
                                border:
                                    Border.all(width: 1, color: Colors.grey)),
                            child: _imageUrlController.text.isEmpty
                                ? const Text('Enter a url')
                                : FittedBox(
                                    child: Image.network(
                                      _imageUrlController.text,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                          ),
                          Expanded(
                            child: TextFormField(
                                //initialValue: _initValues['imaegUrl'],
                                decoration: const InputDecoration(
                                    labelText: 'Image URL'),
                                keyboardType: TextInputType.url,
                                textInputAction: TextInputAction.done,
                                onEditingComplete: () {
                                  setState(() {});
                                },
                                controller: _imageUrlController,
                                focusNode: _imageUrlFocusNode,
                                onFieldSubmitted: (_) {
                                  _saveForm();
                                },
                                validator: (value) {
                                  if (value == null) {
                                    return 'Enter a valid value';
                                  }
                                  if (value.isEmpty) {
                                    return 'Please enter an image URL';
                                  }
                                  if (value.startsWith('htpp') &&
                                      value.startsWith('https')) {
                                    return 'Please enter a valid URL';
                                  }
                                  if (!value.endsWith('png') &&
                                      !value.endsWith('jpg') &&
                                      !value.endsWith('jpeg')) {
                                    return 'Please enter a valid image URL';
                                  }

                                  return null;
                                },
                                onSaved: (value) {
                                  _editProduct = Product(
                                      id: _editProduct.id,
                                      title: _editProduct.title,
                                      description: _editProduct.description,
                                      price: _editProduct.price,
                                      imageUrl: value as String,
                                      isFavorite: _editProduct.isFavorite);
                                }),
                          )
                        ],
                      )
                    ],
                  )),
            ),
    );
  }
}
