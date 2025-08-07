import 'package:flutter/material.dart';
import 'package:projeto_ddm_ifpr/banco/sqlite/dao/dao_academia.dart';
import 'package:projeto_ddm_ifpr/banco/sqlite/dao/dao_aluno.dart';
import 'package:projeto_ddm_ifpr/banco/sqlite/dao/dao_agendamento.dart';
import 'package:projeto_ddm_ifpr/banco/sqlite/dao/dao_turma.dart';
import 'package:projeto_ddm_ifpr/dto/dto_academia.dart';
import 'package:projeto_ddm_ifpr/dto/dto_aluno.dart';
import 'package:projeto_ddm_ifpr/dto/dto_agendamento.dart';
import 'package:projeto_ddm_ifpr/dto/dto_turma.dart';

class CadastroAgendamento extends StatefulWidget {
  final DTOAgendamento? agendamento;

  const CadastroAgendamento({super.key, this.agendamento});

  @override
  State<CadastroAgendamento> createState() => _CadastroAgendamentoState();
}

class _CadastroAgendamentoState extends State<CadastroAgendamento> {
  final _formKey = GlobalKey<FormState>();
  final _dao = DAOAgendamento();
  final _daoAcademia = DAOAcademia();
  final _daoTurma = DAOTurma();
  final _daoAluno = DAOAluno();
  String? _selectedDiaSemana;
  String? _selectedHorarioInicio;
  String? _selectedHorarioFim;
  DTOAcademia? _selectedAcademia;
  TurmaDTO? _selectedTurma;
  List<AlunoDTO> _selectedAlunos = [];
  bool _isEditing = false;
  bool _showTurma = true; // Toggle between turma and alunos
  List<DTOAcademia> _academias = [];
  List<TurmaDTO> _turmas = [];
  List<AlunoDTO> _alunos = [];

  // List of days of the week
  final List<String> _diasSemana = [
    'Segunda-feira',
    'Terça-feira',
    'Quarta-feira',
    'Quinta-feira',
    'Sexta-feira',
    'Sábado',
    'Domingo',
  ];

  // Generate time slots from 7:00 to 21:00 in 30-minute intervals
  final List<String> _horarios = List.generate(
    29, // 7:00 to 21:00 inclusive (28 half-hours + 21:00)
    (index) {
      final hour = 7 + (index ~/ 2);
      final minute = (index % 2) * 30;
      return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
    },
  );

  @override
  void initState() {
    super.initState();
    _isEditing = widget.agendamento != null;
    _selectedDiaSemana = widget.agendamento?.diaSemana;
    _selectedHorarioInicio = widget.agendamento?.horarioInicio;
    _selectedHorarioFim = widget.agendamento?.horarioFim;
    _showTurma = widget.agendamento?.turmaId != null ||
        widget.agendamento?.alunosIds == null;
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final academias = await _daoAcademia.consultarTodos();
      final turmas = await _daoTurma.consultarTodos();
      final alunos = await _daoAluno.consultarTodos();
      setState(() {
        _academias = academias;
        _turmas = turmas;
        _alunos = alunos;
        if (_isEditing) {
          _selectedAcademia = _academias.firstWhere(
            (academia) => academia.id == widget.agendamento!.academiaId,
            orElse: () => DTOAcademia(
              id: widget.agendamento!.academiaId,
              nome: widget.agendamento!.academiaNome ?? '',
              endereco: '',
              telefone: '',
              cidade: '',
            ),
          );
          _selectedTurma = widget.agendamento!.turmaId != null
              ? _turmas.firstWhere(
                  (turma) => turma.id == widget.agendamento!.turmaId,
                  orElse: () => TurmaDTO(
                    id: widget.agendamento!.turmaId,
                    nome: widget.agendamento!.turmaNome ?? '',
                    professoresIds: [],
                    professoresNomes: [],
                    alunosIds: [],
                    alunosNomes: [],
                  ),
                )
              : null;
          _selectedAlunos = widget.agendamento!.alunosIds != null
              ? _alunos
                  .where((aluno) =>
                      widget.agendamento!.alunosIds!.contains(aluno.id))
                  .toList()
              : [];
        }
      });
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar dados: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _toggleSelectionMode(bool showTurma) {
    setState(() {
      _showTurma = showTurma;
      if (showTurma) {
        _selectedAlunos = []; // Clear alunos when switching to turma
      } else {
        _selectedTurma = null; // Clear turma when switching to alunos
      }
    });
  }

  void _salvarAgendamento() async {
    if (_formKey.currentState!.validate()) {
      try {
        final agendamento = DTOAgendamento(
          id: _isEditing ? widget.agendamento!.id : null,
          diaSemana: _selectedDiaSemana!,
          horarioInicio: _selectedHorarioInicio!,
          horarioFim: _selectedHorarioFim!,
          academiaId: _selectedAcademia!.id!,
          academiaNome: _selectedAcademia!.nome,
          turmaId: _selectedTurma?.id,
          turmaNome: _selectedTurma?.nome,
          alunosIds: _selectedAlunos.isNotEmpty
              ? _selectedAlunos.map((e) => e.id!).toList()
              : null,
          alunosNomes: _selectedAlunos.isNotEmpty
              ? _selectedAlunos.map((e) => e.nome).toList()
              : null,
        );

        await _dao.salvar(agendamento);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _isEditing
                    ? 'Agendamento atualizado com sucesso!'
                    : 'Agendamento criado com sucesso!',
              ),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao salvar agendamento: $e'),
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
          _isEditing ? 'Editar Agendamento' : 'Criar Agendamento',
          style: const TextStyle(color: Colors.black),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<String>(
                value: _selectedDiaSemana,
                decoration: const InputDecoration(
                  labelText: 'Dia da Semana',
                  labelStyle: TextStyle(color: Colors.white70),
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
                  return DropdownMenuItem(
                    value: dia,
                    child:
                        Text(dia, style: const TextStyle(color: Colors.white)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedDiaSemana = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Por favor, selecione um dia da semana';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: _selectedHorarioInicio,
                decoration: const InputDecoration(
                  labelText: 'Horário de Início',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.amber),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.amber),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
                dropdownColor: Colors.grey[850],
                items: _horarios.map((horario) {
                  return DropdownMenuItem(
                    value: horario,
                    child: Text(horario,
                        style: const TextStyle(color: Colors.white)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedHorarioInicio = value;
                    // Ensure end time is after start time
                    if (_selectedHorarioFim != null) {
                      final startIndex = _horarios.indexOf(value!);
                      final endIndex = _horarios.indexOf(_selectedHorarioFim!);
                      if (endIndex <= startIndex) {
                        _selectedHorarioFim = _horarios[startIndex + 1];
                      }
                    }
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Por favor, selecione um horário de início';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: _selectedHorarioFim,
                decoration: const InputDecoration(
                  labelText: 'Horário de Fim',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.amber),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.amber),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
                dropdownColor: Colors.grey[850],
                items: _horarios.map((horario) {
                  final index = _horarios.indexOf(horario);
                  final startIndex = _selectedHorarioInicio != null
                      ? _horarios.indexOf(_selectedHorarioInicio!)
                      : -1;
                  return DropdownMenuItem(
                    value: horario,
                    enabled: startIndex == -1 || index > startIndex,
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
                    return 'Por favor, selecione um horário de fim';
                  }
                  if (_selectedHorarioInicio != null) {
                    final startIndex =
                        _horarios.indexOf(_selectedHorarioInicio!);
                    final endIndex = _horarios.indexOf(value);
                    if (endIndex <= startIndex) {
                      return 'O horário de fim deve ser após o início';
                    }
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<DTOAcademia>(
                value: _selectedAcademia,
                decoration: const InputDecoration(
                  labelText: 'Academia',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.amber),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.amber),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
                dropdownColor: Colors.grey[850],
                items: _academias.map((academia) {
                  return DropdownMenuItem(
                    value: academia,
                    child: Text(academia.nome,
                        style: const TextStyle(color: Colors.white)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedAcademia = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Por favor, selecione uma academia';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              if (_showTurma)
                DropdownButtonFormField<TurmaDTO>(
                  value: _selectedTurma,
                  decoration: const InputDecoration(
                    labelText: 'Selecionar Turma',
                    labelStyle: TextStyle(color: Colors.white70),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.amber),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.amber),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                  dropdownColor: Colors.grey[850],
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('Nenhuma',
                          style: TextStyle(color: Colors.white)),
                    ),
                    ..._turmas.map((turma) {
                      return DropdownMenuItem(
                        value: turma,
                        child: Text(turma.nome,
                            style: const TextStyle(color: Colors.white)),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedTurma = value;
                    });
                  },
                )
              else
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[850],
                    foregroundColor: Colors.amber,
                  ),
                  onPressed: () => _toggleSelectionMode(true),
                  child: const Text('Selecionar Turma'),
                ),
              if (!_showTurma) const SizedBox(height: 16),
              if (!_showTurma)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Selecionar Alunos',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.amber),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Column(
                        children: _alunos.map((aluno) {
                          return CheckboxListTile(
                            title: Text(aluno.nome,
                                style: const TextStyle(color: Colors.white)),
                            value: _selectedAlunos.contains(aluno),
                            activeColor: Colors.amber,
                            checkColor: Colors.black,
                            onChanged: (bool? selected) {
                              setState(() {
                                if (selected == true) {
                                  _selectedAlunos.add(aluno);
                                } else {
                                  _selectedAlunos.remove(aluno);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                )
              else
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[850],
                    foregroundColor: Colors.amber,
                  ),
                  onPressed: () => _toggleSelectionMode(false),
                  child: const Text('Selecionar Alunos'),
                ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.black,
                    ),
                    onPressed: _salvarAgendamento,
                    child: const Text('Salvar'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[850],
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
