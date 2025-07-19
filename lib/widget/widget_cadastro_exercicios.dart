import 'package:flutter/material.dart';
import 'package:projeto_ddm_ifpr/banco/sqlite/dao/dao_exercicio.dart';
import 'package:projeto_ddm_ifpr/banco/sqlite/dao/dao_equipamento.dart';
import 'package:projeto_ddm_ifpr/dto/dto_exercicio.dart';
import 'package:projeto_ddm_ifpr/dto/dto_equipamento.dart';

class WidgetCadastroExercicios extends StatefulWidget {
  final DTOExercicio? exercicio;

  const WidgetCadastroExercicios({super.key, this.exercicio});

  @override
  State<WidgetCadastroExercicios> createState() =>
      _WidgetCadastroExerciciosState();
}

class _WidgetCadastroExerciciosState extends State<WidgetCadastroExercicios> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _daoExercicio = DAOExercicio();
  final _daoEquipamento = DAOEquipamento();
  List<DTOEquipamento> _equipamentos = [];
  String? _selectedEquipamentoId;
  String? _selectedEquipamentoSecundarioId;

  @override
  void initState() {
    super.initState();
    _carregarEquipamentos();
    if (widget.exercicio != null) {
      _nomeController.text = widget.exercicio!.nome;
      _selectedEquipamentoId = widget.exercicio!.equipamentoId;
      _selectedEquipamentoSecundarioId =
          widget.exercicio!.equipamentoSecundarioId;
    }
  }

  Future<void> _carregarEquipamentos() async {
    try {
      _equipamentos = await _daoEquipamento.consultarTodos();
      setState(() {});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar equipamentos: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (_formKey.currentState!.validate()) {
      final exercicio = DTOExercicio(
        id: widget.exercicio?.id,
        nome: _nomeController.text,
        equipamentoId: _selectedEquipamentoId!,
        equipamentoSecundarioId: _selectedEquipamentoSecundarioId,
      );

      try {
        await _daoExercicio.salvar(exercicio);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.exercicio == null
                  ? 'Exercício cadastrado com sucesso!'
                  : 'Exercício atualizado com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao salvar exercício: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: Text(
          widget.exercicio == null
              ? 'Cadastro de Exercícios'
              : 'Editar Exercício',
          style: const TextStyle(color: Colors.black),
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
                    return 'O nome do exercício é obrigatório';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              if (_equipamentos.isEmpty)
                const Text(
                  'Carregando equipamentos...',
                  style: TextStyle(color: Colors.white),
                )
              else
                DropdownButtonFormField<String>(
                  value: _selectedEquipamentoId,
                  decoration: const InputDecoration(
                    labelText: 'Equipamento I',
                    labelStyle: TextStyle(color: Colors.amber),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.amber),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.amber),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                  dropdownColor: Colors.black,
                  items: _equipamentos.map((equipamento) {
                    return DropdownMenuItem<String>(
                      value: equipamento.id,
                      child: Text(equipamento.nome,
                          style: const TextStyle(color: Colors.white)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedEquipamentoId = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Selecione o Equipamento I';
                    }
                    return null;
                  },
                ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedEquipamentoSecundarioId,
                decoration: const InputDecoration(
                  labelText: 'Equipamento II (opcional)',
                  labelStyle: TextStyle(color: Colors.amber),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.amber),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.amber),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
                dropdownColor: Colors.black,
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child:
                        Text('Nenhum', style: TextStyle(color: Colors.white)),
                  ),
                  ..._equipamentos.map((equipamento) {
                    return DropdownMenuItem<String>(
                      value: equipamento.id,
                      child: Text(equipamento.nome,
                          style: const TextStyle(color: Colors.white)),
                    );
                  }),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedEquipamentoSecundarioId = value;
                  });
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                ),
                onPressed: _salvar,
                child: Text(widget.exercicio == null ? 'Salvar' : 'Atualizar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
