import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pack_up/configuracao.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TelaConfigUsuario extends StatefulWidget {
  @override
  State<TelaConfigUsuario> createState() => _TelaConfigUsuarioState();
}

class _TelaConfigUsuarioState extends State<TelaConfigUsuario> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  String? _userName;
  String? _userCNPJ;
  String? _userEmail;
  final TextEditingController _novoUsuarioController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _carregarUsuario();
  }

  Future<void> _carregarUsuario() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userCNPJ = prefs.getString('userCNPJ');
      _userEmail = prefs.getString('userEmail'); // Carrega o e-mail do usuário
    });
    if (_userCNPJ != null && _userEmail != null) {
      await _buscarUsuario(_userCNPJ!, _userEmail!);
    }
  }

  Future<void> _buscarUsuario(String cnpj, String email) async {
    try {
      var querySnapshot = await _db.collection('contatos')
          .where('cnpj', isEqualTo: cnpj)
          .where('email', isEqualTo: email)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var data = querySnapshot.docs.first.data();
        if (data['name'] != null) {
          setState(() {
            _userName = data['name'];
          });
        }
      } else {
        print("Usuário não encontrado.");
      }
    } catch (e) {
      print("Erro ao buscar usuário: $e");
    }
  }

  Future<void> _atualizarUsuario(String novoUsuario) async {
    if (_userCNPJ != null && _userEmail != null) {
      try {
        var querySnapshot = await _db.collection('contatos')
            .where('cnpj', isEqualTo: _userCNPJ!)
            .where('email', isEqualTo: _userEmail!)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          String docId = querySnapshot.docs.first.id; // Obtém o ID do documento
          await _db.collection('contatos').doc(docId).update({'name': novoUsuario});
          print("Usuário atualizado com sucesso!");
          setState(() {
            _userName = novoUsuario; // Atualiza o nome exibido
          });
        } else {
          print("Usuário não encontrado para atualização.");
        }
      } catch (e) {
        print("Erro ao atualizar usuário: $e");
      }
    }
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirmar"),
          content: const Text("Tem certeza de que deseja confirmar a mudança de usuário?"),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // Fecha o diálogo
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all<Color>(Colors.red),
              ),
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Fecha o diálogo

                if (_novoUsuarioController.text.isNotEmpty) {
                  await _atualizarUsuario(_novoUsuarioController.text);
                  _novoUsuarioController.clear(); // Limpa o controlador de texto
                } else {
                  print("Novo usuário não pode estar vazio.");
                }
              },
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all<Color>(Colors.green),
              ),
              child: const Text("Confirmar"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "CONFIGURAÇÕES",
          style: TextStyle(
            fontSize: 15,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => TelaConfig()),
            );
          },
          icon: Icon(
            Icons.chevron_left_outlined,
            color: Colors.white,
          ),
        ),
        leadingWidth: 80,
        backgroundColor: Color(0xFFdcbc75),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 40),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("imagens/fundo_login.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: ListView(
          children: <Widget>[
            SizedBox(
              width: 128,
              height: 128,
              child: Image.asset("imagens/LOGOTIPO.png"),
            ),
            SizedBox(height: 20),
            // Campo para exibir o usuário atual
            Text(
              _userName != null ? "Usuário Atual: $_userName" : "Usuário não encontrado",
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 10),
            // Campo para novo usuário
            TextFormField(
              controller: _novoUsuarioController,
              keyboardType: TextInputType.text,
              cursorColor: Color(0xFFdcbc75),
              decoration: InputDecoration(
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFdcbc75)),
                ),
                labelText: "Novo Usuário",
                labelStyle: TextStyle(
                  color: Color(0xFFdcbc75),
                  fontWeight: FontWeight.w400,
                  fontSize: 20,
                ),
              ),
              style: TextStyle(fontSize: 20, color: Color(0xFFdcbc75)),
            ),
            SizedBox(height: 40),
            Container(
              height: 60,
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  stops: [0.3, 1],
                  colors: [
                    Color(0xFFdcbc75),
                    Color(0xFFdcbc75),
                  ],
                ),
                borderRadius: BorderRadius.all(
                  Radius.circular(5),
                ),
              ),
              child: SizedBox.expand(
                child: TextButton(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        "Confirmar",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                      Icon(
                        Icons.account_circle,
                        color: Colors.white,
                      )
                    ],
                  ),
                  onPressed: () {
                    _showConfirmationDialog();
                  },
                ),
              ),
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
