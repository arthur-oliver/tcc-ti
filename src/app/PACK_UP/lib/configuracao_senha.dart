import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pack_up/configuracao.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TelaConfigSenha extends StatefulWidget {
  @override
  State<TelaConfigSenha> createState() => _TelaConfigSenhaState();
}

class _TelaConfigSenhaState extends State<TelaConfigSenha> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  String? _userCNPJ;
  String? _userEmail;
  final TextEditingController _novaSenhaController = TextEditingController();
  bool _isPasswordVisible = false; // Variável para controlar a visibilidade da senha

  @override
  void initState() {
    super.initState();
    _carregarUsuario();
  }

  Future<void> _carregarUsuario() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userCNPJ = prefs.getString('userCNPJ');
      _userEmail = prefs.getString('userEmail');
    });
    if (_userCNPJ != null && _userEmail != null) {
      await _buscarSenhaUsuario(_userCNPJ!, _userEmail!);
    }
  }

  Future<void> _buscarSenhaUsuario(String cnpj, String email) async {
    try {
      var querySnapshot = await _db.collection('contatos')
          .where('cnpj', isEqualTo: cnpj)
          .where('email', isEqualTo: email)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var data = querySnapshot.docs.first.data();
        if (data['senha'] != null) {
          setState(() {
          });
        }
      } else {
        print("CNPJ e e-mail não encontrados.");
      }
    } catch (e) {
      print("Erro ao buscar senha: $e");
    }
  }

  Future<void> _atualizarSenha(String novaSenha) async {
    if (_userCNPJ != null && _userEmail != null) {
      try {
        var querySnapshot = await _db.collection('contatos')
            .where('cnpj', isEqualTo: _userCNPJ!)
            .where('email', isEqualTo: _userEmail!)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          String docId = querySnapshot.docs.first.id; // Obtém o ID do documento
          await _db.collection('contatos').doc(docId).update({'senha': novaSenha});
          print("Senha atualizada com sucesso!");
          setState(() {
          });
        }
      } catch (e) {
        print("Erro ao atualizar senha: $e");
      }
    }
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirmar"),
          content: const Text("Tem certeza de que deseja confirmar a mudança de senha?"),
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

                if (_novaSenhaController.text.isNotEmpty) {
                  await _atualizarSenha(_novaSenhaController.text);
                  _novaSenhaController.clear(); // Limpa o controlador de texto
                } else {
                  print("Nova senha não pode estar vazia.");
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
            SizedBox(height: 30),
            // Campo para nova senha
            TextFormField(
              controller: _novaSenhaController,
              keyboardType: TextInputType.text,
              obscureText: !_isPasswordVisible, // Alterna entre visível e não visível
              cursorColor: Color(0xFFdcbc75),
              decoration: InputDecoration(
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFdcbc75)),
                ),
                labelText: "Nova Senha",
                labelStyle: TextStyle(
                  color: Color(0xFFdcbc75),
                  fontWeight: FontWeight.w400,
                  fontSize: 20,
                ),
                suffixIcon: IconButton( // Ícone para mostrar/esconder senha
                  icon: Icon(
                    _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    color: Color(0xFFdcbc75),
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible; // Alterna a visibilidade
                    });
                  },
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
                  colors: [Color(0xFFdcbc75), Color(0xFFdcbc75)],
                ),
                borderRadius: BorderRadius.all(Radius.circular(5)),
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
                      Icon(Icons.lock, color: Colors.white),
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
