import 'package:flutter/material.dart';
import 'package:projeto_ddm_ifpr/banco/sqlite/dao/dao_dieta.dart';
import 'package:projeto_ddm_ifpr/banco/sqlite/dao/dao_receita.dart';
import 'package:projeto_ddm_ifpr/dto/dto_dieta.dart';
import 'package:projeto_ddm_ifpr/dto/dto_receita.dart';
import 'dart:convert';

class WidgetCadastroReceitas extends StatefulWidget {
  final ReceitaDTO? receita;

  const WidgetCadastroReceitas({super.key, this.receita});

  @override
  State<WidgetCadastroReceitas> createState() => _WidgetCadastroReceitasState();
}

class _WidgetCadastroReceitasState extends State<WidgetCadastroReceitas> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _ingredientesController = TextEditingController();
  final _modoPreparoController = TextEditingController();
  final _valorNutricionalController = TextEditingController();
  final _daoReceitas = DAOReceitas();
  final _daoDieta = DAODieta();
  List<DietaDTO> _dietas = [];
  List<String> _selectedDietaIds = [];

  @override
  void initState() {
    super.initState();
    _carregarDietas();
    if (widget.receita != null) {
      _nomeController.text = widget.receita!.nome;
      _ingredientesController.text = widget.receita!.ingredientes.join(', ');
      _modoPreparoController.text = widget.receita!.modoPreparo ?? '';
      _valorNutricionalController.text =
          widget.receita!.valorNutricional != null
              ? widget.receita!.valorNutricional!.entries
                  .map((e) => '${e.key}:${e.value}')
                  .join(',')
              : '';
      _selectedDietaIds = widget.receita!.dietasIds;
    }
  }

  Future<void> _carregarDietas() async {
    try {
      _dietas = await _daoDieta.consultarTodos();
      print('Dietas carregadas: ${_dietas.map((d) => d.nome).toList()}');
      if (widget.receita != null && widget.receita!.dietasIds.isNotEmpty) {
        final validDietaIds = widget.receita!.dietasIds
            .where((id) => _dietas.any((dieta) => dieta.id == id))
            .toList();
        if (validDietaIds.length != widget.receita!.dietasIds.length) {
          print(
              'Dietas inválidas na receita: ${widget.receita!.dietasIds.where((id) => !_dietas.any((dieta) => dieta.id == id)).toList()}');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    'Algumas dietas associadas não foram encontradas. Atualizando lista.'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }
        _selectedDietaIds = validDietaIds;
      }
      setState(() {});
    } catch (e) {
      if (mounted) {
        print('Erro ao carregar dietas: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar dietas: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _ingredientesController.dispose();
    _modoPreparoController.dispose();
    _valorNutricionalController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (_formKey.currentState!.validate()) {
      final ingredientes =
          _ingredientesController.text.split(',').map((e) => e.trim()).toList();
      final valorNutricional = _valorNutricionalController.text.isNotEmpty
          ? Map<String, double>.fromEntries(_valorNutricionalController.text
              .split(',')
              .map((e) {
                final parts = e.split(':');
                if (parts.length == 2) {
                  return MapEntry(
                      parts[0].trim(), double.tryParse(parts[1].trim()) ?? 0.0);
                }
                return null;
              })
              .where((e) => e != null)
              .cast<MapEntry<String, double>>())
          : null;

      final receita = ReceitaDTO(
        id: widget.receita?.id,
        nome: _nomeController.text,
        ingredientes: ingredientes,
        modoPreparo: _modoPreparoController.text.isEmpty
            ? null
            : _modoPreparoController.text,
        valorNutricional: valorNutricional,
        dietasIds: _selectedDietaIds,
        dietasNomes: _dietas
            .where((d) => _selectedDietaIds.contains(d.id))
            .map((d) => d.nome)
            .toList(),
      );

      try {
        await _daoReceitas.salvar(receita);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.receita == null
                  ? 'Receita cadastrada com sucesso!'
                  : 'Receita atualizada com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao salvar receita: $e'),
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
          widget.receita == null ? 'Cadastro de Receitas' : 'Editar Receita',
          style: const TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _nomeController,
                  decoration: const InputDecoration(
                    labelText: 'Nome da Receita',
                    hintText: 'Insira o nome da receita',
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
                      return 'O nome da receita é obrigatório';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _ingredientesController,
                  decoration: const InputDecoration(
                    labelText: 'Ingredientes',
                    hintText: 'Insira os ingredientes (separados por vírgula)',
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
                      return 'Os ingredientes são obrigatórios';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _modoPreparoController,
                  decoration: const InputDecoration(
                    labelText: 'Modo de Preparo',
                    hintText: 'Insira o modo de preparo (opcional)',
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
                  minLines: 3,
                  maxLines: 5,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _valorNutricionalController,
                  decoration: const InputDecoration(
                    labelText: 'Valor Nutricional',
                    hintText:
                        'Ex.: Calorias:200,Proteína:20 (opcional, separado por vírgula)',
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
                const Text(
                  'Dietas',
                  style: TextStyle(color: Colors.amber, fontSize: 16),
                ),
                const SizedBox(height: 8),
                if (_dietas.isEmpty)
                  const Text(
                    'Carregando dietas...',
                    style: TextStyle(color: Colors.white),
                  )
                else
                  SizedBox(
                    height: 300, // Fixed height to prevent overflow
                    child: ListView.builder(
                      itemCount: _dietas.length,
                      itemBuilder: (context, index) {
                        final dieta = _dietas[index];
                        final isSelected = _selectedDietaIds.contains(dieta.id);
                        return CheckboxListTile(
                          title: Text(
                            dieta.nome,
                            style: const TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            dieta.descricao ?? 'Sem descrição',
                            style: const TextStyle(color: Colors.white70),
                          ),
                          value: isSelected,
                          activeColor: Colors.amber,
                          checkColor: Colors.black,
                          onChanged: (value) {
                            setState(() {
                              if (value == true && dieta.id != null) {
                                _selectedDietaIds.add(dieta.id!);
                              } else {
                                _selectedDietaIds.remove(dieta.id);
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
                  child: Text(widget.receita == null ? 'Salvar' : 'Atualizar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
