import 'package:projeto_ddm_ifpr/dto/dto_turma.dart';
import 'package:sqflite/sqflite.dart';
import 'package:projeto_ddm_ifpr/banco/sqlite/conexao.dart';

class DAOTurma {
  final String _inserirTurma = '''
    INSERT INTO turma (nome, horario_inicio, horario_fim, dia_semana)
    VALUES (?, ?, ?, ?)
  ''';

  final String _atualizarTurma = '''
    UPDATE turma
    SET nome = ?, horario_inicio = ?, horario_fim = ?, dia_semana = ?
    WHERE id = ?
  ''';

  final String _deletarTurma = '''
    DELETE FROM turma
    WHERE id = ?
  ''';

  final String _deletarTurmaProfessores = '''
    DELETE FROM turma_professor
    WHERE turma_id = ?
  ''';

  final String _deletarTurmaAlunos = '''
    DELETE FROM turma_aluno
    WHERE turma_id = ?
  ''';

  final String _inserirTurmaProfessor = '''
    INSERT INTO turma_professor (turma_id, professor_id)
    VALUES (?, ?)
  ''';

  final String _inserirTurmaAluno = '''
    INSERT INTO turma_aluno (turma_id, aluno_id)
    VALUES (?, ?)
  ''';

  final String _consultarTodos = '''
    SELECT t.id, t.nome, t.horario_inicio, t.horario_fim, t.dia_semana,
           GROUP_CONCAT(DISTINCT tp.professor_id) as professores_ids,
           GROUP_CONCAT(DISTINCT p.nome) as professores_nomes,
           GROUP_CONCAT(DISTINCT ta.aluno_id) as alunos_ids,
           GROUP_CONCAT(DISTINCT a.nome) as alunos_nomes
    FROM turma t
    LEFT JOIN turma_professor tp ON t.id = tp.turma_id
    LEFT JOIN professor p ON tp.professor_id = p.id
    LEFT JOIN turma_aluno ta ON t.id = ta.turma_id
    LEFT JOIN aluno a ON ta.aluno_id = a.id
    GROUP BY t.id
  ''';

  final String _consultarPorId = '''
    SELECT t.id, t.nome, t.horario_inicio, t.horario_fim, t.dia_semana,
           GROUP_CONCAT(DISTINCT tp.professor_id) as professores_ids,
           GROUP_CONCAT(DISTINCT p.nome) as professores_nomes,
           GROUP_CONCAT(DISTINCT ta.aluno_id) as alunos_ids,
           GROUP_CONCAT(DISTINCT a.nome) as alunos_nomes
    FROM turma t
    LEFT JOIN turma_professor tp ON t.id = tp.turma_id
    LEFT JOIN professor p ON tp.professor_id = p.id
    LEFT JOIN turma_aluno ta ON t.id = ta.turma_id
    LEFT JOIN aluno a ON ta.aluno_id = a.id
    WHERE t.id = ?
    GROUP BY t.id
  ''';

  final String _verificarConflitoProfessor = '''
    SELECT t.id, t.nome
    FROM turma t
    JOIN turma_professor tp ON t.id = tp.turma_id
    WHERE tp.professor_id = ? 
      AND t.dia_semana = ?
      AND (
        (t.horario_inicio <= ? AND t.horario_fim > ?)
        OR (t.horario_inicio < ? AND t.horario_fim >= ?)
        OR (? <= t.horario_inicio AND ? >= t.horario_fim)
      )
      AND t.id != ?
  ''';

  Map<String, dynamic> toMap(TurmaDTO turma) {
    return {
      'id': turma.id,
      'nome': turma.nome,
      'horario_inicio': turma.horarioInicio,
      'horario_fim': turma.horarioFim,
      'dia_semana': turma.diaSemana,
      'professores_ids': turma.professoresIds,
      'professores_nomes': turma.professoresNomes,
      'alunos_ids': turma.alunosIds,
      'alunos_nomes': turma.alunosNomes,
    };
  }

  TurmaDTO fromMap(Map<String, dynamic> map) {
    final List<String> professoresIds = map['professores_ids'] != null
        ? (map['professores_ids'] as String).split(',')
        : [];
    final List<String>? professoresNomes = map['professores_nomes'] != null
        ? (map['professores_nomes'] as String).split(',')
        : null;
    final List<String> alunosIds = map['alunos_ids'] != null
        ? (map['alunos_ids'] as String).split(',')
        : [];
    final List<String>? alunosNomes = map['alunos_nomes'] != null
        ? (map['alunos_nomes'] as String).split(',')
        : null;

    return TurmaDTO(
      id: map['id']?.toString(),
      nome: map['nome'],
      horarioInicio: map['horario_inicio'],
      horarioFim: map['horario_fim'],
      diaSemana: map['dia_semana'],
      professoresIds: professoresIds,
      professoresNomes: professoresNomes,
      alunosIds: alunosIds,
      alunosNomes: alunosNomes,
    );
  }

  Future<String?> verificarConflitoProfessor(int professorId,
      String horarioInicio, String horarioFim, String diaSemana,
      {String? turmaId}) async {
    final Database db = await ConexaoSQLite.database;
    final List<Map<String, dynamic>> result = await db.rawQuery(
      _verificarConflitoProfessor,
      [
        professorId,
        diaSemana,
        horarioFim,
        horarioInicio,
        horarioInicio,
        horarioFim,
        horarioInicio,
        horarioFim,
        turmaId ?? -1,
      ],
    );
    if (result.isNotEmpty) {
      return result.first['nome'] as String;
    }
    return null;
  }

  Future<void> salvar(TurmaDTO turma) async {
    final Database db = await ConexaoSQLite.database;
    try {
      for (String professorId in turma.professoresIds) {
        final parsedId = int.tryParse(professorId);
        if (parsedId == null) {
          throw Exception('ID de professor inválido: $professorId');
        }
        final conflito = await verificarConflitoProfessor(
          parsedId,
          turma.horarioInicio!,
          turma.horarioFim!,
          turma.diaSemana!,
          turmaId: turma.id,
        );
        if (conflito != null) {
          throw Exception(
              'Conflito de horário: Professor já está na turma $conflito no mesmo horário e dia.');
        }
      }

      await db.transaction((txn) async {
        if (turma.id == null) {
          final int id = await txn.rawInsert(
            _inserirTurma,
            [
              turma.nome,
              turma.horarioInicio,
              turma.horarioFim,
              turma.diaSemana
            ],
          );
          turma.id = id.toString();
          if (turma.professoresIds.isNotEmpty) {
            for (String professorId in turma.professoresIds) {
              final parsedId = int.tryParse(professorId);
              if (parsedId == null) {
                throw Exception('ID de professor inválido: $professorId');
              }
              await txn.rawInsert(
                _inserirTurmaProfessor,
                [id, parsedId],
              );
            }
          }
          if (turma.alunosIds.isNotEmpty) {
            for (String alunoId in turma.alunosIds) {
              final parsedId = int.tryParse(alunoId);
              if (parsedId == null) {
                throw Exception('ID de aluno inválido: $alunoId');
              }
              await txn.rawInsert(
                _inserirTurmaAluno,
                [id, parsedId],
              );
            }
          }
        } else {
          await txn.rawUpdate(
            _atualizarTurma,
            [
              turma.nome,
              turma.horarioInicio,
              turma.horarioFim,
              turma.diaSemana,
              int.parse(turma.id!)
            ],
          );
          await txn.rawDelete(_deletarTurmaProfessores, [int.parse(turma.id!)]);
          await txn.rawDelete(_deletarTurmaAlunos, [int.parse(turma.id!)]);
          if (turma.professoresIds.isNotEmpty) {
            for (String professorId in turma.professoresIds) {
              final parsedId = int.tryParse(professorId);
              if (parsedId == null) {
                throw Exception('ID de professor inválido: $professorId');
              }
              await txn.rawInsert(
                _inserirTurmaProfessor,
                [int.parse(turma.id!), parsedId],
              );
            }
          }
          if (turma.alunosIds.isNotEmpty) {
            for (String alunoId in turma.alunosIds) {
              final parsedId = int.tryParse(alunoId);
              if (parsedId == null) {
                throw Exception('ID de aluno inválido: $alunoId');
              }
              await txn.rawInsert(
                _inserirTurmaAluno,
                [int.parse(turma.id!), parsedId],
              );
            }
          }
        }
      });
    } catch (e, stackTrace) {
      print('Erro ao salvar turma: $e, stack: $stackTrace');
      throw Exception('Erro ao salvar turma: $e');
    }
  }

  Future<List<TurmaDTO>> consultarTodos() async {
    final Database db = await ConexaoSQLite.database;
    try {
      print('Executando consulta de turmas');
      final List<Map<String, dynamic>> maps =
          await db.rawQuery(_consultarTodos);
      print('Resultados da consulta: $maps');
      return maps.map((map) => fromMap(map)).toList();
    } catch (e, stackTrace) {
      print('Erro ao consultar turmas: $e, stack: $stackTrace');
      throw Exception('Erro ao consultar turmas: $e');
    }
  }

  Future<TurmaDTO?> consultarPorId(int id) async {
    final Database db = await ConexaoSQLite.database;
    try {
      print('Consultando turma por ID: $id');
      final List<Map<String, dynamic>> maps =
          await db.rawQuery(_consultarPorId, [id]);
      print('Resultado da consulta: $maps');
      if (maps.isEmpty) return null;
      return fromMap(maps.first);
    } catch (e, stackTrace) {
      print('Erro ao consultar turma por ID: $e, stack: $stackTrace');
      throw Exception('Erro ao consultar turma por ID: $e');
    }
  }

  Future<void> excluir(int id) async {
    final Database db = await ConexaoSQLite.database;
    try {
      print('Excluindo turma: $id');
      await db.transaction((txn) async {
        await txn.rawDelete(_deletarTurmaProfessores, [id]);
        await txn.rawDelete(_deletarTurmaAlunos, [id]);
        await txn.rawDelete(_deletarTurma, [id]);
      });
    } catch (e, stackTrace) {
      print('Erro ao excluir turma: $e, stack: $stackTrace');
      throw Exception('Erro ao excluir turma: $e');
    }
  }
}
