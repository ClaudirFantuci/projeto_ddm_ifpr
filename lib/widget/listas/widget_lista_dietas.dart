import 'package:flutter/material.dart';
import 'package:projeto_ddm_ifpr/banco/sqlite/dao/dao_dieta.dart';
import 'package:projeto_ddm_ifpr/configuracao/rotas.dart';
import 'package:projeto_ddm_ifpr/dto/dto_dieta.dart';

class WidgetListaDietas extends StatefulWidget {
  const WidgetListaDietas({super.key});

  @override
  State<WidgetListaDietas> createState() => _WidgetListaDietasState();
}

class _WidgetListaDietasState extends State<WidgetListaDietas> {
  final _dao = DAODieta();
  Key _futureBuilderKey = UniqueKey();

  void _refreshList() {
    setState(() {
      _futureBuilderKey = UniqueKey();
    });
  }

  void _alterarDieta(BuildContext context, DietaDTO dieta) async {
    try {
      await Navigator.pushNamed(
        context,
        Rotas.cadastroDietas,
        arguments: dieta,
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Dieta ${dieta.nome} pronta para edição'),
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

  void _excluirDieta(BuildContext context, DietaDTO dieta) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color.fromARGB(255, 36, 36, 36),
        title: const Text(
          'Confirmar Exclusão',
          style: TextStyle(color: Colors.amber),
        ),
        content: Text(
          'Deseja realmente excluir a dieta ${dieta.nome}?',
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
      await _dao.excluir(int.parse(dieta.id!));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Dieta ${dieta.nome} excluída com sucesso'),
            backgroundColor: Colors.red,
          ),
        );
        _refreshList();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao excluir dieta: $e'),
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
          'Lista de Dietas',
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: FutureBuilder<List<DietaDTO>>(
        key: _futureBuilderKey,
        future: _dao.consultarTodos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(
                child: Text('Erro ao carregar dietas',
                    style: TextStyle(color: Colors.white)));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
                child: Text('Nenhuma dieta encontrada',
                    style: TextStyle(color: Colors.white)));
          }

          final dietas = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: dietas.length,
            itemBuilder: (context, index) {
              final dieta = dietas[index];
              return Card(
                color: const Color.fromARGB(255, 36, 36, 36),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  title: Text(
                    dieta.nome,
                    style: const TextStyle(color: Colors.amber),
                  ),
                  subtitle: Text(
                    'Receitas: ${dieta.receitasNomes?.join(", ") ?? "Nenhuma"}',
                    style: const TextStyle(color: Colors.white),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.orange),
                        onPressed: () => _alterarDieta(context, dieta),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _excluirDieta(context, dieta),
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
        onPressed: () => Navigator.pushNamed(context, Rotas.cadastroDietas)
            .then((_) => _refreshList()),
        child: const Icon(Icons.add),
      ),
    );
  }
}
