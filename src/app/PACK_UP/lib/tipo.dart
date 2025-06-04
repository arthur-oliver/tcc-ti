import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ItemEstoque {
  String nome;

  ItemEstoque({required this.nome});
}

class TelaTipo extends StatefulWidget {
  @override
  _TelaTipoState createState() => _TelaTipoState();
}

class _TelaTipoState extends State<TelaTipo> {
  FirebaseFirestore db = FirebaseFirestore.instance;
  List<ItemEstoque> _itensEstoque = [];
  TextEditingController _controleNomeItem = TextEditingController();
  String? _userCNPJ;

  @override
  void initState() {
    super.initState();
    _inicializarFirebase();
    _carregarCNPJUsuario();
  }

  Future<void> _inicializarFirebase() async {
    await Firebase.initializeApp();
  }

  Future<void> _carregarCNPJUsuario() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userCNPJ = prefs.getString('userCNPJ');
    });
    if (_userCNPJ != null) {
      _buscarTiposUsuario(_userCNPJ!);
    }
  }

  Future<void> _buscarTiposUsuario(String cnpj) async {
    var docRef = db.collection('tipo').doc(cnpj);
    var resultado = await docRef.get();
    if (resultado.exists) {
      var data = resultado.data();
      if (data != null && data['types'] != null) {
        setState(() {
          _itensEstoque = List<ItemEstoque>.from(
            data['types'].map((item) => ItemEstoque(nome: item['name'])),
          );
        });
      }
    }
  }

  void _enviarDados() {
    if (_userCNPJ != null) {
      db.collection("tipo").doc(_userCNPJ).set({
        "types": FieldValue.arrayUnion([{"name": _controleNomeItem.text}]),
      }, SetOptions(merge: true));
    }
  }

  void _adicionarItem(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Adicionar Tipo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _controleNomeItem,
                cursorColor: Color(0xFFdcbc75),
                decoration: InputDecoration(
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFdcbc75)),
                  ),
                  labelText: 'Nome',
                  labelStyle: TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar', style: TextStyle(color: Colors.white)),
              style: TextButton.styleFrom(
                backgroundColor: Color(0xFFdcbc75),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (_controleNomeItem.text.isNotEmpty) {
                  _enviarDados();
                  final nomeItem = _controleNomeItem.text;
                  setState(() {
                    _itensEstoque.add(ItemEstoque(nome: nomeItem));
                  });
                  _controleNomeItem.clear();
                  Navigator.of(context).pop();
                }
              },
              child: Text('Adicionar', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFdcbc75),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _removerItemDoBanco(String nome) async {
    if (_userCNPJ != null) {
      var collection = db.collection('tipo');
      await collection.doc(_userCNPJ).update({
        "types": FieldValue.arrayRemove([{"name": nome}]),
      }).then((_) {
        print("Excluído com sucesso!");
      }).catchError((error) {
        print("Erro ao excluir: $error");
      });
    }
  }

  Future<void> _removerItem(int index) async {
    final itemRemovido = _itensEstoque[index].nome;

    await _removerItemDoBanco(itemRemovido);
    
    setState(() {
      _itensEstoque.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "TIPO DE ESTOQUE",
          style: TextStyle(
            fontSize: 15,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.chevron_left_outlined, color: Colors.white),
        ),
        backgroundColor: Color(0xFFdcbc75),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("imagens/fundo_estoque.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: ListView.builder(
          itemCount: _itensEstoque.length,
          itemBuilder: (context, index) {
            final item = _itensEstoque[index];
            return Dismissible(
              key: Key(item.nome),
              onDismissed: (direction) {
                _removerItem(index);
              },
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
                          onPressed: () {
                            _removerItem(index);
                            Navigator.of(context).pop(true);
                          },
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
                  item.nome,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFFdcbc75),
        onPressed: () => _adicionarItem(context),
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
