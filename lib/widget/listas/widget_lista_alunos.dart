import 'package:flutter/material.dart';
import '/configuracao/rotas.dart';

class WidgetListaAlunos extends StatelessWidget {
  const WidgetListaAlunos({super.key});

  @override
  Widget build(BuildContext context) {
    final alunos = [
      {'nome': 'João Silva', 'email': 'joao@email.com'},
      {'nome': 'Maria Oliveira', 'email': 'maria@email.com'},
    ];

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
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: alunos.length,
        itemBuilder: (context, index) {
          final aluno = alunos[index];
          return Card(
            color: Color.fromARGB(255, 36, 36, 36),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
              title: Text(
                aluno['nome']!,
                style: const TextStyle(color: Colors.amber),
              ),
              subtitle: Text(
                'E-mail: ${aluno['email']}',
                style: const TextStyle(color: Colors.amber),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.amber,
        foregroundColor: Colors.black,
        onPressed: () => Navigator.pushNamed(context, Rotas.cadastroAlunos),
        child: const Icon(Icons.add),
      ),
    );
  }
}
