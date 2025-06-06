import 'package:flutter/material.dart';

class WidgetCadastroTreinos extends StatefulWidget {
  const WidgetCadastroTreinos({super.key});

  @override
  _WidgetCadastroTreinosState createState() => _WidgetCadastroTreinosState();
}

class _WidgetCadastroTreinosState extends State<WidgetCadastroTreinos> {
  final _formKey = GlobalKey<FormState>();
  final List<String> selectedExercises = [];

  @override
  Widget build(BuildContext context) {
    // Mock list of exercises (in a real app, this would come from a database)
    final exercises = [
      'Supino Reto',
      'Agachamento Livre',
      'Levantamento Terra',
      'Rosca Direta'
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: const Text(
          'Cadastro de Treinos',
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
                  labelText: 'Nome do Treino',
                  hintText: 'Insira o nome do treino',
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
                    return 'Por favor, insira o nome do treino';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'Selecionar Exercícios',
                style: TextStyle(
                    color: Colors.amber,
                    fontSize: 16,
                    fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView(
                  children: exercises.map((exercise) {
                    return CheckboxListTile(
                      title: Text(
                        exercise,
                        style: const TextStyle(color: Colors.amber),
                      ),
                      value: selectedExercises.contains(exercise),
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            selectedExercises.add(exercise);
                          } else {
                            selectedExercises.remove(exercise);
                          }
                        });
                      },
                      checkColor: Colors.black,
                      activeColor: Colors.amber,
                    );
                  }).toList(),
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
                    if (selectedExercises.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Selecione pelo menos um exercício'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }
                    // Implement save logic here
                    print('Treino salvo:');
                    print('Exercícios selecionados: $selectedExercises');
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
