import 'package:flutter/material.dart';
import 'package:projeto_ddm_ifpr/banco/sqlite/dao/dao_turma.dart';
import 'package:projeto_ddm_ifpr/banco/sqlite/dao/dao_professor.dart';
import 'package:projeto_ddm_ifpr/banco/sqlite/dao/dao_aluno.dart';
import 'package:projeto_ddm_ifpr/dto/dto_professor.dart';
import 'package:projeto_ddm_ifpr/dto/dto_turma.dart';
import 'package:projeto_ddm_ifpr/dto/dto_aluno.dart';

class WidgetCadastroTurmas extends StatefulWidget {
  final TurmaDTO? turma;

  const WidgetCadastroTurmas({super.key, this.turma});

  @override
  State<WidgetCadastroTurmas> createState() => _WidgetCadastroTurmasState();
}

class _WidgetCadastroTurmasState extends State<WidgetCadastroTurmas> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _daoTurma = DAOTurma();
  final _daoProfessor = DAOProfessor();
  final _daoAluno = DAOAluno();
  late Future<List<ProfessorDTO>> _futureProfessores;
  late Future<List<AlunoDTO>> _futureAlunos;
  List<ProfessorDTO> _professores = [];
  List<AlunoDTO> _alunos = [];
  List<String> _selectedProfessoresIds = [];
  List<String> _selectedAlunosIds = [];

  @override
  void initState() {
    super.initState();
    _futureProfessores = _daoProfessor.consultarTodos().catchError((e) {
      print('Erro ao carregar professores: $e');
      return <ProfessorDTO>[];
    });
    _futureAlunos = _daoAluno.consultarTodos().catchError((e) {
      print('Erro ao carregar alunos: $e');
      return <AlunoDTO>[];
    });
    if (widget.turma != null) {
      _nomeController.text = widget.turma!.nome;
      _selectedProfessoresIds = widget.turma!.professoresIds.toSet().toList();
      _selectedAlunosIds = widget.turma!.alunosIds.toSet().toList();
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (_formKey.currentState!.validate()) {
      final turma = TurmaDTO(
        id: widget.turma?.id,
        nome: _nomeController.text,
        professoresIds: _selectedProfessoresIds,
        professoresNomes: _professores
            .where((p) => _selectedProfessoresIds.contains(p.id))
            .map((p) => p.nome)
            .toSet()
            .toList(),
        alunosIds: _selectedAlunosIds,
        alunosNomes: _alunos
            .where((a) => _selectedAlunosIds.contains(a.id))
            .map((a) => a.nome)
            .toSet()
            .toList(),
      );

      try {
        await _daoTurma.salvar(turma);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.turma == null
                  ? 'Turma cadastrada com sucesso!'
                  : 'Turma atualizada com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          print('Erro ao salvar turma: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao salvar turma: $e'),
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
          widget.turma == null ? 'Cadastro de Turmas' : 'Editar Turma',
          style: const TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: FutureBuilder<List<ProfessorDTO>>(
        future: _futureProfessores,
        builder: (context, professorSnapshot) {
          if (professorSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: Colors.amber));
          } else if (professorSnapshot.hasError) {
            return Center(
              child: Text(
                'Erro ao carregar professores: ${professorSnapshot.error}',
                style: const TextStyle(color: Colors.white),
              ),
            );
          } else if (!professorSnapshot.hasData ||
              professorSnapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'Nenhum professor encontrado',
                style: TextStyle(color: Colors.white),
              ),
            );
          }
          _professores = professorSnapshot.data!;
          return FutureBuilder<List<AlunoDTO>>(
            future: _futureAlunos,
            builder: (context, alunoSnapshot) {
              if (alunoSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: CircularProgressIndicator(color: Colors.amber));
              } else if (alunoSnapshot.hasError) {
                return Center(
                  child: Text(
                    'Erro ao carregar alunos: ${alunoSnapshot.error}',
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              } else if (!alunoSnapshot.hasData ||
                  alunoSnapshot.data!.isEmpty) {
                return const Center(
                  child: Text(
                    'Nenhum aluno encontrado',
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }
              _alunos = alunoSnapshot.data!;
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _nomeController,
                        decoration: const InputDecoration(
                          labelText: 'Nome da Turma',
                          hintText: 'Insira o nome da turma',
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
                            return 'Por favor, insira o nome da turma';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Professores',
                        style: TextStyle(color: Colors.amber, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _professores.length,
                          itemBuilder: (context, index) {
                            final professor = _professores[index];
                            final isSelected =
                                _selectedProfessoresIds.contains(professor.id);
                            return CheckboxListTile(
                              title: Text(
                                professor.nome,
                                style: const TextStyle(color: Colors.white),
                              ),
                              value: isSelected,
                              activeColor: Colors.amber,
                              checkColor: Colors.black,
                              onChanged: (value) {
                                setState(() {
                                  if (value == true) {
                                    _selectedProfessoresIds.add(professor.id!);
                                  } else {
                                    _selectedProfessoresIds
                                        .remove(professor.id);
                                  }
                                });
                              },
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Alunos',
                        style: TextStyle(color: Colors.amber, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _alunos.length,
                          itemBuilder: (context, index) {
                            final aluno = _alunos[index];
                            final isSelected =
                                _selectedAlunosIds.contains(aluno.id);
                            return CheckboxListTile(
                              title: Text(
                                aluno.nome,
                                style: const TextStyle(color: Colors.white),
                              ),
                              value: isSelected,
                              activeColor: Colors.amber,
                              checkColor: Colors.black,
                              onChanged: (value) {
                                setState(() {
                                  if (value == true) {
                                    _selectedAlunosIds.add(aluno.id!);
                                  } else {
                                    _selectedAlunosIds.remove(aluno.id);
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
                            Text(widget.turma == null ? 'Salvar' : 'Atualizar'),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
