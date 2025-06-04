import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Cadastro extends StatefulWidget {
  const Cadastro({Key? key}) : super(key: key);

  @override
  State<Cadastro> createState() => _CadastroState();
}

class _CadastroState extends State<Cadastro> {
  FirebaseFirestore db = FirebaseFirestore.instance;
  String? _userType;

  TextEditingController _usuarioController = TextEditingController();
  var _cnpjController = MaskedTextController(mask: '00.000.000/0000-00');
  TextEditingController _emailController = TextEditingController();
  TextEditingController _senhaController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "CADASTRO",
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
        actions: [
          IconButton(
            padding: EdgeInsets.only(right: 30),
            icon: Icon(Icons.filter_list, color: Colors.white),
            onPressed: () {
              _openFilterDrawer(context);
            },
          ),
        ],
      ),
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
              controller: _usuarioController,
              keyboardType: TextInputType.text,
              cursorColor: Color(0xFFdcbc75),
              decoration: InputDecoration(
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFdcbc75)),
                ),
                labelText: "Usuário",
                labelStyle: TextStyle(
                  color: Color(0xFFdcbc75),
                  fontWeight: FontWeight.w400,
                  fontSize: 20,
                ),
              ),
              style: TextStyle(fontSize: 20, color: Color(0xFFdcbc75)),
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: _cnpjController,
              keyboardType: TextInputType.number,
              cursorColor: Color(0xFFdcbc75),
              decoration: InputDecoration(
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFdcbc75)),
                ),
                labelText: "CNPJ",
                labelStyle: TextStyle(
                  color: Color(0xFFdcbc75),
                  fontWeight: FontWeight.w400,
                  fontSize: 20,
                ),
              ),
              style: TextStyle(fontSize: 20, color: Color(0xFFdcbc75)),
            ),
            SizedBox(height: 20),
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
            PasswordFormField(senhaController: _senhaController),
            SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Tipo de usuário:',
                  style: TextStyle(
                    color: Color(0xFFdcbc75),
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                Row(
                  children: <Widget>[
                    Radio<String>(
                      value: 'Administrador',
                      groupValue: _userType,
                      onChanged: (value) {
                        setState(() {
                          _userType = value;
                        });
                      },
                      activeColor: Color(0xFFdcbc75),
                    ),
                    Text(
                      'Administrador',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ],
                ),
                Row(
                  children: <Widget>[
                    Radio<String>(
                      value: 'Padrão',
                      groupValue: _userType,
                      onChanged: (value) {
                        setState(() {
                          _userType = value;
                        });
                      },
                      activeColor: Color(0xFFdcbc75),
                    ),
                    Text(
                      'Padrão',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ],
                ),
                Row(
                  children: <Widget>[
                    Radio<String>(
                      value: 'Desenvolvedor',
                      groupValue: _userType,
                      onChanged: (value) {
                        setState(() {
                          _userType = value;
                        });
                      },
                      activeColor: Color(0xFFdcbc75),
                    ),
                    Text(
                      'Desenvolvedor',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ],
                ),
              ],
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
                        "Criar conta",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 20,
                        ),
                        textAlign: TextAlign.left,
                      ),
                      Container(
                        child: SizedBox(
                          child: Icon(
                            Icons.account_circle,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  onPressed: () {
                    if (_userType == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Por favor, selecione um tipo de usuário.'),
                        ),
                      );
                      return;
                    }

                    // Validação de e-mail
                    if (!_isValidEmail(_emailController.text)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Por favor, insira um e-mail válido.'),
                        ),
                      );
                      return;
                    }

                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text("Confirmar Dados"),
                          content: const Text("Tem certeza que os campos foram preenchidos corretamente?"),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              style: ButtonStyle(
                                foregroundColor: MaterialStateProperty.all<Color>(Colors.red),
                              ),
                              child: const Text("Cancelar"),
                            ),
                            TextButton(
                              onPressed: () {
                                sendData();
                                Navigator.of(context).pop(); // Fecha o diálogo
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

  Future<void> sendData() async {
    // Verifica se o e-mail já existe no banco de dados
    QuerySnapshot querySnapshot = await db.collection("contatos")
        .where("email", isEqualTo: _emailController.text)
        .get();

    // Se já existe um documento com o mesmo e-mail
    if (querySnapshot.docs.isNotEmpty) {
      // Mostra a mensagem de erro
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('O e-mail digitado já existe, escolha outro!'),
        ),
      );
      return;
    }

    // Se não existe, prossegue com o cadastro
    String id = Uuid().v1();
    await db.collection("contatos").doc(id).set({
      "name": _usuarioController.text,
      "cnpj": _removeMaskFromCNPJ(_cnpjController.text), // Remove a máscara aqui
      "email": _emailController.text,
      "senha": _senhaController.text,
      "userType": _userType,
    });

    // Navega de volta à página principal ou onde for necessário
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  // Função para remover a máscara do CNPJ
  String _removeMaskFromCNPJ(String cnpj) {
    return cnpj.replaceAll(RegExp(r'[^\d]'), ''); // Remove qualquer coisa que não seja número
  }

  bool _isValidEmail(String email) {
    RegExp regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return regex.hasMatch(email);
  }

  void _openFilterDrawer(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Filtros"),
          content: Text("Aqui você pode adicionar opções de filtro."),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Fechar"),
            ),
          ],
        );
      },
    );
  }
}

// PasswordFormField widget
class PasswordFormField extends StatefulWidget {
  final TextEditingController senhaController;

  const PasswordFormField({Key? key, required this.senhaController}) : super(key: key);

  @override
  _PasswordFormFieldState createState() => _PasswordFormFieldState();
}

class _PasswordFormFieldState extends State<PasswordFormField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.senhaController,
      keyboardType: TextInputType.text,
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
