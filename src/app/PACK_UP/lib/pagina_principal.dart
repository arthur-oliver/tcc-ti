import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pack_up/configuracao.dart';
import 'package:pack_up/descricao.dart';
import 'package:pack_up/estoque.dart';
import 'package:pack_up/relatorio_adm.dart';
import 'package:pack_up/tipo.dart';
import 'package:pack_up/cadastro.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: PaginaPrincipal(),
    );
  }
}

class PaginaPrincipal extends StatefulWidget {
  @override
  State<PaginaPrincipal> createState() => _PaginaPrincipalState();
}

class _PaginaPrincipalState extends State<PaginaPrincipal> {
  String _userEmail = '';
  String _userCNPJ = '';
  String _userType = '';

  @override
  void initState() {
    super.initState();
    _carregarUsuario();
  }

  Future<void> _carregarUsuario() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _userEmail = prefs.getString('userEmail') ?? '';
    _userCNPJ = prefs.getString('userCNPJ') ?? '';

    print("Email carregado: $_userEmail");
    print("CNPJ carregado: $_userCNPJ");

    await _obterTipoUsuario();
  }

  Future<void> _obterTipoUsuario() async {
    if (_userEmail.isEmpty || _userCNPJ.isEmpty) {
      print("Email ou CNPJ não carregados corretamente.");
      return;
    }

    var collection = FirebaseFirestore.instance.collection('contatos');
    var result = await collection
        .where('email', isEqualTo: _userEmail)
        .where('cnpj', isEqualTo: _userCNPJ)
        .get();

    if (result.docs.isNotEmpty) {
      setState(() {
        _userType = result.docs.first['userType'];
      });

      print("Email: $_userEmail");
      print("CNPJ: $_userCNPJ");
      print("User Type: $_userType");
    } else {
      print("Usuário não encontrado no Firestore.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.bottomCenter,
        padding: EdgeInsets.only(top: 0, left: 40, right: 40),
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage("imagens/fundo_principal.jpg"),
              fit: BoxFit.cover),
        ),
        child: ListView(
          children: [
            SizedBox(
              width: 128,
              height: 128,
              child: Image.asset("imagens/LOGOTIPO.png"),
            ),
            SizedBox(height: 40),
            _buildButton("Produtos", Icons.outbox_rounded, () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => TelaEstoque()));
            }),
            SizedBox(height: 10),
            _buildButton("Tipo de Estoque", Icons.outbox_rounded, () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => TelaTipo()));
            }),
            SizedBox(height: 10),
            _buildButton("Relatório", Icons.align_horizontal_left_rounded, () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => TelaRelatorio()));
            }, isEnabled: _userType != 'Desenvolvedor' && _userType != 'Padrão'),
            SizedBox(height: 10),
            _buildButton("Configuração", Icons.settings, () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => TelaConfig()));
            }),
            SizedBox(height: 10),
            _buildButton("Cadastrar", Icons.person_add, () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => Cadastro()));
            }, isEnabled: _userType != 'Administrador' && _userType != 'Padrão'),
            SizedBox(height: 10),
            _buildButton("Sobre Nós", Icons.article_outlined, () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => TelaDesc()));
            }),
            SizedBox(height: 10),
            _buildButton("Sair/Logout", Icons.arrow_circle_left_outlined, () {
              _showLogoutDialog();
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(String title, IconData icon, VoidCallback onPressed, {bool isEnabled = true}) {
    return Container(
      height: 60,
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0.3, 1],
          colors: [isEnabled ? Color(0xFFdcbc75) : Colors.grey, isEnabled ? Color(0xFFdcbc75) : Colors.grey],
        ),
        borderRadius: BorderRadius.all(Radius.circular(5)),
      ),
      child: SizedBox.expand(
        child: TextButton(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isEnabled ? Colors.white : Colors.black54,
                  fontSize: 20,
                ),
                textAlign: TextAlign.left,
              ),
              Icon(icon, color: isEnabled ? Colors.white : Colors.black54),
            ],
          ),
          onPressed: isEnabled ? onPressed : null,
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirmar Logout"),
          content: const Text("Tem certeza de que deseja sair desta conta?"),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all<Color>(Colors.red),
              ),
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all<Color>(Colors.green),
              ),
              child: const Text("Sair"),
            ),
          ],
        );
      },
    );
  }
}
