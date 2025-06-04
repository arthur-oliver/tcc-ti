import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';

class StockItem {
  String name;
  String tipo;
  int quantity;
  int min;

  StockItem({
    required this.name,
    required this.tipo,
    required this.quantity,
    required this.min,
  });
}

class TelaEstoque extends StatefulWidget {
  @override
  _StockScreenState createState() => _StockScreenState();
}

class _StockScreenState extends State<TelaEstoque> {
  FirebaseFirestore db = FirebaseFirestore.instance;
  List<StockItem> _stockItems = [];
  List<StockItem> _filteredStockItems = [];
  TextEditingController _itemNameController = TextEditingController();
  TextEditingController _itemQuantityController = TextEditingController();
  TextEditingController _itemMinController = TextEditingController();
  TextEditingController _adjustmentValueController = TextEditingController();
  String? _itemTipo;
  List<String> _filterTypes = [];
  List<String> _tipos = [];
  String? _userCNPJ;

  @override
  void initState() {
    super.initState();
    _loadUserCNPJ();
  }

  Future<void> _loadUserCNPJ() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userCNPJ = prefs.getString('userCNPJ');
    });
    if (_userCNPJ != null) {
      await _fetchTipos();
      await _fetchStockItems();
    }
  }

  Future<void> _fetchTipos() async {
    try {
      var docRef = db.collection('tipo').doc(_userCNPJ);
      var resultado = await docRef.get();
      if (resultado.exists && resultado.data() != null) {
        setState(() {
          _tipos = List<String>.from(resultado.data()!['types'].map((type) => type['name'] ?? ''));
        });
      }
    } catch (e) {
      print('Erro ao buscar tipos: $e');
    }
  }

  Future<void> _fetchStockItems() async {
    if (_userCNPJ != null) {
      var docRef = db.collection('stock').doc(_userCNPJ);
      var result = await docRef.get();
      if (result.exists && result.data() != null) {
        setState(() {
          _stockItems = List<StockItem>.from(
            result.data()!['items'].map((item) => StockItem(
              name: item['name'],
              tipo: item['tipo'],
              quantity: item['quantity'],
              min: item['min'],
            )),
          );
          _filteredStockItems = _stockItems;
        });
      }
    }
  }

  void _clearFormFields() {
    _itemNameController.clear();
    _itemQuantityController.clear();
    _itemMinController.clear();
    _adjustmentValueController.clear();
    _itemTipo = null;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "PRODUTOS",
          style: TextStyle(fontSize: 15, color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.chevron_left_outlined, color: Colors.white),
        ),
        backgroundColor: Color(0xFFdcbc75),
        actions: [
          IconButton(
            padding: EdgeInsets.only(right: 30),
            icon: Icon(Icons.filter_list, color: Colors.white),
            onPressed: () => _openFilterDrawer(context),
          ),
        ],
      ),
      body: Container(
        alignment: Alignment.bottomCenter,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("imagens/fundo_estoque.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: ListView.builder(
          itemCount: _filteredStockItems.length,
          itemBuilder: (context, index) {
            final item = _filteredStockItems[index];
            return Dismissible(
              key: Key(item.name),
              onDismissed: (direction) => _removeItem(index),
              confirmDismiss: (DismissDirection direction) async {
                return await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text("Confirmar exclusão"),
                      content: const Text("Tem certeza de que deseja excluir este item?"),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text("Cancelar", style: TextStyle(color: Colors.red)),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text("Excluir", style: TextStyle(color: Colors.green)),
                        ),
                      ],
                    );
                  },
                );
              },
              background: Container(
                color: Colors.red,
                child: Icon(Icons.delete, color: Colors.white),
                alignment: Alignment.centerRight,
                padding: EdgeInsets.only(right: 20.0),
              ),
              child: ListTile(
                title: Text(
                  item.name,
                  style: TextStyle(color: Color(0xFFdcbc75), fontSize: 18),
                ),
                subtitle: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Quantidade: ${item.quantity}\nMínimo: ${item.min}\nTipo: ${item.tipo}',
                        style: TextStyle(
                          color: item.quantity < item.min ? Colors.yellow : Colors.white,
                        ),
                      ),
                    ),
                    if (item.quantity < item.min)
                      Icon(Icons.warning, color: Colors.yellow),
                  ],
                ),
                onTap: () => _editItem(context, item),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFFdcbc75),
        onPressed: () => _addItem(context),
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _openFilterDrawer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              height: 200,
              decoration: BoxDecoration(color: Color(0xFFdcbc75)),
              child: ListView(
                children: _tipos.map((tipo) => _buildFilterTile(tipo, setState)).toList(),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFilterTile(String type, StateSetter setState) {
    return ListTile(
      title: Text(type, style: TextStyle(color: Colors.white)),
      trailing: Checkbox(
        value: _filterTypes.contains(type),
        onChanged: (value) {
          setState(() {
            if (value!) {
              _filterTypes.add(type);
            } else {
              _filterTypes.remove(type);
            }
            _updateFilteredItems();
          });
        },
        activeColor: Colors.white,
        checkColor: Color(0xFFdcbc75),
        side: BorderSide(color: Colors.white),
      ),
    );
  }

  void _updateFilteredItems() {
    setState(() {
      if (_filterTypes.isNotEmpty) {
        _filteredStockItems = _stockItems.where((item) => _filterTypes.contains(item.tipo)).toList();
      } else {
        _filteredStockItems = _stockItems;
      }
    });
  }

  void _addItem(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Adicionar Item'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _itemNameController,
                decoration: InputDecoration(labelText: 'Nome'),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _itemQuantityController,
                      decoration: InputDecoration(labelText: 'Quantidade'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () => _showAdjustmentDialog(context, true),
                  ),
                  IconButton(
                    icon: Icon(Icons.remove),
                    onPressed: () => _showAdjustmentDialog(context, false),
                  ),
                ],
              ),
              TextFormField(
                controller: _itemMinController,
                decoration: InputDecoration(labelText: 'Mínimo'),
                keyboardType: TextInputType.number,
              ),
              DropdownButtonFormField<String>(
                hint: Text("Selecione o tipo"),
                value: _itemTipo,
                items: _tipos.map((tipo) {
                  return DropdownMenuItem(child: Text(tipo), value: tipo);
                }).toList(),
                onChanged: (String? value) {
                  setState(() {
                    _itemTipo = value;
                  });
                },
                decoration: InputDecoration(labelText: "Tipo"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancelar', style: TextStyle(color: Colors.white)),
              style: TextButton.styleFrom(backgroundColor: Color(0xFFdcbc75)),
            ),
            ElevatedButton(
              onPressed: () {
                final itemName = _itemNameController.text;
                final itemQuantity = int.tryParse(_itemQuantityController.text) ?? 0;
                final itemMin = int.tryParse(_itemMinController.text) ?? 0;

                if (itemName.isNotEmpty && _itemTipo != null) {
                  final newItem = StockItem(
                    name: itemName,
                    tipo: _itemTipo!,
                    quantity: itemQuantity,
                    min: itemMin,
                  );

                  _addItemToFirestore(newItem);
                  _clearFormFields();
                  Navigator.of(context).pop();
                }
              },
              child: Text('Adicionar', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFdcbc75)),
            ),
          ],
        );
      },
    );
  }

  void _showAdjustmentDialog(BuildContext context, bool isAddition) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(isAddition ? 'Adicionar Quantidade' : 'Subtrair Quantidade'),
          content: TextField(
            controller: _adjustmentValueController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'Valor'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                final adjustmentValue = int.tryParse(_adjustmentValueController.text);
                if (adjustmentValue != null) {
                  int currentQuantity = int.tryParse(_itemQuantityController.text) ?? 0;
                  if (isAddition) {
                    _itemQuantityController.text = (currentQuantity + adjustmentValue).toString();
                  } else if (currentQuantity - adjustmentValue >= 0) {
                    _itemQuantityController.text = (currentQuantity - adjustmentValue).toString();
                  }
                }
                _adjustmentValueController.clear();
                Navigator.of(context).pop();
              },
              child: Text('Confirmar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  void _editItem(BuildContext context, StockItem item) {
    _itemNameController.text = item.name;
    _itemQuantityController.text = item.quantity.toString();
    _itemMinController.text = item.min.toString();
    _itemTipo = item.tipo;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Editar Item'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _itemNameController,
                decoration: InputDecoration(labelText: 'Nome'),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _itemQuantityController,
                      decoration: InputDecoration(labelText: 'Quantidade'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () => _showAdjustmentDialog(context, true),
                  ),
                  IconButton(
                    icon: Icon(Icons.remove),
                    onPressed: () => _showAdjustmentDialog(context, false),
                  ),
                ],
              ),
              TextFormField(
                controller: _itemMinController,
                decoration: InputDecoration(labelText: 'Mínimo'),
                keyboardType: TextInputType.number,
              ),
              DropdownButtonFormField<String>(
                hint: Text("Selecione o tipo"),
                value: _itemTipo,
                items: _tipos.map((tipo) {
                  return DropdownMenuItem(child: Text(tipo), value: tipo);
                }).toList(),
                onChanged: (String? value) {
                  setState(() {
                    _itemTipo = value;
                  });
                },
                decoration: InputDecoration(labelText: "Tipo"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancelar', style: TextStyle(color: Colors.white)),
              style: TextButton.styleFrom(backgroundColor: Color(0xFFdcbc75)),
            ),
            ElevatedButton(
              onPressed: () {
                final updatedItem = StockItem(
                  name: _itemNameController.text,
                  tipo: _itemTipo ?? '',
                  quantity: int.tryParse(_itemQuantityController.text) ?? 0,
                  min: int.tryParse(_itemMinController.text) ?? 0,
                );

                if (updatedItem.name.isNotEmpty && updatedItem.tipo.isNotEmpty) {
                  _updateItemInFirestore(item, updatedItem);
                  _clearFormFields();
                  Navigator.of(context).pop();
                }
              },
              child: Text('Atualizar', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFdcbc75)),
            ),
          ],
        );
      },
    );
  }

  void _addItemToFirestore(StockItem item) {
    if (_userCNPJ != null) {
      db.collection('stock').doc(_userCNPJ).set({
        'items': FieldValue.arrayUnion([{
          'name': item.name,
          'tipo': item.tipo,
          'quantity': item.quantity,
          'min': item.min,
        }])
      }, SetOptions(merge: true)).then((_) {
        setState(() {
          _stockItems.add(item);
          _filteredStockItems = _stockItems;
        });
      }).catchError((error) {
        print("Erro ao adicionar item: $error");
      });
    }
  }

  void _updateItemInFirestore(StockItem oldItem, StockItem updatedItem) {
    if (_userCNPJ != null) {
      final itemRef = db.collection('stock').doc(_userCNPJ);
      itemRef.update({
        'items': FieldValue.arrayRemove([{
          'name': oldItem.name,
          'tipo': oldItem.tipo,
          'quantity': oldItem.quantity,
          'min': oldItem.min,
        }])
      }).then((_) {
        itemRef.update({
          'items': FieldValue.arrayUnion([{
            'name': updatedItem.name,
            'tipo': updatedItem.tipo,
            'quantity': updatedItem.quantity,
            'min': updatedItem.min,
          }])
        }).then((_) {
          setState(() {
            final index = _stockItems.indexOf(oldItem);
            if (index != -1) {
              _stockItems[index] = updatedItem;
              _filteredStockItems = _stockItems;
            }
          });
        });
      }).catchError((error) {
        print("Erro ao atualizar item: $error");
      });
    }
  }

  void _removeItem(int index) {
    final item = _filteredStockItems[index];
    if (_userCNPJ != null) {
      final itemRef = db.collection('stock').doc(_userCNPJ);
      itemRef.update({
        'items': FieldValue.arrayRemove([{
          'name': item.name,
          'tipo': item.tipo,
          'quantity': item.quantity,
          'min': item.min,
        }])
      }).then((_) {
        setState(() {
          _stockItems.remove(item);
          _filteredStockItems = _stockItems;
        });
      }).catchError((error) {
        print("Erro ao excluir item: $error");
      });
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(home: TelaEstoque()));
}
