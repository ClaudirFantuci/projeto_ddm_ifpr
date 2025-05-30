import 'package:flutter/material.dart';
import '../widget/widget_agendamento.dart';
import '../widget/widget_lista_academias.dart';
import '../widget/widget_lista_alunos.dart';
import '../widget/widget_menu.dart';
import '../configuracao/rotas.dart';
import '../widget/widget_cadastro_academias.dart';
import '../widget/widget_cadastro_alunos.dart';
import '../widget/widget_cadastro_objetivos.dart';
import '../widget/widget_cadastro_exercicios.dart';
import '../widget/widget_cadastro_treinos.dart';
// FAZER: import widget_detalhes_agendamento.dart

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
        Rotas.cadastroObjetivos: (context) => const WidgetCadastroObjetivos(),
        Rotas.cadastroExercicios: (context) => const WidgetCadastroExercicios(),
        Rotas.cadastroTreinos: (context) => const WidgetCadastroTreinos(),
        Rotas.listaAcademias: (context) => const WidgetListaAcademias(),
        Rotas.listaAlunos: (context) => const WidgetListaAlunos(),
        Rotas.agendamento: (context) => const WidgetAgendamento(),
        // FAZER: Rotas.detalhesAgendamento: (context) => const WidgetDetalhesAgendamento(),
      },
    );
  }
}
