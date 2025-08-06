import 'package:flutter/material.dart';
import 'package:projeto_ddm_ifpr/banco/sqlite/dao/dao_professor.dart';
import 'package:projeto_ddm_ifpr/configuracao/rotas.dart';
import 'package:projeto_ddm_ifpr/dto/dto_professor.dart';

class ListaProfessor extends StatefulWidget {
  const ListaProfessor({super.key});

  @override
  State<ListaProfessor> createState() => _ListaProfessorState();
}

class _ListaProfessorState extends State<ListaProfessor> {
  final DAOProfessor _dao = DAOProfessor();
  Key _futureBuilderKey = UniqueKey();

  void _refreshList() {
    setState(() {
      _futureBuilderKey = UniqueKey();
    });
  }

  void _alterarProfessor(BuildContext context, ProfessorDTO professor) async {
    try {
      await Navigator.pushNamed(
        context,
        Rotas.cadastroProfessores,
        arguments: professor,
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Professor ${professor.nome} pronto para edição'),
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

  void _excluirProfessor(BuildContext context, ProfessorDTO professor) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color.fromARGB(255, 36, 36, 36),
        title: const Text(
          'Confirmar Exclusão',
          style: TextStyle(color: Colors.amber),
        ),
        content: Text(
          'Deseja realmente excluir o professor ${professor.nome}?',
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
      await _dao.excluir(int.parse(professor.id!));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Professor ${professor.nome} excluído com sucesso'),
            backgroundColor: Colors.red,
          ),
        );
        _refreshList();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao excluir professor: $e'),
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
          'Professores',
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: FutureBuilder<List<ProfessorDTO>>(
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
                'Erro ao carregar professores: ${snapshot.error}',
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'Nenhum professor encontrado',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          final professores = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: professores.length,
            itemBuilder: (context, index) {
              final professor = professores[index];
              return Card(
                color: const Color.fromARGB(255, 36, 36, 36),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  title: Text(
                    professor.nome,
                    style: const TextStyle(color: Colors.amber),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Modalidades: ${professor.ModalidadesNomes?.join(", ") ?? "Nenhuma"}',
                        style: const TextStyle(color: Colors.white),
                      ),
                      Text(
                        'Telefone: ${professor.telefone}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.orange),
                        onPressed: () => _alterarProfessor(context, professor),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _excluirProfessor(context, professor),
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
        onPressed: () => Navigator.pushNamed(context, Rotas.cadastroProfessores)
            .then((_) => _refreshList()),
        child: const Icon(Icons.add),
      ),
    );
  }
}
