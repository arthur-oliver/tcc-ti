import 'package:flutter/material.dart';

class TelaDesc extends StatefulWidget {
  @override
  State<TelaDesc> createState() => _TelaDescState();
}

class _TelaDescState extends State<TelaDesc> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "DESCRIÇÃO",
            style: TextStyle(
              fontSize: 15,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
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
              SizedBox(
                height: 40,
              ),
              Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Color(0xFFdcbc75),
                    ),
                    child: ExpansionTile(
                      backgroundColor: Color(0xFFdcbc75),
                      title: Text(
                        "O que é o PACKUP?",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                      trailing: Icon(
                        Icons.arrow_drop_down,
                        color: Colors.white,
                      ),
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(32),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(32),
                              color: Color(0xFFdcbc75),
                            ),
                            child: ListTile(
                              title: Text(
                                "O PACKUP é um aplicativo móvel projetado para simplificar e aprimorar o controle de estoque em diversos tipos de negócios. Com uma interface intuitiva e amigável, os usuários podem cadastrar produtos de forma rápida e fácil, atribuindo categorias e definindo limites mínimos e atuais para cada item.",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                      onExpansionChanged: (bool expanded) {},
                    ),
                  )
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Color(0xFFdcbc75),
                    ),
                    child: ExpansionTile(
                      backgroundColor: Color(0xFFdcbc75),
                      title: Text(
                        "Para que serve o PACKUP?",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                      trailing: Icon(
                        Icons.arrow_drop_down,
                        color: Colors.white,
                      ),
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(32),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(32),
                              color: Color(0xFFdcbc75),
                            ),
                            child: ListTile(
                              title: Text(
                                "Uma das principais características do PACK UP é a sua flexibilidade e capacidade de personalização. Os usuários podem criar divisões específicas dentro do estoque, organizar produtos por categorias e nomeá-las conforme suas necessidades individuais. Além disso, o aplicativo oferece a funcionalidade de edição em tempo real, permitindo que os usuários atualizem informações sobre os produtos a qualquer momento.",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                      onExpansionChanged: (bool expanded) {},
                    ),
                  )
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Color(0xFFdcbc75),
                    ),
                    child: ExpansionTile(
                      backgroundColor: Color(0xFFdcbc75),
                      title: Text(
                        "Missão",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                      trailing: Icon(
                        Icons.arrow_drop_down,
                        color: Colors.white,
                      ),
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(32),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(32),
                              color: Color(0xFFdcbc75),
                            ),
                            child: ListTile(
                              title: Text(
                                "Nossa missão é simplificar a gestão de estoques por meio de uma plataforma intuitiva e acessível, capacitando empresas a otimizar seus processos logísticos. Buscamos reduzir perdas, aumentar a eficiência e proporcionar uma organização clara e eficaz dos produtos, contribuindo para o crescimento sustentável dos nossos clientes.",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                      onExpansionChanged: (bool expanded) {},
                    ),
                  )
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Color(0xFFdcbc75),
                    ),
                    child: ExpansionTile(
                      backgroundColor: Color(0xFFdcbc75),
                      title: Text(
                        "Visão",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                      trailing: Icon(
                        Icons.arrow_drop_down,
                        color: Colors.white,
                      ),
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(32),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(32),
                              color: Color(0xFFdcbc75),
                            ),
                            child: ListTile(
                              title: Text(
                                "Nossa visão é nos tornarmos a plataforma de referência em gestão de estoques, reconhecida pela inovação e pela excelência no atendimento ao cliente. Almejamos transformar a experiência de logística e armazenamento, oferecendo soluções que atendam às necessidades de negócios de todos os tamanhos, promovendo eficiência e agilidade em um mercado em constante evolução.",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                      onExpansionChanged: (bool expanded) {},
                    ),
                  )
                ],
              ),
            ],
          ),
        ));
  }
}
