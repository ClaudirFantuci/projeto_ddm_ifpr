// import 'package:flutter/material.dart';
// import 'package:projeto_ddm_ifpr/banco/sqlite/dao/dao_agendamento.dart';
// import 'package:projeto_ddm_ifpr/configuracao/rotas.dart';
// import 'package:projeto_ddm_ifpr/dto/dto_agendamento.dart';

// class WidgetListaAgendamentos extends StatefulWidget {
//   const WidgetListaAgendamentos({super.key});

//   @override
//   State<WidgetListaAgendamentos> createState() =>
//       _WidgetListaAgendamentosState();
// }

// class _WidgetListaAgendamentosState extends State<WidgetListaAgendamentos> {
//   final _daoAgendamento = DAOAgendamento();
//   List<DTOAgendamento> _agendamentos = [];

//   @override
//   void initState() {
//     super.initState();
//     _carregarAgendamentos();
//   }

//   Future<void> _carregarAgendamentos() async {
//     try {
//       _agendamentos = await _daoAgendamento.consultarTodos();
//       print('Agendamentos carregados: ${_agendamentos.length}');
//       setState(() {});
//     } catch (e) {
//       if (mounted) {
//         print('Erro ao carregar agendamentos: $e');
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Erro ao carregar agendamentos: $e'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
//   }

//   Future<void> _excluirAgendamento(int id) async {
//     try {
//       await _daoAgendamento.excluir(id);
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Agendamento excluído com sucesso!'),
//             backgroundColor: Colors.green,
//           ),
//         );
//         _carregarAgendamentos(); // Refresh list
//       }
//     } catch (e) {
//       if (mounted) {
//         print('Erro ao excluir agendamento: $e');
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Erro ao excluir agendamento: $e'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       appBar: AppBar(
//         backgroundColor: Colors.amber,
//         title: const Text(
//           'Lista de Agendamentos',
//           style: TextStyle(color: Colors.black),
//         ),
//         iconTheme: const IconThemeData(color: Colors.black),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: _agendamentos.isEmpty
//             ? const Center(
//                 child: Text(
//                   'Nenhum agendamento encontrado.',
//                   style: TextStyle(color: Colors.white, fontSize: 16),
//                 ),
//               )
//             : ListView.builder(
//                 itemCount: _agendamentos.length,
//                 itemBuilder: (context, index) {
//                   final agendamento = _agendamentos[index];
//                   final participantes = agendamento.turmaId != null
//                       ? agendamento.turmaNome ?? 'Turma desconhecida'
//                       : agendamento.alunosNomes?.join(', ') ?? 'Nenhum aluno';
//                   return Card(
//                     color: const Color.fromARGB(255, 36, 36, 36),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     margin: const EdgeInsets.symmetric(vertical: 8),
//                     child: ListTile(
//                       contentPadding: const EdgeInsets.all(16),
//                       title: Text(
//                         '${agendamento.diaSemana} - ${agendamento.horario}',
//                         style:
//                             const TextStyle(color: Colors.white, fontSize: 18),
//                       ),
//                       subtitle: Text(
//                         'Academia: ${agendamento.academiaNome ?? "Desconhecida"}\nParticipantes: $participantes',
//                         style: const TextStyle(color: Colors.white70),
//                       ),
//                       trailing: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           IconButton(
//                             icon: const Icon(Icons.edit, color: Colors.amber),
//                             onPressed: () {
//                               Navigator.pushNamed(
//                                 context,
//                                 Rotas.cadastroAgendamentos,
//                                 arguments: agendamento,
//                               ).then((_) => _carregarAgendamentos());
//                             },
//                           ),
//                           IconButton(
//                             icon: const Icon(Icons.delete, color: Colors.red),
//                             onPressed: () async {
//                               final confirm = await showDialog<bool>(
//                                 context: context,
//                                 builder: (context) => AlertDialog(
//                                   backgroundColor:
//                                       const Color.fromARGB(255, 36, 36, 36),
//                                   title: const Text(
//                                     'Confirmar Exclusão',
//                                     style: TextStyle(color: Colors.white),
//                                   ),
//                                   content: const Text(
//                                     'Deseja excluir este agendamento?',
//                                     style: TextStyle(color: Colors.white70),
//                                   ),
//                                   actions: [
//                                     TextButton(
//                                       onPressed: () =>
//                                           Navigator.pop(context, false),
//                                       child: const Text(
//                                         'Cancelar',
//                                         style: TextStyle(color: Colors.amber),
//                                       ),
//                                     ),
//                                     TextButton(
//                                       onPressed: () =>
//                                           Navigator.pop(context, true),
//                                       child: const Text(
//                                         'Excluir',
//                                         style: TextStyle(color: Colors.red),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               );
//                               if (confirm == true && mounted) {
//                                 await _excluirAgendamento(
//                                     int.parse(agendamento.id!));
//                               }
//                             },
//                           ),
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//               ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         backgroundColor: Colors.amber,
//         foregroundColor: Colors.black,
//         onPressed: () {
//           Navigator.pushNamed(context, Rotas.cadastroAgendamentos)
//               .then((_) => _carregarAgendamentos());
//         },
//         child: const Icon(Icons.add),
//       ),
//     );
//   }
// }
