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
  String? _selectedHorarioInicio;
  String? _selectedHorarioFim;
  String? _selectedDiaSemana;

  static const List<String> _horariosDisponiveis = [
    '06:00',
    '06:30',
    '07:00',
    '07:30',
    '08:00',
    '08:30',
    '09:00',
    '09:30',
    '10:00',
    '10:30',
    '11:00',
    '11:30',
    '12:00',
    '12:30',
    '13:00',
    '13:30',
    '14:00',
    '14:30',
    '15:00',
    '15:30',
    '16:00',
    '16:30',
    '17:00',
    '17:30',
    '18:00',
    '18:30',
    '19:00',
    '19:30',
    '20:00',
    '20:30',
    '21:00',
    '21:30',
    '22:00',
  ];

  static const List<String> _diasSemana = [
    'Segunda',
    'Terça',
    'Quarta',
    'Quinta',
    'Sexta',
    'Sábado',
    'Domingo',
  ];

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
      _selectedHorarioInicio = widget.turma!.horarioInicio;
      _selectedHorarioFim = widget.turma!.horarioFim;
      _selectedDiaSemana = widget.turma!.diaSemana;
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
      if (_selectedHorarioInicio == null ||
          _selectedHorarioFim == null ||
          _selectedDiaSemana == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Selecione horário de início, fim e dia da semana.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final inicioIndex = _horariosDisponiveis.indexOf(_selectedHorarioInicio!);
      final fimIndex = _horariosDisponiveis.indexOf(_selectedHorarioFim!);
      if (fimIndex <= inicioIndex) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'O horário de fim deve ser posterior ao horário de início.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final turma = TurmaDTO(
        id: widget.turma?.id,
        nome: _nomeController.text,
        horarioInicio: _selectedHorarioInicio,
        horarioFim: _selectedHorarioFim,
        diaSemana: _selectedDiaSemana,
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
                            return 'O nome da turma é obrigatório';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedDiaSemana,
                        decoration: const InputDecoration(
                          labelText: 'Dia da Semana',
                          labelStyle: TextStyle(color: Colors.amber),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.amber),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.amber),
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
                        dropdownColor: Colors.grey[850],
                        items: _diasSemana.map((dia) {
                          return DropdownMenuItem<String>(
                            value: dia,
                            child: Text(dia,
                                style: const TextStyle(color: Colors.white)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedDiaSemana = value;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Selecione um dia da semana';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedHorarioInicio,
                        decoration: const InputDecoration(
                          labelText: 'Horário de Início',
                          labelStyle: TextStyle(color: Colors.amber),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.amber),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.amber),
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
                        dropdownColor: Colors.grey[850],
                        items: _horariosDisponiveis.map((horario) {
                          return DropdownMenuItem<String>(
                            value: horario,
                            child: Text(horario,
                                style: const TextStyle(color: Colors.white)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedHorarioInicio = value;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Selecione um horário de início';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedHorarioFim,
                        decoration: const InputDecoration(
                          labelText: 'Horário de Fim',
                          labelStyle: TextStyle(color: Colors.amber),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.amber),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.amber),
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
                        dropdownColor: Colors.grey[850],
                        items: _horariosDisponiveis.map((horario) {
                          return DropdownMenuItem<String>(
                            value: horario,
                            child: Text(horario,
                                style: const TextStyle(color: Colors.white)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedHorarioFim = value;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Selecione um horário de fim';
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
