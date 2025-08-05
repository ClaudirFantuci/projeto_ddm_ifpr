import 'package:flutter/material.dart';
import 'package:projeto_ddm_ifpr/banco/sqlite/dao/dao_dieta.dart';
import 'package:projeto_ddm_ifpr/banco/sqlite/dao/dao_receita.dart';
import 'package:projeto_ddm_ifpr/dto/dto_dieta.dart';
import 'package:projeto_ddm_ifpr/dto/dto_receita.dart';

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
      _selectedDietaIds = widget.receita!.dietasNomes ?? [];
    }
  }

  Future<void> _carregarDietas() async {
    try {
      _dietas = await _daoDieta.consultarTodos();
      print('Dietas carregadas: ${_dietas.map((d) => d.nome).toList()}');
      // Validate existing dietasNomes against loaded diets
      if (widget.receita != null && widget.receita!.dietasNomes != null) {
        final validDietaIds = widget.receita!.dietasNomes!
            .where((id) => _dietas.any((dieta) => dieta.id == id))
            .toList();
        if (validDietaIds.length != widget.receita!.dietasNomes!.length) {
          print(
              'Dietas inválidas no receita: ${widget.receita!.dietasNomes!.where((id) => !_dietas.any((dieta) => dieta.id == id)).toList()}');
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
      try {
        // Parse ingredientes
        final ingredientes = _ingredientesController.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();

        // Parse valorNutricional with robust validation
        Map<String, double>? valorNutricional;
        if (_valorNutricionalController.text.isNotEmpty) {
          valorNutricional = {};
          final pairs = _valorNutricionalController.text.split(',');
          for (var pair in pairs) {
            final parts = pair.split(':');
            if (parts.length != 2 || parts[0].trim().isEmpty) {
              print('Par inválido ignorado: $pair');
              continue;
            }
            try {
              final value = double.tryParse(parts[1].trim());
              if (value == null) {
                print('Valor numérico inválido: ${parts[1].trim()}');
                continue;
              }
              valorNutricional[parts[0].trim()] = value;
            } catch (e) {
              print('Erro ao parsear valor nutricional: $pair, erro: $e');
              continue;
            }
          }
          if (valorNutricional.isEmpty) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      'Nenhum valor nutricional válido fornecido. Continuando sem valores nutricionais.'),
                  backgroundColor: Colors.orange,
                ),
              );
            }
            valorNutricional = null;
          }
        }

        // Validate diet selection
        final validDietaIds = _selectedDietaIds
            .where((id) => _dietas.any((dieta) => dieta.id == id))
            .toList();
        if (_selectedDietaIds.length != validDietaIds.length) {
          print('Dietas inválidas detectadas: $_selectedDietaIds');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    'Algumas dietas selecionadas não são válidas. Usando apenas dietas válidas.'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }

        final receita = ReceitaDTO(
          id: widget.receita?.id,
          nome: _nomeController.text,
          ingredientes: ingredientes,
          modoPreparo: _modoPreparoController.text.isEmpty
              ? null
              : _modoPreparoController.text,
          valorNutricional: valorNutricional,
          dietaId: validDietaIds.isNotEmpty ? validDietaIds.first : null,
          dietasNomes: validDietaIds,
        );

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
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          print('Erro ao salvar receita: $e');
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
          child: Card(
            color: const Color.fromARGB(255, 36, 36, 36),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
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
                      hintText: 'Insira os ingredientes separados por vírgula',
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
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _valorNutricionalController,
                    decoration: const InputDecoration(
                      labelText: 'Valores Nutricionais',
                      hintText: 'Ex: calorias:300,proteinas:20 (opcional)',
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
                    Expanded(
                      child: ListView.builder(
                        itemCount: _dietas.length,
                        itemBuilder: (context, index) {
                          final dieta = _dietas[index];
                          final isSelected =
                              _selectedDietaIds.contains(dieta.id);
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
                                if (value == true) {
                                  if (dieta.id != null) {
                                    _selectedDietaIds.add(dieta.id!);
                                  }
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
                    child:
                        Text(widget.receita == null ? 'Salvar' : 'Atualizar'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
