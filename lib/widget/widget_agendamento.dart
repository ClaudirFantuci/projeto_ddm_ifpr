import 'package:flutter/material.dart';

class WidgetAgendamento extends StatefulWidget {
  const WidgetAgendamento({super.key});

  @override
  _WidgetAgendamentoState createState() => _WidgetAgendamentoState();
}

class _WidgetAgendamentoState extends State<WidgetAgendamento> {
  String? alunoSelecionado;
  String? academiaSelecionada;
  String? horarioSelecionado;

  @override
  Widget build(BuildContext context) {
    final alunos = ['João Silva', 'Maria Oliveira'];
    final academias = ['Academia 1', 'Academia 2'];
    final diasSemama = ['Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta'];
    final horarios = ['08:00', '10:00', '15:00', '18:00'];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Novo Agendamento'),
        backgroundColor: Colors.amber,
        foregroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            color: Colors.black,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Aluno',
                        labelStyle: TextStyle(color: Colors.amber),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.amber),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.amber, width: 2),
                        ),
                      ),
                      dropdownColor: Colors.black,
                      style: const TextStyle(color: Colors.amber),
                      items:
                          alunos
                              .map(
                                (aluno) => DropdownMenuItem(
                                  value: aluno,
                                  child: Text(
                                    aluno,
                                    style: const TextStyle(color: Colors.amber),
                                  ),
                                ),
                              )
                              .toList(),
                      onChanged:
                          (value) => setState(() => alunoSelecionado = value),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Academia',
                        labelStyle: TextStyle(color: Colors.amber),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.amber),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.amber, width: 2),
                        ),
                      ),
                      dropdownColor: Colors.black,
                      style: const TextStyle(color: Colors.amber),
                      items:
                          academias
                              .map(
                                (academia) => DropdownMenuItem(
                                  value: academia,
                                  child: Text(
                                    academia,
                                    style: const TextStyle(color: Colors.amber),
                                  ),
                                ),
                              )
                              .toList(),
                      onChanged:
                          (value) =>
                              setState(() => academiaSelecionada = value),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Dia da Semana',
                        labelStyle: TextStyle(color: Colors.amber),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.amber),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.amber, width: 2),
                        ),
                      ),
                      dropdownColor: Colors.black,
                      style: const TextStyle(color: Colors.amber),
                      items:
                          diasSemama
                              .map(
                                (dia) => DropdownMenuItem(
                                  value: dia,
                                  child: Text(
                                    dia,
                                    style: const TextStyle(color: Colors.amber),
                                  ),
                                ),
                              )
                              .toList(),
                      onChanged: (value) {},
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Horário',
                        labelStyle: TextStyle(color: Colors.amber),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.amber),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.amber, width: 2),
                        ),
                      ),
                      dropdownColor: Colors.black,
                      style: const TextStyle(color: Colors.amber),
                      items:
                          horarios
                              .map(
                                (horario) => DropdownMenuItem(
                                  value: horario,
                                  child: Text(
                                    horario,
                                    style: const TextStyle(color: Colors.amber),
                                  ),
                                ),
                              )
                              .toList(),
                      onChanged:
                          (value) => setState(() => horarioSelecionado = value),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.black,
                        side: BorderSide(color: Colors.amber, width: 2),
                      ),
                      onPressed: () {},
                      child: const Text('Salvar Agendamento'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
