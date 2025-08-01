import 'package:flutter/material.dart';
import 'package:projeto_ddm_ifpr/banco/sqlite/dao/dao_modalidade.dart';
import 'package:projeto_ddm_ifpr/configuracao/rotas.dart';
import 'package:projeto_ddm_ifpr/dto/dto_modalidade.dart';

class ListaModalidade extends StatefulWidget {
  const ListaModalidade({super.key});

  @override
  State<ListaModalidade> createState() => _ListaModalidadeState();
}

class _ListaModalidadeState extends State<ListaModalidade> {
  final _dao = DAOModalidade();
  Key _futureBuilderKey = UniqueKey();

  void _refreshList() {
    setState(() {
      _futureBuilderKey = UniqueKey();
    });
  }

  void _editModalidade(BuildContext context, DtoModalidade modalidade) async {
    try {
      final result = await Navigator.pushNamed(
        context,
        Rotas.cadastroModalidade,
        arguments: modalidade,
      );
      print('Editar modalidade: ${modalidade.nome}, Resultado: $result');
      if (context.mounted && result == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Modalidade ${modalidade.nome} atualizada'),
            backgroundColor: Colors.orange,
          ),
        );
        _refreshList();
      }
    } catch (e) {
      print('Erro ao abrir edição: $e');
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

  void _deleteModalidade(BuildContext context, DtoModalidade modalidade) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color.fromARGB(255, 36, 36, 36),
        title: const Text(
          'Confirmar Exclusão',
          style: TextStyle(color: Colors.amber),
        ),
        content: Text(
          'Deseja realmente excluir a modalidade ${modalidade.nome}?',
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
      if (modalidade.id != null) {
        await _dao.excluir(modalidade.id!);
        print('Excluir modalidade: ${modalidade.nome}, ID: ${modalidade.id}');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('Modalidade ${modalidade.nome} excluída com sucesso'),
              backgroundColor: Colors.red,
            ),
          );
          _refreshList();
        }
      }
    } catch (e) {
      print('Erro ao excluir modalidade: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao excluir modalidade: $e'),
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
          'Modalidades de Aula',
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: FutureBuilder<List<DtoModalidade>>(
        key: _futureBuilderKey,
        future: _dao.consultarTodos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.amber,
              ),
            );
          } else if (snapshot.hasError) {
            print('Erro no FutureBuilder: ${snapshot.error}');
            return Center(
              child: Text(
                'Erro ao carregar modalidades: ${snapshot.error}',
                style: const TextStyle(color: Colors.white),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'Nenhuma modalidade encontrada',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          final modalidades = snapshot.data!;
          print('Modalidades carregadas: ${modalidades.length}');
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: modalidades.length,
            itemBuilder: (context, index) {
              final modalidade = modalidades[index];
              return Card(
                color: const Color.fromARGB(255, 36, 36, 36),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  title: Text(
                    modalidade.nome,
                    style: const TextStyle(color: Colors.amber),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.orange),
                        onPressed: () => _editModalidade(context, modalidade),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteModalidade(context, modalidade),
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
        onPressed: () async {
          final result =
              await Navigator.pushNamed(context, Rotas.cadastroModalidade);
          print('Retorno do cadastro: $result');
          if (result == true) _refreshList();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
