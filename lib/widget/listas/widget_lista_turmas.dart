import 'package:flutter/material.dart';
import 'package:projeto_ddm_ifpr/banco/sqlite/dao/dao_turma.dart';
import 'package:projeto_ddm_ifpr/configuracao/rotas.dart';
import 'package:projeto_ddm_ifpr/dto/dto_turma.dart';

class WidgetListaTurmas extends StatefulWidget {
  const WidgetListaTurmas({super.key});

  @override
  State<WidgetListaTurmas> createState() => _WidgetListaTurmasState();
}

class _WidgetListaTurmasState extends State<WidgetListaTurmas> {
  final DAOTurma _dao = DAOTurma();
  Key _futureBuilderKey = UniqueKey();

  void _refreshList() {
    setState(() {
      _futureBuilderKey = UniqueKey();
    });
  }

  void _alterarTurma(BuildContext context, TurmaDTO turma) async {
    try {
      await Navigator.pushNamed(
        context,
        Rotas.cadastroTurmas,
        arguments: turma,
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Turma ${turma.nome} pronta para edição'),
            backgroundColor: Colors.orange,
          ),
        );
        _refreshList();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao editar turma: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _excluirTurma(BuildContext context, int id) async {
    bool confirm = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Confirmar Exclusão'),
            content: const Text('Deseja realmente excluir esta turma?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Excluir'),
              ),
            ],
          ),
        ) ??
        false;

    if (confirm) {
      try {
        await _dao.excluir(id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Turma excluída com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
          _refreshList();
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao excluir turma: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: const Text(
          'Lista de Turmas',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: FutureBuilder<List<TurmaDTO>>(
        key: _futureBuilderKey,
        future: _dao.consultarTodos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: Colors.amber));
          } else if (snapshot.hasError) {
            print('Erro no FutureBuilder: ${snapshot.error}');
            return Center(
              child: Text(
                'Erro ao carregar turmas: ${snapshot.error}',
                style: const TextStyle(color: Colors.white),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'Nenhuma turma encontrada',
                style: TextStyle(color: Colors.white),
              ),
            );
          }
          final turmas = snapshot.data!;
          return ListView.builder(
            itemCount: turmas.length,
            itemBuilder: (context, index) {
              final turma = turmas[index];
              return Card(
                color: Colors.grey[850],
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  title: Text(
                    turma.nome,
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Horário: ${turma.diaSemana ?? 'Não definido'}, ${turma.horarioInicio ?? 'Não definido'}-${turma.horarioFim ?? 'Não definido'}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      Text(
                        'Professores: ${turma.professoresNomes?.toSet().join(', ') ?? 'Nenhum'}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      Text(
                        'Alunos: ${turma.alunosNomes?.toSet().join(', ') ?? 'Nenhum'}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.amber),
                        onPressed: () => _alterarTurma(context, turma),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () =>
                            _excluirTurma(context, int.parse(turma.id!)),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.amber,
        foregroundColor: Colors.black,
        onPressed: () => Navigator.pushNamed(context, Rotas.cadastroTurmas)
            .then((_) => _refreshList()),
        child: const Icon(Icons.add),
      ),
    );
  }
}
