import 'package:flutter/material.dart';
import '/configuracao/rotas.dart';

class WidgetListaAcademias extends StatelessWidget {
  const WidgetListaAcademias({super.key});

  @override
  Widget build(BuildContext context) {
    final academias = [
      {'nome': 'Academia 1', 'cidade': 'Paranavaí'},
      {'nome': 'Academia 2', 'cidade': 'Maringá'},
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: const Text(
          'Lista de Academias',
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: academias.length,
        itemBuilder: (context, index) {
          final academia = academias[index];
          return Card(
            color: Color.fromARGB(255, 36, 36, 36),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
              title: Text(
                academia['nome']!,
                style: const TextStyle(color: Colors.amber),
              ),
              subtitle: Text(
                'Cidade: ${academia['cidade']}',
                style: const TextStyle(color: Colors.amber),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.amber,
        foregroundColor: Colors.black,
        onPressed: () => Navigator.pushNamed(context, Rotas.cadastroAcademias),
        child: const Icon(Icons.add),
      ),
    );
  }
}
