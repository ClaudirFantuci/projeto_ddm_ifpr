import 'package:flutter/material.dart';
import 'package:projeto_ddm_ifpr/banco/sqlite/dao/dao_agendamento.dart';
import 'package:projeto_ddm_ifpr/configuracao/rotas.dart';
import 'package:projeto_ddm_ifpr/dto/dto_agendamento.dart';

class ListaAgendamento extends StatefulWidget {
  const ListaAgendamento({super.key});

  @override
  State<ListaAgendamento> createState() => _ListaAgendamentoState();
}

class _ListaAgendamentoState extends State<ListaAgendamento> {
  final DAOAgendamento _dao = DAOAgendamento();
  Key _futureBuilderKey = UniqueKey();

  void _refreshList() {
    setState(() {
      _futureBuilderKey = UniqueKey();
    });
  }

  void _alterarAgendamento(
      BuildContext context, DTOAgendamento agendamento) async {
    try {
      await Navigator.pushNamed(
        context,
        Rotas.cadastroAgendamento,
        arguments: agendamento,
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Agendamento ${agendamento.turmaNome ?? agendamento.alunosNomes?.join(", ")} pronto para edição'),
            backgroundColor: Colors.orange,
          ),
        );
        _refreshList();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao editar agendamento: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _excluirAgendamento(BuildContext context, String id) async {
    bool confirm = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Confirmar Exclusão'),
            content: const Text('Deseja realmente excluir este agendamento?'),
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
              content: Text('Agendamento excluído com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
          _refreshList();
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao excluir agendamento: $e'),
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
          'Lista de Agendamentos',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: FutureBuilder<List<DTOAgendamento>>(
        key: _futureBuilderKey,
        future: _dao.consultarTodos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.amber),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Erro ao carregar agendamentos: ${snapshot.error}',
                style: const TextStyle(color: Colors.white),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'Nenhum agendamento encontrado',
                style: TextStyle(color: Colors.white),
              ),
            );
          }
          final agendamentos = snapshot.data!;
          return ListView.builder(
            itemCount: agendamentos.length,
            itemBuilder: (context, index) {
              final agendamento = agendamentos[index];
              return Card(
                color: Colors.grey[850],
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  title: Text(
                    agendamento.turmaNome ??
                        agendamento.alunosNomes?.join(', ') ??
                        'Sem nome',
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dia: ${agendamento.diaSemana}, ${agendamento.horarioInicio}-${agendamento.horarioFim}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      Text(
                        'Academia: ${agendamento.academiaNome ?? 'Não definida'}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      Text(
                        'Alunos: ${agendamento.alunosNomes?.toSet().join(', ') ?? 'Nenhum'}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.orange),
                        onPressed: () =>
                            _alterarAgendamento(context, agendamento),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () =>
                            _excluirAgendamento(context, agendamento.id!),
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
        onPressed: () => Navigator.pushNamed(context, Rotas.cadastroAgendamento)
            .then((_) => _refreshList()),
        child: const Icon(Icons.add),
      ),
    );
  }
}
