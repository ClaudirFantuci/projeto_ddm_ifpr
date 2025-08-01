import 'package:flutter/material.dart';
import 'package:projeto_ddm_ifpr/banco/sqlite/dao/dao_aluno.dart';
import 'package:projeto_ddm_ifpr/configuracao/rotas.dart';
import 'package:projeto_ddm_ifpr/dto/dto_aluno.dart';

class WidgetListaAlunos extends StatefulWidget {
  const WidgetListaAlunos({super.key});

  @override
  State<WidgetListaAlunos> createState() => _WidgetListaAlunosState();
}

class _WidgetListaAlunosState extends State<WidgetListaAlunos> {
  final _dao = DAOAluno();
  Key _futureBuilderKey = UniqueKey();

  void _refreshList() {
    setState(() {
      _futureBuilderKey = UniqueKey();
    });
  }

  void _alterarAluno(BuildContext context, AlunoDTO aluno) async {
    try {
      await Navigator.pushNamed(
        context,
        Rotas.cadastroAlunos,
        arguments: aluno,
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Aluno ${aluno.nome} pronto para edição'),
            backgroundColor: Colors.orange,
          ),
        );
        _refreshList();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao abrir edição: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _excluirAluno(BuildContext context, AlunoDTO aluno) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color.fromARGB(255, 36, 36, 36),
        title: const Text(
          'Confirmar Exclusão',
          style: TextStyle(color: Colors.amber),
        ),
        content: Text(
          'Deseja realmente excluir o aluno ${aluno.nome}?',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child:
                const Text('Cancelar', style: TextStyle(color: Colors.amber)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _dao.excluir(int.parse(aluno.id!));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Aluno ${aluno.nome} excluído com sucesso'),
            backgroundColor: Colors.red,
          ),
        );
        _refreshList();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao excluir aluno: $e'),
            backgroundColor: Colors.red,
          ),
        );
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
          'Lista de Alunos',
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: FutureBuilder<List<AlunoDTO>>(
        key: _futureBuilderKey,
        future: _dao.consultarTodos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.amber),
            );
          } else if (snapshot.hasError) {
            print('Erro no FutureBuilder: ${snapshot.error}');
            return Center(
              child: Text(
                'Erro ao carregar alunos: ${snapshot.error}',
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'Nenhum aluno encontrado',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          final alunos = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: alunos.length,
            itemBuilder: (context, index) {
              final aluno = alunos[index];
              return Card(
                color: const Color.fromARGB(255, 36, 36, 36),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  title: Text(
                    aluno.nome,
                    style: const TextStyle(color: Colors.amber),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Objetivo Principal: ${aluno.objetivoPrincipalNome ?? "Nenhum"}',
                        style: const TextStyle(color: Colors.white),
                      ),
                      Text(
                        'Objetivos Adicionais: ${aluno.objetivosAdicionaisNomes?.join(", ") ?? "Nenhum"}',
                        style: const TextStyle(color: Colors.white),
                      ),
                      Text(
                        'Telefone: ${aluno.telefone}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.orange),
                        onPressed: () => _alterarAluno(context, aluno),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _excluirAluno(context, aluno),
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
        onPressed: () => Navigator.pushNamed(context, Rotas.cadastroAlunos)
            .then((_) => _refreshList()),
        child: const Icon(Icons.add),
      ),
    );
  }
}
