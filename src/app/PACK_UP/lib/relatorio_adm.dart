import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TelaRelatorio extends StatefulWidget {
  @override
  State<TelaRelatorio> createState() => _TelaRelatorioState();
}

class _TelaRelatorioState extends State<TelaRelatorio> {
  String? _userCNPJ;
  List<String> _logins = []; // Lista para armazenar os logins

  @override
  void initState() {
    super.initState();
    _carregarCNPJUsuario();
  }

  Future<void> _carregarCNPJUsuario() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userCNPJ = prefs.getString('userCNPJ');
    });
    _carregarLogins(); // Carregar logins após obter o CNPJ
  }

  Future<void> _carregarLogins() async {
    if (_userCNPJ != null) {
      // Substitua 'collectionName' pelo nome correto da sua coleção
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('relatorio')
          .where('cnpj', isEqualTo: _userCNPJ)
          .get();

      setState(() {
        _logins = snapshot.docs.map((doc) => doc['login'] as String).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Relatório",
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
          top: 0,
          left: 40,
          right: 40,
        ),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("imagens/fundo_desc.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: ListView(
          children: [
            SizedBox(
              width: 128,
              height: 128,
              child: Image.asset("imagens/LOGOTIPO.png"),
            ),
            SizedBox(height: 40),
            Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Color(0xFFdcbc75),
                  ),
                  child: ExpansionTile(
                    backgroundColor: Color(0xFFdcbc75),
                    title: Text(
                      "Usuários (data/horário) Logins",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                    trailing: Icon(
                      Icons.arrow_drop_down,
                      color: Colors.white,
                    ),
                    children: _logins.map((login) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(32),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(32),
                            color: Color(0xFFdcbc75),
                          ),
                          child: ListTile(
                            title: Text(
                              login, // Exibe cada login
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
