import 'package:flutter/material.dart';

class WidgetCadastroAlunos extends StatefulWidget {
  const WidgetCadastroAlunos({super.key});

  @override
  _WidgetCadastroAlunosState createState() => _WidgetCadastroAlunosState();
}

class _WidgetCadastroAlunosState extends State<WidgetCadastroAlunos> {
  final _formKey = GlobalKey<FormState>();
  String? selectedObjective;
  List<String> additionalObjectives = [];

  @override
  Widget build(BuildContext context) {
    // Mock list of objectives (in a real app, this would come from a database)
    final objectives = [
      'Perda de Peso',
      'Ganho Muscular',
      'Condicionamento Físico'
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: const Text(
          'Cadastro de Alunos',
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Nome',
                  hintText: 'Insira o nome do aluno',
                  labelStyle: TextStyle(color: Colors.amber),
                  hintStyle: TextStyle(color: Colors.amber),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.amber),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.amber),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o nome';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Telefone',
                  hintText: 'Insira o telefone do aluno',
                  labelStyle: TextStyle(color: Colors.amber),
                  hintStyle: TextStyle(color: Colors.amber),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.amber),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.amber),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Objetivo Principal',
                  labelStyle: TextStyle(color: Colors.amber),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.amber),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.amber),
                  ),
                ),
                dropdownColor: Colors.black,
                style: const TextStyle(color: Colors.amber),
                items: objectives
                    .map(
                      (objective) => DropdownMenuItem(
                        value: objective,
                        child: Text(
                          objective,
                          style: const TextStyle(color: Colors.amber),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedObjective = value;
                    // Reset additional objectives if they include the newly selected primary objective
                    additionalObjectives = additionalObjectives
                        .where((obj) => obj != value && obj.isNotEmpty)
                        .toList();
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Por favor, selecione um objetivo principal';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              ...additionalObjectives.asMap().entries.map((entry) {
                int index = entry.key;
                String? objective = entry.value.isEmpty ? null : entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'Objetivo Adicional',
                            labelStyle: TextStyle(color: Colors.amber),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.amber),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.amber),
                            ),
                          ),
                          dropdownColor: Colors.black,
                          style: const TextStyle(color: Colors.amber),
                          value: objective,
                          items: objectives
                              .where((obj) =>
                                  obj != selectedObjective &&
                                  !additionalObjectives
                                      .asMap()
                                      .entries
                                      .where((e) => e.key != index)
                                      .map((e) => e.value)
                                      .contains(obj))
                              .map(
                                (objective) => DropdownMenuItem(
                                  value: objective,
                                  child: Text(
                                    objective,
                                    style: const TextStyle(color: Colors.amber),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              additionalObjectives[index] = value!;
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Por favor, selecione um objetivo adicional';
                            }
                            return null;
                          },
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.remove_circle,
                            color: Colors.amber),
                        onPressed: () {
                          setState(() {
                            additionalObjectives.removeAt(index);
                          });
                        },
                      ),
                    ],
                  ),
                );
              }).toList(),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.add_circle, color: Colors.amber),
                  onPressed: objectives.length > additionalObjectives.length + 1
                      ? () {
                          setState(() {
                            additionalObjectives.add('');
                          });
                        }
                      : null, // Disable if no more objectives are available
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Implement save logic here
                    print('Aluno salvo:');
                    print('Objetivo Principal: $selectedObjective');
                    print('Objetivos Adicionais: $additionalObjectives');
                    Navigator.pop(context);
                  }
                },
                child: const Text('Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
