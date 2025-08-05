// import 'package:flutter/foundation.dart';
// import 'package:sqflite/sqflite.dart';
// import 'package:projeto_ddm_ifpr/banco/sqlite/conexao.dart';
// import 'package:projeto_ddm_ifpr/dto/dto_agendamento.dart';
// import 'package:projeto_ddm_ifpr/dto/dto_academia.dart';
// import 'package:projeto_ddm_ifpr/dto/dto_aluno.dart';
// import 'package:projeto_ddm_ifpr/dto/dto_turma.dart';

// class DAOAgendamento {
//   final String _criarTabelaAgendamento = '''
//     CREATE TABLE agendamento (
//       id INTEGER PRIMARY KEY AUTOINCREMENT,
//       dia_semana TEXT NOT NULL,
//       horario TEXT NOT NULL,
//       academia_id INTEGER NOT NULL,
//       turma_id INTEGER,
//       FOREIGN KEY (academia_id) REFERENCES academia(id),
//       FOREIGN KEY (turma_id) REFERENCES turma(id)
//     )
//   ''';

//   final String _criarTabelaAgendamentoAluno = '''
//     CREATE TABLE agendamento_aluno (
//       agendamento_id INTEGER NOT NULL,
//       aluno_id INTEGER NOT NULL,
//       PRIMARY KEY (agendamento_id, aluno_id),
//       FOREIGN KEY (agendamento_id) REFERENCES agendamento(id),
//       FOREIGN KEY (aluno_id) REFERENCES aluno(id)
//     )
//   ''';

//   final String _inserirAgendamento = '''
//     INSERT INTO agendamento (dia_semana, horario, academia_id, turma_id)
//     VALUES (?, ?, ?, ?)
//   ''';

//   final String _atualizarAgendamento = '''
//     UPDATE agendamento
//     SET dia_semana = ?, horario = ?, academia_id = ?, turma_id = ?
//     WHERE id = ?
//   ''';

//   final String _deletarAgendamento = '''
//     DELETE FROM agendamento
//     WHERE id = ?
//   ''';

//   final String _deletarAgendamentoAlunos = '''
//     DELETE FROM agendamento_aluno
//     WHERE agendamento_id = ?
//   ''';

//   final String _inserirAgendamentoAluno = '''
//     INSERT INTO agendamento_aluno (agendamento_id, aluno_id)
//     VALUES (?, ?)
//   ''';

//   final String _consultarTodos = '''
//     SELECT a.id, a.dia_semana, a.horario, a.academia_id, a.turma_id,
//            ac.nome as academia_nome,
//            t.nome as turma_nome,
//            GROUP_CONCAT(aa.aluno_id) as alunos_ids,
//            GROUP_CONCAT(al.nome) as alunos_nomes
//     FROM agendamento a
//     LEFT JOIN academia ac ON a.academia_id = ac.id
//     LEFT JOIN turma t ON a.turma_id = t.id
//     LEFT JOIN agendamento_aluno aa ON a.id = aa.agendamento_id
//     LEFT JOIN aluno al ON aa.aluno_id = al.id
//     GROUP BY a.id
//   ''';

//   final String _consultarPorId = '''
//     SELECT a.id, a.dia_semana, a.horario, a.academia_id, a.turma_id,
//            ac.nome as academia_nome,
//            t.nome as turma_nome,
//            GROUP_CONCAT(aa.aluno_id) as alunos_ids,
//            GROUP_CONCAT(al.nome) as alunos_nomes
//     FROM agendamento a
//     LEFT JOIN academia ac ON a.academia_id = ac.id
//     LEFT JOIN turma t ON a.turma_id = t.id
//     LEFT JOIN agendamento_aluno aa ON a.id = aa.agendamento_id
//     LEFT JOIN aluno al ON aa.aluno_id = al.id
//     WHERE a.id = ?
//     GROUP BY a.id
//   ''';

//   Map<String, dynamic> toMap(DTOAgendamento agendamento) {
//     return {
//       'id': agendamento.id != null ? int.tryParse(agendamento.id!) : null,
//       'dia_semana': agendamento.diaSemana,
//       'horario': agendamento.horario,
//       'academia_id': int.tryParse(agendamento.academiaId),
//       'turma_id': agendamento.turmaId != null
//           ? int.tryParse(agendamento.turmaId!)
//           : null,
//       'academia_nome': agendamento.academiaNome,
//       'turma_nome': agendamento.turmaNome,
//       'alunos_ids': agendamento.alunosIds,
//       'alunos_nomes': agendamento.alunosNomes,
//     };
//   }

//   DTOAgendamento fromMap(Map<String, dynamic> map) {
//     try {
//       final List<String> alunosIds = map['alunos_ids'] != null
//           ? (map['alunos_ids'] as String).split(',')
//           : [];
//       final List<String>? alunosNomes = map['alunos_nomes'] != null
//           ? (map['alunos_nomes'] as String).split(',')
//           : null;

//       return DTOAgendamento(
//         id: map['id']?.toString(),
//         diaSemana: map['dia_semana'] as String? ?? 'Desconhecido',
//         horario: map['horario'] as String? ?? '00:00',
//         academiaId: map['academia_id']?.toString() ?? '0',
//         academiaNome: map['academia_nome'] as String?,
//         turmaId: map['turma_id']?.toString(),
//         turmaNome: map['turma_nome'] as String?,
//         alunosIds: alunosIds,
//         alunosNomes: alunosNomes,
//       );
//     } catch (e) {
//       debugPrint('Erro ao parsear mapa para DTOAgendamento: $e');
//       throw Exception('Erro ao parsear agendamento: $e');
//     }
//   }

//   Future<void> salvar(DTOAgendamento agendamento) async {
//     final Database db = await ConexaoSQLite.database;
//     try {
//       await db.transaction((txn) async {
//         final academiaId = int.tryParse(agendamento.academiaId);
//         if (academiaId == null) {
//           throw Exception('ID da academia inválido');
//         }

//         int id;
//         if (agendamento.id == null) {
//           // Insert
//           id = await txn.rawInsert(
//             _inserirAgendamento,
//             [
//               agendamento.diaSemana,
//               agendamento.horario,
//               academiaId,
//               agendamento.turmaId != null
//                   ? int.tryParse(agendamento.turmaId!)
//                   : null,
//             ],
//           );
//           agendamento.id = id.toString();
//         } else {
//           // Update
//           id = int.parse(agendamento.id!);
//           await txn.rawUpdate(
//             _atualizarAgendamento,
//             [
//               agendamento.diaSemana,
//               agendamento.horario,
//               academiaId,
//               agendamento.turmaId != null
//                   ? int.tryParse(agendamento.turmaId!)
//                   : null,
//               id,
//             ],
//           );
//           await txn.rawDelete(_deletarAgendamentoAlunos, [id]);
//         }

//         // Insert student associations if no turma is selected
//         if (agendamento.turmaId == null && agendamento.alunosIds.isNotEmpty) {
//           for (String alunoId in agendamento.alunosIds) {
//             final parsedAlunoId = int.tryParse(alunoId);
//             if (parsedAlunoId != null) {
//               await txn.rawInsert(
//                 _inserirAgendamentoAluno,
//                 [id, parsedAlunoId],
//               );
//             } else {
//               debugPrint('ID de aluno inválido ignorado: $alunoId');
//             }
//           }
//         }
//       });
//     } catch (e) {
//       debugPrint('Erro ao salvar agendamento: $e');
//       throw Exception('Erro ao salvar agendamento: $e');
//     }
//   }

//   Future<List<DTOAgendamento>> consultarTodos() async {
//     final Database db = await ConexaoSQLite.database;
//     try {
//       final List<Map<String, dynamic>> maps =
//           await db.rawQuery(_consultarTodos);
//       debugPrint('Agendamentos carregados: ${maps.length}');
//       return maps.map((map) => fromMap(map)).toList();
//     } catch (e) {
//       debugPrint('Erro ao consultar agendamentos: $e');
//       throw Exception('Erro ao consultar agendamentos: $e');
//     }
//   }

//   Future<DTOAgendamento?> consultarPorId(int id) async {
//     final Database db = await ConexaoSQLite.database;
//     try {
//       final List<Map<String, dynamic>> maps =
//           await db.rawQuery(_consultarPorId, [id]);
//       if (maps.isEmpty) return null;
//       return fromMap(maps.first);
//     } catch (e) {
//       debugPrint('Erro ao consultar agendamento por ID: $e');
//       throw Exception('Erro ao consultar agendamento por ID: $e');
//     }
//   }

//   Future<void> excluir(int id) async {
//     final Database db = await ConexaoSQLite.database;
//     try {
//       await db.transaction((txn) async {
//         await txn.rawDelete(_deletarAgendamentoAlunos, [id]);
//         await txn.rawDelete(_deletarAgendamento, [id]);
//       });
//     } catch (e) {
//       debugPrint('Erro ao excluir agendamento: $e');
//       throw Exception('Erro ao excluir agendamento: $e');
//     }
//   }
// }
