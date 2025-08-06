import 'package:flutter/material.dart';
import 'package:projeto_ddm_ifpr/banco/sqlite/dao/dao_agendamento.dart';
import 'package:projeto_ddm_ifpr/configuracao/rotas.dart';
import 'package:projeto_ddm_ifpr/dto/dto_agendamento.dart';

class WidgetMenu extends StatelessWidget {
  const WidgetMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final DAOAgendamento _dao = DAOAgendamento();
    final String today = _getTodayInPortuguese();

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
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.amber),
              child: Text(
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
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Text(
                'Agendamentos de Hoje ($today)',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.amber,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: FutureBuilder<List<DTOAgendamento>>(
                future: _dao.consultarTodos(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.amber),
                    );
                  } else if (snapshot.hasError) {
                    return const Center(
                      child: Text(
                        'Erro ao carregar agendamentos',
                        style: TextStyle(color: Colors.white),
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
                  final agendamentos = snapshot.data!
                      .where((agendamento) => agendamento.diaSemana == today)
                      .toList();
                  if (agendamentos.isEmpty) {
                    return const Center(
                      child: Text(
                        'Nenhum agendamento para hoje',
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: agendamentos.length,
                    itemBuilder: (context, index) {
                      final agendamento = agendamentos[index];
                      return Card(
                        color: const Color.fromARGB(255, 36, 36, 36),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          title: Text(
                            agendamento.turmaNome ??
                                agendamento.alunosNomes?.join(', ') ??
                                'Sem nome',
                            style: const TextStyle(color: Colors.amber),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 8),
                              Text(
                                'Horário: ${agendamento.horarioInicio}-${agendamento.horarioFim}',
                                style: const TextStyle(color: Colors.amber),
                              ),
                              Text(
                                'Academia: ${agendamento.academiaNome ?? 'Não definida'}',
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
                              Rotas.cadastroAgendamento,
                              arguments: agendamento,
                            );
                          },
                        ),
                      );
                    },
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
        onPressed: () =>
            Navigator.pushNamed(context, Rotas.cadastroAgendamento),
        child: const Icon(Icons.add),
      ),
    );
  }

  String _getTodayInPortuguese() {
    final now = DateTime.now();
    switch (now.weekday) {
      case DateTime.monday:
        return 'Segunda-feira';
      case DateTime.tuesday:
        return 'Terça-feira';
      case DateTime.wednesday:
        return 'Quarta-feira';
      case DateTime.thursday:
        return 'Quinta-feira';
      case DateTime.friday:
        return 'Sexta-feira';
      case DateTime.saturday:
        return 'Sábado';
      case DateTime.sunday:
        return 'Domingo';
      default:
        return '';
    }
  }
}
