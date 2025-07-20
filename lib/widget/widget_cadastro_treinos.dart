import 'package:flutter/material.dart';
import 'package:projeto_ddm_ifpr/banco/sqlite/dao/dao_treino.dart';
import 'package:projeto_ddm_ifpr/banco/sqlite/dao/dao_exercicio.dart';
import 'package:projeto_ddm_ifpr/dto/dto_treino.dart';
import 'package:projeto_ddm_ifpr/dto/dto_exercicio.dart';

class WidgetCadastroTreinos extends StatefulWidget {
  final DTOTreino? treino;

  const WidgetCadastroTreinos({super.key, this.treino});

  @override
  State<WidgetCadastroTreinos> createState() => _WidgetCadastroTreinosState();
}

class _WidgetCadastroTreinosState extends State<WidgetCadastroTreinos> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _daoTreino = DAOTreino();
  final _daoExercicio = DAOExercicio();
  List<DTOExercicio> _exercicios = [];
  List<String> _selectedExercicioIds = [];

  @override
  void initState() {
    super.initState();
    _carregarExercicios();
    if (widget.treino != null) {
      _nomeController.text = widget.treino!.nome;
      _selectedExercicioIds = widget.treino!.exerciciosIds;
    }
  }

  Future<void> _carregarExercicios() async {
    try {
      _exercicios = await _daoExercicio.consultarTodosComNomeEquipamento();
      setState(() {});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar exercícios: $e'),
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
      final treino = DTOTreino(
        id: widget.treino?.id,
        nome: _nomeController.text,
        exerciciosIds: _selectedExercicioIds,
      );

      try {
        await _daoTreino.salvar(treino);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.treino == null
                  ? 'Treino cadastrado com sucesso!'
                  : 'Treino atualizado com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao salvar treino: $e'),
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
          widget.treino == null ? 'Cadastro de Treinos' : 'Editar Treino',
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
                    return 'O nome do treino é obrigatório';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'Exercícios',
                style: TextStyle(color: Colors.amber, fontSize: 16),
              ),
              const SizedBox(height: 8),
              if (_exercicios.isEmpty)
                const Text(
                  'Carregando exercícios...',
                  style: TextStyle(color: Colors.white),
                )
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: _exercicios.length,
                    itemBuilder: (context, index) {
                      final exercicio = _exercicios[index];
                      final isSelected =
                          _selectedExercicioIds.contains(exercicio.id);
                      return CheckboxListTile(
                        title: Text(
                          exercicio.nome,
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          'Equipamentos: ${exercicio.equipamentosNomes?.join(", ") ?? "Nenhum"}',
                          style: const TextStyle(color: Colors.white70),
                        ),
                        value: isSelected,
                        activeColor: Colors.amber,
                        checkColor: Colors.black,
                        onChanged: (value) {
                          setState(() {
                            if (value == true) {
                              _selectedExercicioIds.add(exercicio.id!);
                            } else {
                              _selectedExercicioIds.remove(exercicio.id);
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
                child: Text(widget.treino == null ? 'Salvar' : 'Atualizar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
