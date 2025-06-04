import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pack_up/configuracao.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TelaConfigSenhaAdm extends StatefulWidget {
  @override
  State<TelaConfigSenhaAdm> createState() => _TelaConfigSenhaAdmState();
}

class _TelaConfigSenhaAdmState extends State<TelaConfigSenhaAdm> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  String? _userCNPJ;
  String? _selectedUserId;
  String? _selectedUserEmail;
  final TextEditingController _novaSenhaController = TextEditingController();
  bool _senhaVisivel = false; // Variável para controlar a visibilidade da senha

  @override
  void initState() {
    super.initState();
    _carregarUsuario();
  }

  Future<void> _carregarUsuario() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userCNPJ = prefs.getString('userCNPJ');
    });
  }

  Future<void> _atualizarSenha(String novaSenha) async {
    if (_selectedUserId != null) {
      try {
        await _db.collection('contatos').doc(_selectedUserId!).update({'senha': novaSenha});
        print("Senha atualizada com sucesso!");
        _novaSenhaController.clear();
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
              onPressed: () => Navigator.of(context).pop(),
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all<Color>(Colors.red),
              ),
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                if (_novaSenhaController.text.isNotEmpty) {
                  await _atualizarSenha(_novaSenhaController.text);
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

  Future<void> _escolherUsuario() async {
    if (_userCNPJ != null) {
      var querySnapshot = await _db.collection('contatos')
          .where('cnpj', isEqualTo: _userCNPJ!)
          .get();

      List<String> usuarios = querySnapshot.docs.map((doc) => doc['email'] as String).toList();

      if (usuarios.isNotEmpty) {
        String? selectedUser = await showDialog<String>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Escolher Usuário"),
              content: Container(
                width: double.maxFinite,
                child: ListView.builder(
                  itemCount: usuarios.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(usuarios[index]),
                      onTap: () {
                        Navigator.of(context).pop(usuarios[index]);
                      },
                    );
                  },
                ),
              ),
            );
          },
        );

        if (selectedUser != null) {
          await _buscarSenhaUsuarioPorEmail(selectedUser);
        }
      } else {
        print("Nenhum usuário encontrado.");
      }
    }
  }

  Future<void> _buscarSenhaUsuarioPorEmail(String email) async {
    try {
      var querySnapshot = await _db.collection('contatos')
          .where('email', isEqualTo: email)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var data = querySnapshot.docs.first.data();
        if (data['senha'] != null) {
          setState(() {
            _selectedUserEmail = email;
            _selectedUserId = querySnapshot.docs.first.id;
          });
        }
      } else {
        print("Usuário não encontrado.");
      }
    } catch (e) {
      print("Erro ao buscar senha: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "CONFIGURAÇÕES ADM",
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
            Text(
              _selectedUserEmail != null ? "E-mail: $_selectedUserEmail" : "Nenhum usuário escolhido",
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 10),
            // Campo Senha
            TextFormField(
              controller: _novaSenhaController,
              keyboardType: TextInputType.text,
              obscureText: !_senhaVisivel, // variável para controlar a visibilidade
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
                suffixIcon: IconButton(
                  icon: Icon(
                    _senhaVisivel ? Icons.visibility : Icons.visibility_off,
                    color: Color(0xFFdcbc75),
                  ),
                  onPressed: () {
                    setState(() {
                      _senhaVisivel = !_senhaVisivel; // Alterna a visibilidade
                    });
                  },
                ),
              ),
              style: TextStyle(fontSize: 20, color: Color(0xFFdcbc75)),
            ),
            SizedBox(height: 20),
            // Botão para escolher usuário
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
                        "Escolher Usuário",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                      Icon(Icons.person, color: Colors.white),
                    ],
                  ),
                  onPressed: _escolherUsuario,
                ),
              ),
            ),
            SizedBox(height: 20),
            // Botão para confirmar a alteração da senha
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
