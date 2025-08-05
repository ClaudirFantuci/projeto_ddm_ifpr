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
  final _daoReceita = DAOReceita();
  final _daoDieta = DAODieta();
  List<DietaDTO> _dietas = [];
  List<String> _selectedDietasIds = [];

  @override
  void initState() {
    super.initState();
    _carregarDietas();
    if (widget.receita != null) {
      _nomeController.text = widget.receita!.nome;
      _ingredientesController.text = widget.receita!.ingredientes.join(', ');
      _modoPreparoController.text = widget.receita!.modoPreparo ?? '';
      _valorNutricionalController.text = widget
              .receita!.valorNutricional?.entries
              .map((e) => '${e.key}: ${e.value}')
              .join(', ') ??
          '';
      _selectedDietasIds = widget.receita!.dietasNomes ?? [];
    }
  }

  Future<void> _carregarDietas() async {
    try {
      _dietas = await _daoDieta.consultarTodos();
      setState(() {});
    } catch (e) {
      if (mounted) {
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

  Future<void> _selecionarDietas() async {
    final List<String> tempSelectedDietasIds = List.from(_selectedDietasIds);
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color.fromARGB(255, 36, 36, 36),
        title: const Text(
          'Selecionar Dietas',
          style: TextStyle(color: Colors.amber),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _dietas.length,
            itemBuilder: (context, index) {
              final dieta = _dietas[index];
              return CheckboxListTile(
                title: Text(dieta.nome,
                    style: const TextStyle(color: Colors.white)),
                activeColor: Colors.amber,
                checkColor: Colors.black,
                value: tempSelectedDietasIds.contains(dieta.id),
                onChanged: (bool? value) {
                  setState(() {
                    if (value == true) {
                      tempSelectedDietasIds.add(dieta.id!);
                    } else {
                      tempSelectedDietasIds.remove(dieta.id);
                    }
                  });
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar', style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child:
                const Text('Confirmar', style: TextStyle(color: Colors.amber)),
          ),
        ],
      ),
    );

    if (result == true) {
      setState(() {
        _selectedDietasIds = tempSelectedDietasIds;
      });
    }
  }

  Future<void> _salvar() async {
    if (_formKey.currentState!.validate()) {
      final ingredientes = _ingredientesController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      Map<String, double>? valorNutricional;
      if (_valorNutricionalController.text.isNotEmpty) {
        try {
          valorNutricional = Map.fromEntries(
            _valorNutricionalController.text.split(',').map((e) {
              final parts = e.split(':').map((p) => p.trim()).toList();
              if (parts.length != 2 || double.tryParse(parts[1]) == null) {
                throw FormatException(
                    'Formato inválido para valor nutricional');
              }
              return MapEntry(parts[0], double.parse(parts[1]));
            }),
          );
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text(
                    'Erro: Valor nutricional deve estar no formato "chave: valor, chave: valor" (ex.: calorias: 300, proteinas: 20)'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
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
        dietaId:
            _selectedDietasIds.isNotEmpty ? _selectedDietasIds.first : null,
        dietasNomes: _selectedDietasIds,
      );

      try {
        await _daoReceita.salvar(receita);
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
                    hintText: 'Insira os ingredientes, separados por vírgula',
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
                    labelText: 'Valor Nutricional',
                    hintText:
                        'Insira como "calorias: 300, proteinas: 20" (opcional)',
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
                GestureDetector(
                  onTap: _selecionarDietas,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Dietas Associadas',
                      hintText: 'Toque para selecionar dietas',
                      labelStyle: TextStyle(color: Colors.amber),
                      hintStyle: TextStyle(color: Colors.amber),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.amber),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.amber),
                      ),
                    ),
                    child: Text(
                      _selectedDietasIds.isEmpty
                          ? 'Nenhuma dieta selecionada'
                          : _dietas
                              .where((dieta) =>
                                  _selectedDietasIds.contains(dieta.id))
                              .map((dieta) => dieta.nome)
                              .join(', '),
                      style: const TextStyle(color: Colors.white),
                    ),
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
