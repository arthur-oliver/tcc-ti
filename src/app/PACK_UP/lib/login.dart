import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'pagina_principal.dart';

class Global {
  static String resultado = '';
}

class TelaLogin extends StatefulWidget {
  const TelaLogin({Key? key}) : super(key: key);

  @override
  State<TelaLogin> createState() => _TelaLoginState();
}

class _TelaLoginState extends State<TelaLogin> {
  FirebaseFirestore db = FirebaseFirestore.instance;

  TextEditingController _emailController = TextEditingController();
  TextEditingController _senhaController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.only(top: 0, left: 40, right: 40),
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
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              cursorColor: Color(0xFFdcbc75),
              decoration: InputDecoration(
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFdcbc75)),
                ),
                labelText: "E-mail",
                labelStyle: TextStyle(
                  color: Color(0xFFdcbc75),
                  fontWeight: FontWeight.w400,
                  fontSize: 20,
                ),
              ),
              style: TextStyle(fontSize: 20, color: Color(0xFFdcbc75)),
            ),
            SizedBox(height: 10),
            PasswordFormField(controller: _senhaController),
            SizedBox(height: 40),
            _buildLoginButton(),
            SizedBox(height: 20),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return Container(
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
                "Login",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
              Icon(Icons.account_circle, color: Colors.white),
            ],
          ),
          onPressed: _login,
        ),
      ),
    );
  }

  Future<void> _login() async {
    try {
      final email = _emailController.text.trim();
      final senha = _senhaController.text.trim();

      if (email.isEmpty || senha.isEmpty) {
        throw Exception('Por favor, preencha todos os campos!');
      }

      final querySnapshot = await db
          .collection('contatos')
          .where('email', isEqualTo: email)
          .where('senha', isEqualTo: senha)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception('Usuário ou senha incorretos!');
      }

      final userData = querySnapshot.docs.first;
      final cnpj = userData['cnpj'];

      await _saveLoginInfo(email, cnpj);
      await _logLoginToReport(email, cnpj); // Registro na coleção 'relatorio'
      _clearForm(); // Limpa o formulário após o login

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaginaPrincipal(),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: ${e.toString()}')),
      );
    }
  }

  void _clearForm() {
    _emailController.clear();
    _senhaController.clear();
  }

  Future<void> _saveLoginInfo(String email, String cnpj) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    DateTime now = DateTime.now();
    String formattedDate = "Logado: ${now.day}/${now.month}/${now.year} ${now.hour}:${now.minute}h";

    Global.resultado = "$formattedDate - $email";

    prefs.setString('loginTime', formattedDate);
    prefs.setString('userEmail', email);
    prefs.setString('userCNPJ', cnpj);
  }

  Future<void> _logLoginToReport(String email, String cnpj) async {
    DateTime now = DateTime.now();
    String loginTime = "Login: ${now.day}/${now.month}/${now.year} ${now.hour}:${now.minute}h - $email";

    await db.collection('relatorio').add({
      'cnpj': cnpj,
      'login': loginTime,
    });
  }
}

// Modificação do TextFormField da senha
class PasswordFormField extends StatefulWidget {
  final TextEditingController controller;

  PasswordFormField({required this.controller});

  @override
  _PasswordFormFieldState createState() => _PasswordFormFieldState();
}

class _PasswordFormFieldState extends State<PasswordFormField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscureText,
      cursorColor: Color(0xFFdcbc75),
      decoration: InputDecoration(
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFdcbc75)),
        ),
        labelText: "Senha",
        labelStyle: TextStyle(
          color: Color(0xFFdcbc75),
          fontWeight: FontWeight.w400,
          fontSize: 20,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureText ? Icons.visibility : Icons.visibility_off,
            color: _obscureText ? Colors.grey : Color(0xFFdcbc75),
          ),
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
        ),
      ),
      style: TextStyle(fontSize: 20, color: Color(0xFFdcbc75)),
    );
  }
}
