import 'package:flutter/material.dart';
import 'package:pack_up/configuracao_senha.dart';
import 'package:pack_up/configuracao_senha_adm.dart';
import 'package:pack_up/configuracao_usuario.dart';
import 'package:pack_up/pagina_principal.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TelaConfig extends StatefulWidget {
  @override
  State<TelaConfig> createState() => _TelaConfigState();
}

class _TelaConfigState extends State<TelaConfig> {
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
    } else {
      print("Usuário não encontrado no Firestore.");
    }
  }

  _launchWhatsApp() async {
    String phoneNumber = '+12983172261';
    String message = 'Olá, estou precisando de suporte.';
    String url = 'https://wa.me/$phoneNumber/?text=${Uri.parse(message)}';

    try {
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Não foi possível abrir o WhatsApp.';
      }
    } catch (e) {
      print('Erro ao lançar o WhatsApp: $e');
    }
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
              MaterialPageRoute(builder: (context) => PaginaPrincipal()),
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
        alignment: Alignment.bottomCenter,
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).size.height / 4,
          left: 40,
          right: 40,
        ),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("imagens/fundo_config.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: ListView(
          children: [
            SizedBox(height: 10),
            _buildButton("Suporte", Icons.build_rounded, _launchWhatsApp),
            SizedBox(height: 10),
            _buildButton("Senha", Icons.lock, () {
              // Direcionar para a tela correta com base no tipo de usuário
              if (_userType == 'Administrador' || _userType == 'Desenvolvedor') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TelaConfigSenhaAdm()),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TelaConfigSenha()),
                );
              }
            }, isEnabled: true), // Todos podem acessar
            SizedBox(height: 10),
            _buildButton("Usuário", Icons.account_circle, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TelaConfigUsuario()),
              );
            }, isEnabled: _userType == 'Administrador' || _userType == 'Desenvolvedor' || _userType == 'Padrão'),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(String title, IconData icon, VoidCallback onPressed, {bool isEnabled = true}) {
    return Container(
      height: 40,
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0.3, 1],
          colors: [
            isEnabled ? Color(0xFFdcbc75) : Colors.grey,
            isEnabled ? Color(0xFFdcbc75) : Colors.grey,
          ],
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
}
