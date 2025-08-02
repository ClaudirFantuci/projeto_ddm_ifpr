import 'package:flutter/material.dart';
import 'package:projeto_ddm_ifpr/banco/sqlite/dao/dao_professor.dart';
import 'package:projeto_ddm_ifpr/banco/sqlite/dao/dao_modalidade.dart';
import 'package:projeto_ddm_ifpr/dto/dto_professor.dart';
import 'package:projeto_ddm_ifpr/dto/dto_modalidade.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class WidgetCadastroProfessores extends StatefulWidget {
  final ProfessorDTO? professor;

  const WidgetCadastroProfessores({super.key, this.professor});

  @override
  State<WidgetCadastroProfessores> createState() =>
      _WidgetCadastroProfessoresState();
}

class _WidgetCadastroProfessoresState extends State<WidgetCadastroProfessores> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _daoProfessor = DAOProfessor();
  final _daoModalidade = DAOModalidade();
  List<DtoModalidade> _modalidades = [];
  List<String> _selectedModalidadesIds = [];

  // Máscara para telefone no formato (XX) XXXXX-XXXX
  final _telefoneMask = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {"#": RegExp(r'[0-9]')},
  );

  @override
  void initState() {
    super.initState();
    _carregarModalidades();
    if (widget.professor != null) {
      _nomeController.text = widget.professor!.nome;
      _telefoneController.text = _telefoneMask
          .formatEditUpdate(
            TextEditingValue.empty,
            TextEditingValue(text: widget.professor!.telefone),
          )
          .text;
      _selectedModalidadesIds = widget.professor!.ModalidadesIds;
    }
  }

  Future<void> _carregarModalidades() async {
    try {
      _modalidades = await _daoModalidade.consultarTodos();
      print(
          'Modalidades carregadas: ${_modalidades.map((m) => m.nome).toList()}');
      setState(() {});
    } catch (e) {
      if (mounted) {
        print('Erro ao carregar modalidades: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar modalidades: $e'),
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
      final professor = ProfessorDTO(
        id: widget.professor?.id,
        nome: _nomeController.text,
        telefone: _telefoneController.text,
        ModalidadesIds: _selectedModalidadesIds,
        ModalidadesNomes: _modalidades
            .where((m) => _selectedModalidadesIds.contains(m.id))
            .map((m) => m.nome)
            .toList(),
      );

      try {
        await _daoProfessor.salvar(professor);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.professor == null
                  ? 'Professor cadastrado com sucesso!'
                  : 'Professor atualizado com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          print('Erro ao salvar professor: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao salvar professor: $e'),
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
          widget.professor == null
              ? 'Cadastro de Professores'
              : 'Editar Professor',
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
                  labelText: 'Nome do Professor',
                  hintText: 'Insira o nome do professor',
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
                    return 'O nome do professor é obrigatório';
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
                  final regex = RegExp(r'^\(\d{2}\) \d{5}-\d{4}$');
                  if (!regex.hasMatch(value)) {
                    return 'O telefone deve estar no formato (XX) XXXXX-XXXX';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'Modalidades',
                style: TextStyle(color: Colors.amber, fontSize: 16),
              ),
              const SizedBox(height: 8),
              if (_modalidades.isEmpty)
                const Text(
                  'Carregando modalidades...',
                  style: TextStyle(color: Colors.white),
                )
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: _modalidades.length,
                    itemBuilder: (context, index) {
                      final modalidade = _modalidades[index];
                      final isSelected =
                          _selectedModalidadesIds.contains(modalidade.id);
                      return CheckboxListTile(
                        title: Text(
                          modalidade.nome,
                          style: const TextStyle(color: Colors.white),
                        ),
                        value: isSelected,
                        activeColor: Colors.amber,
                        checkColor: Colors.black,
                        onChanged: (value) {
                          setState(() {
                            if (value == true) {
                              if (modalidade.id != null) {
                                _selectedModalidadesIds.add(modalidade.id!);
                              }
                            } else {
                              _selectedModalidadesIds.remove(modalidade.id);
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
                child: Text(widget.professor == null ? 'Salvar' : 'Atualizar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
