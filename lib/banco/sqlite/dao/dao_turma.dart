import 'package:projeto_ddm_ifpr/dto/dto_turma.dart';
import 'package:sqflite/sqflite.dart';
import 'package:projeto_ddm_ifpr/banco/sqlite/conexao.dart';

class DAOTurma {
  final String _criarTabelaTurma = '''
    CREATE TABLE turma (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nome TEXT NOT NULL,
      horario TEXT
    )
  ''';

  final String _criarTabelaTurmaProfessor = '''
    CREATE TABLE turma_professor (
      turma_id INTEGER NOT NULL,
      professor_id INTEGER NOT NULL,
      PRIMARY KEY (turma_id, professor_id),
      FOREIGN KEY (turma_id) REFERENCES turma(id),
      FOREIGN KEY (professor_id) REFERENCES professor(id)
    )
  ''';

  final String _criarTabelaTurmaAluno = '''
    CREATE TABLE turma_aluno (
      turma_id INTEGER NOT NULL,
      aluno_id INTEGER NOT NULL,
      PRIMARY KEY (turma_id, aluno_id),
      FOREIGN KEY (turma_id) REFERENCES turma(id),
      FOREIGN KEY (aluno_id) REFERENCES aluno(id)
    )
  ''';

  final String _inserirTurma = '''
    INSERT INTO turma (nome, horario)
    VALUES (?, ?)
  ''';

  final String _atualizarTurma = '''
    UPDATE turma
    SET nome = ?, horario = ?
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
    SELECT t.id, t.nome, t.horario,
           GROUP_CONCAT(tp.professor_id) as professores_ids,
           GROUP_CONCAT(p.nome) as professores_nomes,
           GROUP_CONCAT(ta.aluno_id) as alunos_ids,
           GROUP_CONCAT(a.nome) as alunos_nomes
    FROM turma t
    LEFT JOIN turma_professor tp ON t.id = tp.turma_id
    LEFT JOIN professor p ON tp.professor_id = p.id
    LEFT JOIN turma_aluno ta ON t.id = ta.turma_id
    LEFT JOIN aluno a ON ta.aluno_id = a.id
    GROUP BY t.id
  ''';

  final String _consultarPorId = '''
    SELECT t.id, t.nome, t.horario,
           GROUP_CONCAT(tp.professor_id) as professores_ids,
           GROUP_CONCAT(p.nome) as professores_nomes,
           GROUP_CONCAT(ta.aluno_id) as alunos_ids,
           GROUP_CONCAT(a.nome) as alunos_nomes
    FROM turma t
    LEFT JOIN turma_professor tp ON t.id = tp.turma_id
    LEFT JOIN professor p ON tp.professor_id = p.id
    LEFT JOIN turma_aluno ta ON t.id = ta.turma_id
    LEFT JOIN aluno a ON ta.aluno_id = a.id
    WHERE t.id = ?
    GROUP BY t.id
  ''';

  Map<String, dynamic> toMap(TurmaDTO turma) {
    return {
      'id': turma.id,
      'nome': turma.nome,
      'horario': turma.horario,
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
      horario: map['horario'],
      professoresIds: professoresIds,
      professoresNomes: professoresNomes,
      alunosIds: alunosIds,
      alunosNomes: alunosNomes,
    );
  }

  Future<void> salvar(TurmaDTO turma) async {
    final Database db = await ConexaoSQLite.database;
    try {
      await db.transaction((txn) async {
        if (turma.id == null) {
          // Insert
          final int id = await txn.rawInsert(
            _inserirTurma,
            [turma.nome, turma.horario],
          );
          turma.id = id.toString();

          // Insert professors
          for (String professorId in turma.professoresIds) {
            await txn.rawInsert(
              _inserirTurmaProfessor,
              [id, int.parse(professorId)],
            );
          }

          // Insert students
          for (String alunoId in turma.alunosIds) {
            await txn.rawInsert(
              _inserirTurmaAluno,
              [id, int.parse(alunoId)],
            );
          }
        } else {
          // Update
          await txn.rawUpdate(
            _atualizarTurma,
            [turma.nome, turma.horario, int.parse(turma.id!)],
          );

          // Delete existing associations
          await txn.rawDelete(_deletarTurmaProfessores, [int.parse(turma.id!)]);
          await txn.rawDelete(_deletarTurmaAlunos, [int.parse(turma.id!)]);

          // Insert updated professors
          for (String professorId in turma.professoresIds) {
            await txn.rawInsert(
              _inserirTurmaProfessor,
              [int.parse(turma.id!), int.parse(professorId)],
            );
          }

          // Insert updated students
          for (String alunoId in turma.alunosIds) {
            await txn.rawInsert(
              _inserirTurmaAluno,
              [int.parse(turma.id!), int.parse(alunoId)],
            );
          }
        }
      });
    } catch (e) {
      throw Exception('Erro ao salvar turma: $e');
    }
  }

  Future<List<TurmaDTO>> consultarTodos() async {
    final Database db = await ConexaoSQLite.database;
    try {
      final List<Map<String, dynamic>> maps =
          await db.rawQuery(_consultarTodos);
      return maps.map((map) => fromMap(map)).toList();
    } catch (e) {
      throw Exception('Erro ao consultar turmas: $e');
    }
  }

  Future<TurmaDTO?> consultarPorId(int id) async {
    final Database db = await ConexaoSQLite.database;
    try {
      final List<Map<String, dynamic>> maps =
          await db.rawQuery(_consultarPorId, [id]);
      if (maps.isEmpty) return null;
      return fromMap(maps.first);
    } catch (e) {
      throw Exception('Erro ao consultar turma por ID: $e');
    }
  }

  Future<void> excluir(int id) async {
    final Database db = await ConexaoSQLite.database;
    try {
      await db.transaction((txn) async {
        await txn.rawDelete(_deletarTurmaProfessores, [id]);
        await txn.rawDelete(_deletarTurmaAlunos, [id]);
        await txn.rawDelete(_deletarTurma, [id]);
      });
    } catch (e) {
      throw Exception('Erro ao excluir turma: $e');
    }
  }
}
