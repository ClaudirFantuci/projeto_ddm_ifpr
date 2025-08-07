import 'package:flutter/material.dart';
import 'package:projeto_ddm_ifpr/banco/sqlite/dao/dao_agendamento.dart';
import 'package:projeto_ddm_ifpr/configuracao/rotas.dart';
import 'package:projeto_ddm_ifpr/dto/dto_agendamento.dart';

class WidgetMenu extends StatefulWidget {
  const WidgetMenu({super.key});

  @override
  _WidgetMenuState createState() => _WidgetMenuState();
}

class _WidgetMenuState extends State<WidgetMenu> {
  final DAOAgendamento _dao = DAOAgendamento();
  List<DTOAgendamento> _agendamentos = [];
  String _diaSelecionado = _getTodayInPortuguese();
  bool _isLoading = true;
  Key _futureBuilderKey = UniqueKey();

  // Lista de dias da semana
  final List<String> _diasSemana = [
    'Segunda-feira',
    'Terça-feira',
    'Quarta-feira',
    'Quinta-feira',
    'Sexta-feira',
    'Sábado',
    'Domingo'
  ];

  @override
  void initState() {
    super.initState();
    _carregarAgendamentos();
  }

  // Carrega todos os agendamentos do banco de dados
  Future<void> _carregarAgendamentos() async {
    try {
      setState(() {
        _isLoading = true;
      });
      final agendamentos = await _dao.consultarTodos();
      if (mounted) {
        setState(() {
          _agendamentos = agendamentos;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar agendamentos: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Filtra os agendamentos pelo dia selecionado
  List<DTOAgendamento> _filtrarAgendamentosPorDia(String dia) {
    return _agendamentos
        .where((agendamento) => agendamento.diaSemana == dia)
        .toList();
  }

  // Atualiza a lista de agendamentos
  void _refreshList() {
    setState(() {
      _futureBuilderKey = UniqueKey();
      _carregarAgendamentos();
    });
  }

  @override
  Widget build(BuildContext context) {
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
            // Barra de rolagem horizontal para os dias da semana
            Container(
              height: 60,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _diasSemana.length,
                itemBuilder: (context, index) {
                  final dia = _diasSemana[index];
                  final isSelected = dia == _diaSelecionado;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _diaSelecionado = dia;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.amber : Colors.grey[700],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          dia,
                          style: TextStyle(
                            color: isSelected ? Colors.black : Colors.amber,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Text(
                'Agendamentos de $_diaSelecionado',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.amber,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.amber))
                  : _filtrarAgendamentosPorDia(_diaSelecionado).isEmpty
                      ? const Center(
                          child: Text(
                            'Nenhum agendamento para este dia',
                            style: TextStyle(color: Colors.white),
                          ),
                        )
                      : ListView.builder(
                          key: _futureBuilderKey,
                          itemCount: _filtrarAgendamentosPorDia(_diaSelecionado)
                              .length,
                          itemBuilder: (context, index) {
                            final agendamento = _filtrarAgendamentosPorDia(
                                _diaSelecionado)[index];
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
                                      style:
                                          const TextStyle(color: Colors.amber),
                                    ),
                                    Text(
                                      'Academia: ${agendamento.academiaNome ?? 'Não definida'}',
                                      style:
                                          const TextStyle(color: Colors.amber),
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
                                  ).then((_) => _refreshList());
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
        onPressed: () => Navigator.pushNamed(context, Rotas.cadastroAgendamento)
            .then((_) => _refreshList()),
        child: const Icon(Icons.add),
      ),
    );
  }

  static String _getTodayInPortuguese() {
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
        return 'Segunda-feira';
    }
  }
}
