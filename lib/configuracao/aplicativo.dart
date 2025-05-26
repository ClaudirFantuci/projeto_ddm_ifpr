import 'package:flutter/material.dart';
import 'package:projeto_ddm_ifpr/widget/widget_agendamento.dart';
import '../widget/widget_lista_academias.dart';
import '../widget/widget_lista_alunos.dart';
import '../widget/widget_menu.dart';
import "/configuracao/rotas.dart";
import '/widget/widget_cadastro_academias.dart';
import '/widget/widget_cadastro_alunos.dart';

class Aplicativo extends StatelessWidget {
  const Aplicativo({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gerenciamento de aulas',
      debugShowCheckedModeBanner: false,
      initialRoute: Rotas.home,
      routes: {
        Rotas.home: (context) => const WidgetMenu(),
        Rotas.cadastroAcademias: (context) => const WidgetCadastroAcademias(),
        Rotas.cadastroAlunos: (context) => const WidgetCadastroAlunos(),
        Rotas.listaAcademias: (context) => const WidgetListaAcademias(),
        Rotas.listaAlunos: (context) => const WidgetListaAlunos(),
        Rotas.agendamento: (context) => const WidgetAgendamento(),
        //FAZER
        //Rotas.detalhesAgendamento:
        //   (context) => const WidgetDetalhesAgendamento(),
      },
    );
  }
}
