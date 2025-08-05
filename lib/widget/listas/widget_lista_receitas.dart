import 'package:flutter/material.dart';
import 'package:projeto_ddm_ifpr/banco/sqlite/dao/dao_receita.dart';
import 'package:projeto_ddm_ifpr/configuracao/rotas.dart';
import 'package:projeto_ddm_ifpr/dto/dto_receita.dart';

class WidgetListaReceitas extends StatefulWidget {
  const WidgetListaReceitas({super.key});

  @override
  State<WidgetListaReceitas> createState() => _WidgetListaReceitasState();
}

class _WidgetListaReceitasState extends State<WidgetListaReceitas> {
  final DAOReceitas _dao = DAOReceitas();
  Key _futureBuilderKey = UniqueKey();

  void _refreshList() {
    setState(() {
      _futureBuilderKey = UniqueKey();
    });
  }

  void _alterarReceita(BuildContext context, ReceitaDTO receita) async {
    try {
      await Navigator.pushNamed(
        context,
        Rotas.cadastroReceitas,
        arguments: receita,
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Receita ${receita.nome} pronta para edição'),
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

  void _excluirReceita(BuildContext context, ReceitaDTO receita) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color.fromARGB(255, 36, 36, 36),
        title: const Text(
          'Confirmar Exclusão',
          style: TextStyle(color: Colors.amber),
        ),
        content: Text(
          'Deseja realmente excluir a receita ${receita.nome}?',
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
      await _dao.excluir(int.parse(receita.id!));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Receita ${receita.nome} excluída com sucesso'),
            backgroundColor: Colors.red,
          ),
        );
        _refreshList();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao excluir receita: $e'),
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
          'Lista de Receitas',
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: FutureBuilder<List<ReceitaDTO>>(
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
                'Erro ao carregar receitas: ${snapshot.error}',
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'Nenhuma receita encontrada',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          final receitas = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: receitas.length,
            itemBuilder: (context, index) {
              final receita = receitas[index];
              return Card(
                color: const Color.fromARGB(255, 36, 36, 36),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  title: Text(
                    receita.nome,
                    style: const TextStyle(color: Colors.amber),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ingredientes: ${receita.ingredientes.join(", ")}',
                        style: const TextStyle(color: Colors.white),
                      ),
                      Text(
                        'Dietas: ${receita.dietasNomes?.join(", ") ?? "Nenhuma"}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.orange),
                        onPressed: () => _alterarReceita(context, receita),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _excluirReceita(context, receita),
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
        onPressed: () => Navigator.pushNamed(context, Rotas.cadastroReceitas)
            .then((_) => _refreshList()),
        child: const Icon(Icons.add),
      ),
    );
  }
}
