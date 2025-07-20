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
  List<String> _selectedEquipamentoIds = [];

  @override
  void initState() {
    super.initState();
    _carregarEquipamentos();
    if (widget.exercicio != null) {
      _nomeController.text = widget.exercicio!.nome;
      _selectedEquipamentoIds = widget.exercicio!.equipamentosIds;
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
        equipamentosIds: _selectedEquipamentoIds,
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
              const Text(
                'Equipamentos',
                style: TextStyle(color: Colors.amber, fontSize: 16),
              ),
              const SizedBox(height: 8),
              if (_equipamentos.isEmpty)
                const Text(
                  'Carregando equipamentos...',
                  style: TextStyle(color: Colors.white),
                )
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: _equipamentos.length,
                    itemBuilder: (context, index) {
                      final equipamento = _equipamentos[index];
                      final isSelected =
                          _selectedEquipamentoIds.contains(equipamento.id);
                      return CheckboxListTile(
                        title: Text(
                          equipamento.nome,
                          style: const TextStyle(color: Colors.white),
                        ),
                        value: isSelected,
                        activeColor: Colors.amber,
                        checkColor: Colors.black,
                        onChanged: (value) {
                          setState(() {
                            if (value == true) {
                              _selectedEquipamentoIds.add(equipamento.id!);
                            } else {
                              _selectedEquipamentoIds.remove(equipamento.id);
                            }
                          });
                        },
                      );
                    },
                  ),
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
