import 'package:flutter/material.dart';
import 'package:projeto_ddm_ifpr/banco/sqlite/dao/dao_exercicio.dart';
import 'package:projeto_ddm_ifpr/dto/dto_exercicio.dart';

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
  final _equipamentoController = TextEditingController();
  final _dao = DAOExercicio();

  @override
  void initState() {
    super.initState();
    if (widget.exercicio != null) {
      _nomeController.text = widget.exercicio!.nome;
      _equipamentoController.text = widget.exercicio!.equipamento;
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _equipamentoController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (_formKey.currentState!.validate()) {
      final exercicio = DTOExercicio(
        id: widget.exercicio?.id,
        nome: _nomeController.text,
        equipamento: _equipamentoController.text,
      );

      try {
        await _dao.salvar(exercicio);
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
              TextFormField(
                controller: _equipamentoController,
                decoration: const InputDecoration(
                  labelText: 'Equipamento',
                  hintText: 'Insira o equipamento utilizado',
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
                    return 'O equipamento é obrigatório';
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
