import 'package:flutter/material.dart';
import 'package:projeto_ddm_ifpr/dto/dto_professor.dart';
import 'package:projeto_ddm_ifpr/widget/listas/widget_lista_modalidades.dart';
import 'package:projeto_ddm_ifpr/widget/widget_cadastro_equipamentos.dart';
import 'package:projeto_ddm_ifpr/widget/listas/widget_lista_equipamentos.dart';
import 'package:projeto_ddm_ifpr/widget/widget_agendamento.dart';
import 'package:projeto_ddm_ifpr/widget/listas/widget_lista_academias.dart'
    hide Scaffold;
import 'package:projeto_ddm_ifpr/widget/listas/widget_lista_alunos.dart';
import 'package:projeto_ddm_ifpr/widget/widget_cadastro_modalidades.dart';
import 'package:projeto_ddm_ifpr/widget/widget_menu.dart';
import 'package:projeto_ddm_ifpr/configuracao/rotas.dart';
import 'package:projeto_ddm_ifpr/widget/widget_cadastro_academias.dart';
import 'package:projeto_ddm_ifpr/widget/widget_cadastro_alunos.dart';
import 'package:projeto_ddm_ifpr/widget/widget_cadastro_objetivos.dart';
import 'package:projeto_ddm_ifpr/widget/widget_cadastro_exercicios.dart';
import 'package:projeto_ddm_ifpr/widget/widget_cadastro_treinos.dart';
import 'package:projeto_ddm_ifpr/widget/listas/widget_lista_exercicios.dart';
import 'package:projeto_ddm_ifpr/widget/listas/widgete_listaobjetivos.dart';
import 'package:projeto_ddm_ifpr/widget/listas/widget_lista_treinos.dart';
import 'package:projeto_ddm_ifpr/widget/listas/widget_lista_professor.dart';
import 'package:projeto_ddm_ifpr/widget/widget_cadastro_professores.dart';
import 'package:projeto_ddm_ifpr/widget/widget_listas.dart';
import 'package:projeto_ddm_ifpr/widget/widget_cadastros.dart';
import 'package:projeto_ddm_ifpr/dto/dto_academia.dart';
import 'package:projeto_ddm_ifpr/dto/dto_equipamento.dart';
import 'package:projeto_ddm_ifpr/dto/dto_objetivo.dart';
import 'package:projeto_ddm_ifpr/dto/dto_exercicio.dart';
import 'package:projeto_ddm_ifpr/dto/dto_treino.dart';
import 'package:projeto_ddm_ifpr/dto/dto_aluno.dart';
import 'package:projeto_ddm_ifpr/dto/dto_modalidade.dart';

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
            final aluno = settings.arguments as AlunoDTO?;
            return MaterialPageRoute(
                builder: (_) => WidgetCadastroAlunos(aluno: aluno));
          case Rotas.cadastroObjetivos:
            final objetivo = settings.arguments as DTOObjetivo?;
            return MaterialPageRoute(
                builder: (_) => WidgetCadastroObjetivos(objetivo: objetivo));
          case Rotas.cadastroExercicios:
            final exercicio = settings.arguments as DTOExercicio?;
            return MaterialPageRoute(
                builder: (_) => WidgetCadastroExercicios(exercicio: exercicio));
          case Rotas.cadastroTreinos:
            final treino = settings.arguments as DTOTreino?;
            return MaterialPageRoute(
                builder: (_) => WidgetCadastroTreinos(treino: treino));
          case Rotas.cadastroEquipamento:
            final equipamento = settings.arguments as DTOEquipamento?;
            return MaterialPageRoute(
                builder: (_) =>
                    WidgetCadastroEquipamentos(equipamento: equipamento));
          case Rotas.cadastroModalidade:
            final modalidade = settings.arguments as DtoModalidade?;
            return MaterialPageRoute(
                builder: (_) =>
                    WidgetCadastroModalidades(modalidade: modalidade));
          case Rotas.cadastroProfessores:
            final professor = settings.arguments as ProfessorDTO?;
            return MaterialPageRoute(
                builder: (_) =>
                    WidgetCadastroProfessores(professor: professor));
          case Rotas.listaAcademias:
            return MaterialPageRoute(
                builder: (_) => const WidgetListaAcademias());
          case Rotas.listaEquipamentos:
            return MaterialPageRoute(builder: (_) => const ListaEquipamentos());
          case Rotas.listaAlunos:
            return MaterialPageRoute(builder: (_) => const WidgetListaAlunos());
          case Rotas.listaObjetivos:
            return MaterialPageRoute(
                builder: (_) => const WidgetListaObjetivos());
          case Rotas.listaExercicios:
            return MaterialPageRoute(
                builder: (_) => const WidgetListaExercicios());
          case Rotas.listaTreinos:
            return MaterialPageRoute(
                builder: (_) => const WidgetListaTreinos());
          case Rotas.listaModalidades:
            return MaterialPageRoute(builder: (_) => const ListaModalidade());
          case Rotas.listaProfessores:
            return MaterialPageRoute(builder: (_) => const ListaProfessor());
          case Rotas.agendamento:
            return MaterialPageRoute(builder: (_) => const WidgetAgendamento());
          case Rotas.listas:
            return MaterialPageRoute(builder: (_) => const WidgetListas());
          case Rotas.cadastros:
            return MaterialPageRoute(builder: (_) => const WidgetCadastros());
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
