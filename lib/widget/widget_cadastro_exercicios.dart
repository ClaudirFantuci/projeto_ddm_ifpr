import 'package:flutter/material.dart';
import 'package:projeto_ddm_ifpr/dto/dto_exercicio.dart';

// Mock equipment list (to be replaced with SQLite query in the future)
const List<String> mockEquipments = [
  'Nenhum',
  'Halteres',
  'Barra',
  'Máquina de Smith',
  'Cabo',
  'Banco',
  'Kettlebell',
];

class WidgetCadastroExercicios extends StatefulWidget {
  const WidgetCadastroExercicios({super.key});

  @override
  State<WidgetCadastroExercicios> createState() =>
      _WidgetCadastroExerciciosState();
}

class _WidgetCadastroExerciciosState extends State<WidgetCadastroExercicios> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  String? _selectedEquipment;

  @override
  void dispose() {
    _nomeController.dispose();
    super.dispose();
  }

  void _saveExercise() {
    if (_formKey.currentState!.validate()) {
      final exercicio = DTOExercicio(
        nome: _nomeController.text,
        equipamento:
            _selectedEquipment != null && _selectedEquipment != 'Nenhum'
                ? _selectedEquipment!
                : '',
      );
      // Implement save logic here (e.g., save to SQLite in the future)
      print(
          'Exercício salvo: ${exercicio.nome}, Equipamento: ${exercicio.equipamento}');
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: const Text(
          'Cadastro de Exercícios',
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
                controller: _nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome do Exercício',
                  hintText: 'Insira o nome do exercício',
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
                    return 'Por favor, insira o nome do exercício';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _selectedEquipment,
                decoration: const InputDecoration(
                  labelText: 'Equipamento',
                  labelStyle: TextStyle(color: Colors.amber),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.amber),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.amber),
                  ),
                ),
                dropdownColor: Colors.black,
                items: mockEquipments.map((equipment) {
                  return DropdownMenuItem(
                    value: equipment,
                    child: Text(
                      equipment,
                      style: const TextStyle(color: Colors.amber),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedEquipment = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Por favor, selecione um equipamento';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                ),
                onPressed: _saveExercise,
                child: const Text('Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
