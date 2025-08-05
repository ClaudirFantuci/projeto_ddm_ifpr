// import 'package:flutter/material.dart';
// import 'package:projeto_ddm_ifpr/banco/sqlite/dao/dao_academia.dart';
// import 'package:projeto_ddm_ifpr/banco/sqlite/dao/dao_aluno.dart';
// import 'package:projeto_ddm_ifpr/banco/sqlite/dao/dao_turma.dart';
// import 'package:projeto_ddm_ifpr/dto/dto_academia.dart';
// import 'package:projeto_ddm_ifpr/dto/dto_agendamento.dart';
// import 'package:projeto_ddm_ifpr/dto/dto_aluno.dart';
// import 'package:projeto_ddm_ifpr/dto/dto_turma.dart';

// class WidgetCadastroAgendamentos extends StatefulWidget {
//   final DTOAgendamento? agendamento;

//   const WidgetCadastroAgendamentos({super.key, this.agendamento});

//   @override
//   State<WidgetCadastroAgendamentos> createState() =>
//       _WidgetCadastroAgendamentosState();
// }

// class _WidgetCadastroAgendamentosState
//     extends State<WidgetCadastroAgendamentos> {
//   final _formKey = GlobalKey<FormState>();
//   final _diaSemanaController = TextEditingController();
//   final _horarioController = TextEditingController();
//   final _daoAgendamento = DAOAgendamento();
//   final _daoAcademia = DAOAcademia();
//   final _daoTurma = DAOTurma();
//   final _daoAluno = DAOAluno();
//   List<DTOAcademia> _academias = [];
//   List<DTOAluno> _alunos = [];
//   List<DTOTurma> _turmas = [];
//   String? _selectedAcademiaId;
//   String? _selectedTurmaId;
//   List<String> _selectedAlunoIds = [];
//   bool _useTurma = false;

//   @override
//   void initState() {
//     super.initState();
//     _carregarDados();
//     if (widget.agendamento != null) {
//       _diaSemanaController.text = widget.agendamento!.diaSemana;
//       _horarioController.text = widget.agendamento!.horario;
//       _selectedAcademiaId = widget.agendamento!.academiaId;
//       _selectedTurmaId = widget.agendamento!.turmaId;
//       _selectedAlunoIds = widget.agendamento!.alunosIds;
//       _useTurma = widget.agendamento!.turmaId != null;
//     }
//   }

//   Future<void> _carregarDados() async {
//     try {
//       _academias = await _daoAcademia.consultarTodos();
//       _turmas = await _daoTurma.consultarTodos();
//       _alunos = await _daoAluno.consultarTodos();
//       print('Academias carregadas: ${_academias.map((a) => a.nome).toList()}');
//       print('Turmas carregadas: ${_turmas.map((t) => t.nome).toList()}');
//       print('Alunos carregados: ${_alunos.map((a) => a.nome).toList()}');
//       // Validate existing agendamento data
//       if (widget.agendamento != null) {
//         if (!_academias.any((a) => a.id == widget.agendamento!.academiaId)) {
//           print('Academia inválida: ${widget.agendamento!.academiaId}');
//           if (mounted) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(
//                 content: Text(
//                     'Academia associada não encontrada. Selecione uma nova.'),
//                 backgroundColor: Colors.orange,
//               ),
//             );
//           }
//           _selectedAcademiaId = null;
//         }
//         if (widget.agendamento!.turmaId != null &&
//             !_turmas.any((t) => t.id == widget.agendamento!.turmaId)) {
//           print('Turma inválida: ${widget.agendamento!.turmaId}');
//           if (mounted) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(
//                 content:
//                     Text('Turma associada não encontrada. Selecione uma nova.'),
//                 backgroundColor: Colors.orange,
//               ),
//             );
//           }
//           _selectedTurmaId = null;
//         }
//         if (widget.agendamento!.alunosIds.isNotEmpty) {
//           final validAlunoIds = widget.agendamento!.alunosIds
//               .where((id) => _alunos.any((a) => a.id == id))
//               .toList();
//           if (validAlunoIds.length != widget.agendamento!.alunosIds.length) {
//             print(
//                 'Alunos inválidos: ${widget.agendamento!.alunosIds.where((id) => !_alunos.any((a) => a.id == id)).toList()}');
//             if (mounted) {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(
//                   content: Text(
//                       'Alguns alunos associados não foram encontrados. Atualizando lista.'),
//                   backgroundColor: Colors.orange,
//                 ),
//               );
//             }
//           }
//           _selectedAlunoIds = validAlunoIds;
//         }
//       }
//       setState(() {});
//     } catch (e) {
//       if (mounted) {
//         print('Erro ao carregar dados: $e');
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Erro ao carregar dados: $e'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
//   }

//   @override
//   void dispose() {
//     _diaSemanaController.dispose();
//     _horarioController.dispose();
//     super.dispose();
//   }

//   Future<void> _salvar() async {
//     if (_formKey.currentState!.validate()) {
//       try {
//         if (_selectedAcademiaId == null) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text('Selecione uma academia.'),
//               backgroundColor: Colors.red,
//             ),
//           );
//           return;
//         }
//         if (_useTurma && _selectedTurmaId == null) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text('Selecione uma turma.'),
//               backgroundColor: Colors.red,
//             ),
//           );
//           return;
//         }
//         if (!_useTurma && _selectedAlunoIds.isEmpty) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text('Selecione pelo menos um aluno.'),
//               backgroundColor: Colors.red,
//             ),
//           );
//           return;
//         }

//         // Validate selected aluno IDs
//         final validAlunoIds = _selectedAlunoIds
//             .where((id) => _alunos.any((aluno) => aluno.id == id))
//             .toList();
//         if (_selectedAlunoIds.length != validAlunoIds.length) {
//           print('Alunos inválidos detectados: $_selectedAlunoIds');
//           if (mounted) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(
//                 content: Text(
//                     'Alguns alunos selecionados não são válidos. Usando apenas alunos válidos.'),
//                 backgroundColor: Colors.orange,
//               ),
//             );
//           }
//         }

//         final agendamento = DTOAgendamento(
//           id: widget.agendamento?.id,
//           diaSemana: _diaSemanaController.text,
//           horario: _horarioController.text,
//           academiaId: _selectedAcademiaId!,
//           academiaNome:
//               _academias.firstWhere((a) => a.id == _selectedAcademiaId).nome,
//           turmaId: _useTurma ? _selectedTurmaId : null,
//           turmaNome: _useTurma && _selectedTurmaId != null
//               ? _turmas.firstWhere((t) => t.id == _selectedTurmaId).nome
//               : null,
//           alunosIds: _useTurma ? [] : validAlunoIds,
//           alunosNomes: _useTurma
//               ? []
//               : _alunos
//                   .where((a) => validAlunoIds.contains(a.id))
//                   .map((a) => a.nome)
//                   .toList(),
//         );

//         await _daoAgendamento.salvar(agendamento);
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text(widget.agendamento == null
//                   ? 'Agendamento cadastrado com sucesso!'
//                   : 'Agendamento atualizado com sucesso!'),
//               backgroundColor: Colors.green,
//             ),
//           );
//           Navigator.pop(context);
//         }
//       } catch (e) {
//         if (mounted) {
//           print('Erro ao salvar agendamento: $e');
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text('Erro ao salvar agendamento: $e'),
//               backgroundColor: Colors.red,
//             ),
//           );
//         }
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       appBar: AppBar(
//         backgroundColor: Colors.amber,
//         title: Text(
//           widget.agendamento == null
//               ? 'Cadastro de Agendamentos'
//               : 'Editar Agendamento',
//           style: const TextStyle(color: Colors.black),
//         ),
//         iconTheme: const IconThemeData(color: Colors.black),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Form(
//           key: _formKey,
//           child: Card(
//             color: const Color.fromARGB(255, 36, 36, 36),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   TextFormField(
//                     controller: _diaSemanaController,
//                     decoration: const InputDecoration(
//                       labelText: 'Dia da Semana',
//                       hintText: 'Ex: Segunda-feira',
//                       labelStyle: TextStyle(color: Colors.amber),
//                       hintStyle: TextStyle(color: Colors.amber),
//                       enabledBorder: UnderlineInputBorder(
//                         borderSide: BorderSide(color: Colors.amber),
//                       ),
//                       focusedBorder: UnderlineInputBorder(
//                         borderSide: BorderSide(color: Colors.amber),
//                       ),
//                     ),
//                     style: const TextStyle(color: Colors.white),
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'O dia da semana é obrigatório';
//                       }
//                       return null;
//                     },
//                   ),
//                   const SizedBox(height: 16),
//                   TextFormField(
//                     controller: _horarioController,
//                     decoration: const InputDecoration(
//                       labelText: 'Horário',
//                       hintText: 'Ex: 10:00',
//                       labelStyle: TextStyle(color: Colors.amber),
//                       hintStyle: TextStyle(color: Colors.amber),
//                       enabledBorder: UnderlineInputBorder(
//                         borderSide: BorderSide(color: Colors.amber),
//                       ),
//                       focusedBorder: UnderlineInputBorder(
//                         borderSide: BorderSide(color: Colors.amber),
//                       ),
//                     ),
//                     style: const TextStyle(color: Colors.white),
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'O horário é obrigatório';
//                       }
//                       if (!RegExp(r'^\d{2}:\d{2}$').hasMatch(value)) {
//                         return 'Formato de horário inválido (use HH:MM)';
//                       }
//                       return null;
//                     },
//                   ),
//                   const SizedBox(height: 16),
//                   const Text(
//                     'Academia',
//                     style: TextStyle(color: Colors.amber, fontSize: 16),
//                   ),
//                   DropdownButton<String>(
//                     value: _selectedAcademiaId,
//                     hint: const Text('Selecione uma academia',
//                         style: TextStyle(color: Colors.white70)),
//                     dropdownColor: const Color.fromARGB(255, 36, 36, 36),
//                     isExpanded: true,
//                     items: _academias.map((academia) {
//                       return DropdownMenuItem<String>(
//                         value: academia.id,
//                         child: Text(academia.nome,
//                             style: const TextStyle(color: Colors.white)),
//                       );
//                     }).toList(),
//                     onChanged: (value) {
//                       setState(() {
//                         _selectedAcademiaId = value;
//                       });
//                     },
//                   ),
//                   const SizedBox(height: 16),
//                   Row(
//                     children: [
//                       const Text(
//                         'Selecionar Turma',
//                         style: TextStyle(color: Colors.amber, fontSize: 16),
//                       ),
//                       Switch(
//                         value: _useTurma,
//                         activeColor: Colors.amber,
//                         onChanged: (value) {
//                           setState(() {
//                             _useTurma = value;
//                             if (value) {
//                               _selectedAlunoIds = [];
//                             } else {
//                               _selectedTurmaId = null;
//                             }
//                           });
//                         },
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 8),
//                   if (_useTurma)
//                     DropdownButton<String>(
//                       value: _selectedTurmaId,
//                       hint: const Text('Selecione uma turma',
//                           style: TextStyle(color: Colors.white70)),
//                       dropdownColor: const Color.fromARGB(255, 36, 36, 36),
//                       isExpanded: true,
//                       items: _turmas.map((turma) {
//                         return DropdownMenuItem<String>(
//                           value: turma.id,
//                           child: Text(turma.nome,
//                               style: const TextStyle(color: Colors.white)),
//                         );
//                       }).toList(),
//                       onChanged: (value) {
//                         setState(() {
//                           _selectedTurmaId = value;
//                         });
//                       },
//                     )
//                   else
//                     Expanded(
//                       child: ListView.builder(
//                         itemCount: _alunos.length,
//                         itemBuilder: (context, index) {
//                           final aluno = _alunos[index];
//                           final isSelected =
//                               _selectedAlunoIds.contains(aluno.id);
//                           return CheckboxListTile(
//                             title: Text(
//                               aluno.nome,
//                               style: const TextStyle(color: Colors.white),
//                             ),
//                             subtitle: Text(
//                               'Telefone: ${aluno.telefone}',
//                               style: const TextStyle(color: Colors.white70),
//                             ),
//                             value: isSelected,
//                             activeColor: Colors.amber,
//                             checkColor: Colors.black,
//                             onChanged: (value) {
//                               setState(() {
//                                 if (value == true && aluno.id != null) {
//                                   _selectedAlunoIds.add(aluno.id!);
//                                 } else {
//                                   _selectedAlunoIds.remove(aluno.id);
//                                 }
//                               });
//                             },
//                           );
//                         },
//                       ),
//                     ),
//                   const SizedBox(height: 20),
//                   ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.amber,
//                       foregroundColor: Colors.black,
//                     ),
//                     onPressed: _salvar,
//                     child: Text(
//                         widget.agendamento == null ? 'Salvar' : 'Atualizar'),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
