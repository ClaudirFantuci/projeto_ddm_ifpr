import 'package:flutter/material.dart';
import '../widget/widget_agendamento.dart';
import '../widget/widget_lista_academias.dart' hide Scaffold;
import '../widget/widget_lista_alunos.dart';
import '../widget/widget_menu.dart';
import '../configuracao/rotas.dart';
import '../widget/widget_cadastro_academias.dart';
import '../widget/widget_cadastro_alunos.dart';
import '../widget/widget_cadastro_objetivos.dart';
import '../widget/widget_cadastro_exercicios.dart';
import '../widget/widget_cadastro_treinos.dart';
import '../dto/dto_academia.dart';
// FAZER: import widget_detalhes_agendamento.dart

class Aplicativo extends StatelessWidget {
  const Aplicativo({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gerenciamento de aulas',
      debugShowCheckedModeBanner: false,
      initialRoute: Rotas.home,
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case Rotas.home:
            return MaterialPageRoute(builder: (_) => const WidgetMenu());
          case Rotas.cadastroAcademias:
            final academia = settings.arguments as DTOAcademia?;
            return MaterialPageRoute(
                builder: (_) => WidgetCadastroAcademias(academia: academia));
          case Rotas.cadastroAlunos:
            return MaterialPageRoute(
                builder: (_) => const WidgetCadastroAlunos());
          case Rotas.cadastroObjetivos:
            return MaterialPageRoute(
                builder: (_) => const WidgetCadastroObjetivos());
          case Rotas.cadastroExercicios:
            return MaterialPageRoute(
                builder: (_) => const WidgetCadastroExercicios());
          case Rotas.cadastroTreinos:
            return MaterialPageRoute(
                builder: (_) => const WidgetCadastroTreinos());
          case Rotas.listaAcademias:
            return MaterialPageRoute(
                builder: (_) => const WidgetListaAcademias());
          case Rotas.listaAlunos:
            return MaterialPageRoute(builder: (_) => const WidgetListaAlunos());
          case Rotas.agendamento:
            return MaterialPageRoute(builder: (_) => const WidgetAgendamento());
          // FAZER: case Rotas.detalhesAgendamento:
          //   return MaterialPageRoute(builder: (_) => const WidgetDetalhesAgendamento());
          default:
            return MaterialPageRoute(
              builder: (_) => const Scaffold(
                body: Center(child: Text('Rota não encontrada')),
              ),
            );
        }
      },
    );
  }
}
