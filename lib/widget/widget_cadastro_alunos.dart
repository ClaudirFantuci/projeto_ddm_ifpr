import 'package:flutter/material.dart';
import 'package:projeto_ddm_ifpr/banco/sqlite/dao/dao_aluno.dart';
import 'package:projeto_ddm_ifpr/banco/sqlite/dao/dao_objetivo.dart';
import 'package:projeto_ddm_ifpr/dto/dto_aluno.dart';
import 'package:projeto_ddm_ifpr/dto/dto_objetivo.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class WidgetCadastroAlunos extends StatefulWidget {
  final AlunoDTO? aluno;

  const WidgetCadastroAlunos({super.key, this.aluno});

  @override
  State<WidgetCadastroAlunos> createState() => _WidgetCadastroAlunosState();
}

class _WidgetCadastroAlunosState extends State<WidgetCadastroAlunos> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _daoAluno = DAOAluno();
  final _daoObjetivo = DAOObjetivo();
  List<DTOObjetivo> _objetivos = [];
  String? _selectedObjetivoPrincipalId;
  List<String> _selectedObjetivosAdicionaisIds = [];

  // Máscara para telefone no formato (XX) XXXXX-XXXX
  final _telefoneMask = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {"#": RegExp(r'[0-9]')},
  );

  @override
  void initState() {
    super.initState();
    _carregarObjetivos();
    if (widget.aluno != null) {
      _nomeController.text = widget.aluno!.nome;
      // Apply mask to pre-filled phone number
      _telefoneController.text = _telefoneMask
          .formatEditUpdate(
            TextEditingValue.empty,
            TextEditingValue(text: widget.aluno!.telefone),
          )
          .text;
      _selectedObjetivoPrincipalId = widget.aluno!.objetivoPrincipalId;
      _selectedObjetivosAdicionaisIds = widget.aluno!.objetivosAdicionaisIds;
    }
  }

  Future<void> _carregarObjetivos() async {
    try {
      _objetivos = await _daoObjetivo.consultarTodos();
      print('Objetivos carregados: ${_objetivos.map((o) => o.nome).toList()}');
      setState(() {});
    } catch (e) {
      if (mounted) {
        print('Erro ao carregar objetivos: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar objetivos: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _telefoneController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (_formKey.currentState!.validate()) {
      final aluno = AlunoDTO(
        id: widget.aluno?.id,
        nome: _nomeController.text,
        telefone: _telefoneController.text,
        objetivoPrincipalId: _selectedObjetivoPrincipalId,
        objetivosAdicionaisIds: _selectedObjetivosAdicionaisIds,
      );

      try {
        await _daoAluno.salvar(aluno);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.aluno == null
                  ? 'Aluno cadastrado com sucesso!'
                  : 'Aluno atualizado com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          print('Erro ao salvar aluno: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao salvar aluno: $e'),
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
          widget.aluno == null ? 'Cadastro de Alunos' : 'Editar Aluno',
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
                  labelText: 'Nome do Aluno',
                  hintText: 'Insira o nome do aluno',
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
                    return 'O nome do aluno é obrigatório';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _telefoneController,
                inputFormatters: [_telefoneMask],
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Telefone',
                  hintText: 'Insira o telefone (ex.: (44) 99999-1234)',
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
                    return 'O telefone é obrigatório';
                  }
                  // Validate phone number format using regex
                  final regex = RegExp(r'^\(\d{2}\) \d{5}-\d{4}$');
                  if (!regex.hasMatch(value)) {
                    return 'O telefone deve estar no formato (XX) XXXXX-XXXX';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'Objetivo Principal',
                style: TextStyle(color: Colors.amber, fontSize: 16),
              ),
              DropdownButton<String>(
                value: _selectedObjetivoPrincipalId,
                hint: const Text(
                  'Selecione o objetivo principal',
                  style: TextStyle(color: Colors.white70),
                ),
                isExpanded: true,
                dropdownColor: const Color.fromARGB(255, 36, 36, 36),
                items: _objetivos
                    .map((objetivo) => DropdownMenuItem(
                          value: objetivo.id,
                          child: Text(
                            objetivo.nome,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedObjetivoPrincipalId = value;
                    // Clear additional objectives if primary objective changes
                    _selectedObjetivosAdicionaisIds.clear();
                  });
                },
              ),
              const SizedBox(height: 16),
              if (_selectedObjetivoPrincipalId != null) ...[
                const Text(
                  'Objetivos Adicionais',
                  style: TextStyle(color: Colors.amber, fontSize: 16),
                ),
                const SizedBox(height: 8),
                if (_objetivos.isEmpty)
                  const Text(
                    'Carregando objetivos...',
                    style: TextStyle(color: Colors.white),
                  )
                else
                  Expanded(
                    child: ListView.builder(
                      itemCount: _objetivos.length,
                      itemBuilder: (context, index) {
                        final objetivo = _objetivos[index];
                        // Skip the primary objective
                        if (objetivo.id == _selectedObjetivoPrincipalId) {
                          return const SizedBox.shrink();
                        }
                        final isSelected = _selectedObjetivosAdicionaisIds
                            .contains(objetivo.id);
                        return CheckboxListTile(
                          title: Text(
                            objetivo.nome,
                            style: const TextStyle(color: Colors.white),
                          ),
                          value: isSelected,
                          activeColor: Colors.amber,
                          checkColor: Colors.black,
                          onChanged: (value) {
                            setState(() {
                              if (value == true) {
                                _selectedObjetivosAdicionaisIds
                                    .add(objetivo.id!);
                              } else {
                                _selectedObjetivosAdicionaisIds
                                    .remove(objetivo.id);
                              }
                            });
                          },
                        );
                      },
                    ),
                  ),
              ],
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                ),
                onPressed: _salvar,
                child: Text(widget.aluno == null ? 'Salvar' : 'Atualizar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
