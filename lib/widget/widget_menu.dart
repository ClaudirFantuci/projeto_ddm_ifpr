import 'package:flutter/material.dart';
import 'package:projeto_ddm_ifpr/configuracao/rotas.dart';

class WidgetMenu extends StatelessWidget {
  const WidgetMenu({super.key});

  @override
  Widget build(BuildContext context) {
    List<String> horarios = ["08:00", "10:00", "15:00", "18:00"];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: const Text('Bem-vindo', style: TextStyle(color: Colors.black)),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      drawer: Drawer(
        backgroundColor: const Color.fromARGB(255, 36, 36, 36),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.amber),
              child: const Text(
                'Menu',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.list, color: Colors.amber),
              title:
                  const Text('Listas', style: TextStyle(color: Colors.amber)),
              onTap: () => Navigator.pushNamed(context, Rotas.listas),
            ),
            ListTile(
              leading: const Icon(Icons.add_circle, color: Colors.amber),
              title: const Text('Cadastros',
                  style: TextStyle(color: Colors.amber)),
              onTap: () => Navigator.pushNamed(context, Rotas.cadastros),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 16.0),
              child: Text(
                'Bem-vindo!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 16.0),
              child: Text(
                'Agendamentos de Hoje',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.amber,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: horarios.length,
                itemBuilder: (context, index) {
                  final horario = horarios[index];
                  return Card(
                    color: const Color.fromARGB(255, 36, 36, 36),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      title: Text(
                        'Horário: $horario',
                        style: const TextStyle(color: Colors.amber),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          Text(
                            'Aluno: Aluno ${index + 1}',
                            style: const TextStyle(color: Colors.amber),
                          ),
                          Text(
                            'Academia: Academia ${index + 1}',
                            style: const TextStyle(color: Colors.amber),
                          ),
                        ],
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.amber,
                      ),
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          Rotas.detalhesAgendamento,
                          arguments: {
                            'aluno': 'Aluno ${index + 1}',
                            'academia': 'Academia ${index + 1}',
                            'horario': horario,
                          },
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.amber,
        foregroundColor: Colors.black,
        onPressed: () => Navigator.pushNamed(context, Rotas.agendamento),
        child: const Icon(Icons.add),
      ),
    );
  }
}
