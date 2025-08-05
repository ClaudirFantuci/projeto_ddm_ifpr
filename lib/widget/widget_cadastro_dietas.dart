import 'package:flutter/material.dart';
import 'package:projeto_ddm_ifpr/banco/sqlite/dao/dao_dieta.dart';
import 'package:projeto_ddm_ifpr/banco/sqlite/dao/dao_receita.dart';
import 'package:projeto_ddm_ifpr/dto/dto_dieta.dart';
import 'package:projeto_ddm_ifpr/dto/dto_receita.dart';

class WidgetCadastroDietas extends StatefulWidget {
  final DietaDTO? dieta;

  const WidgetCadastroDietas({super.key, this.dieta});

  @override
  State<WidgetCadastroDietas> createState() => _WidgetCadastroDietasState();
}

class _WidgetCadastroDietasState extends State<WidgetCadastroDietas> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _objetivoController = TextEditingController();
  final _daoDieta = DAODieta();
  final _daoReceita = DAOReceita();
  List<ReceitaDTO> _receitas = [];
  List<String> _selectedReceitaIds = [];

  @override
  void initState() {
    super.initState();
    _carregarReceitas();
    if (widget.dieta != null) {
      _nomeController.text = widget.dieta!.nome;
      _descricaoController.text = widget.dieta!.descricao ?? '';
      _objetivoController.text = widget.dieta!.objetivo ?? '';
      _selectedReceitaIds = widget.dieta!.receitasIds;
    }
  }

  Future<void> _carregarReceitas() async {
    try {
      _receitas = await _daoReceita.consultarTodos();
      setState(() {});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar receitas: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    _objetivoController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (_formKey.currentState!.validate()) {
      final dieta = DietaDTO(
        id: widget.dieta?.id,
        nome: _nomeController.text,
        descricao: _descricaoController.text.isEmpty
            ? null
            : _descricaoController.text,
        objetivo:
            _objetivoController.text.isEmpty ? null : _objetivoController.text,
        receitasIds: _selectedReceitaIds,
        receitasNomes: _receitas
            .where((r) => _selectedReceitaIds.contains(r.id))
            .map((r) => r.nome)
            .toList(),
      );

      try {
        await _daoDieta.salvar(dieta);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.dieta == null
                  ? 'Dieta cadastrada com sucesso!'
                  : 'Dieta atualizada com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao salvar dieta: $e'),
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
          widget.dieta == null ? 'Cadastro de Dietas' : 'Editar Dieta',
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
                  labelText: 'Nome da Dieta',
                  hintText: 'Insira o nome da dieta',
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
                    return 'O nome da dieta é obrigatório';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descricaoController,
                decoration: const InputDecoration(
                  labelText: 'Descrição',
                  hintText: 'Insira a descrição da dieta (opcional)',
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
                controller: _objetivoController,
                decoration: const InputDecoration(
                  labelText: 'Objetivo',
                  hintText: 'Insira o objetivo da dieta (opcional)',
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
                'Receitas',
                style: TextStyle(color: Colors.amber, fontSize: 16),
              ),
              const SizedBox(height: 8),
              if (_receitas.isEmpty)
                const Text(
                  'Carregando receitas...',
                  style: TextStyle(color: Colors.white),
                )
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: _receitas.length,
                    itemBuilder: (context, index) {
                      final receita = _receitas[index];
                      final isSelected =
                          _selectedReceitaIds.contains(receita.id);
                      return CheckboxListTile(
                        title: Text(
                          receita.nome,
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          'Ingredientes: ${receita.ingredientes.join(", ") ?? "Nenhum"}',
                          style: const TextStyle(color: Colors.white70),
                        ),
                        value: isSelected,
                        activeColor: Colors.amber,
                        checkColor: Colors.black,
                        onChanged: (value) {
                          setState(() {
                            if (value == true) {
                              _selectedReceitaIds.add(receita.id!);
                            } else {
                              _selectedReceitaIds.remove(receita.id);
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
                child: Text(widget.dieta == null ? 'Salvar' : 'Atualizar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
