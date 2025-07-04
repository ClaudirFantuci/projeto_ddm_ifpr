import 'package:flutter/material.dart';
import 'package:projeto_ddm_ifpr/widget/widget_cadastro_equipamentos.dart';
import 'package:projeto_ddm_ifpr/widget/widget_lista_equipamentos.dart';
import 'package:projeto_ddm_ifpr/widget/widget_agendamento.dart';
import 'package:projeto_ddm_ifpr/widget/widget_lista_academias.dart'
    hide Scaffold;
import 'package:projeto_ddm_ifpr/widget/widget_lista_alunos.dart';
import 'package:projeto_ddm_ifpr/widget/widget_menu.dart';
import 'package:projeto_ddm_ifpr/configuracao/rotas.dart';
import 'package:projeto_ddm_ifpr/widget/widget_cadastro_academias.dart';
import 'package:projeto_ddm_ifpr/widget/widget_cadastro_alunos.dart';
import 'package:projeto_ddm_ifpr/widget/widget_cadastro_objetivos.dart';
import 'package:projeto_ddm_ifpr/widget/widget_cadastro_exercicios.dart';
import 'package:projeto_ddm_ifpr/widget/widget_cadastro_treinos.dart';
import 'package:projeto_ddm_ifpr/dto/dto_academia.dart';
import 'package:projeto_ddm_ifpr/dto/dto_equipamento.dart';
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
          case Rotas.cadastroEquipamento:
            final equipamento = settings.arguments as DTOEquipamento?;
            return MaterialPageRoute(
                builder: (_) =>
                    WidgetCadastroEquipamentos(equipamento: equipamento));
          case Rotas.cadastroTreinos:
            return MaterialPageRoute(
                builder: (_) => const WidgetCadastroTreinos());
          case Rotas.listaAcademias:
            return MaterialPageRoute(
                builder: (_) => const WidgetListaAcademias());
          case Rotas.listaEquipamentos:
            return MaterialPageRoute(builder: (_) => const ListaEquipamentos());
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
