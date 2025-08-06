import 'package:projeto_ddm_ifpr/dto/dto_professor.dart';
import 'package:sqflite/sqflite.dart';
import 'package:projeto_ddm_ifpr/banco/sqlite/conexao.dart';

class DAOProfessor {
  final String _criarTabelaProfessor = '''
    CREATE TABLE professor (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nome TEXT NOT NULL,
      telefone TEXT NOT NULL CHECK(length(telefone) <= 15)
    )
  ''';

  final String _criarTabelaProfessorModalidade = '''
    CREATE TABLE professor_modalidade (
      professor_id INTEGER NOT NULL,
      modalidade_id INTEGER NOT NULL,
      PRIMARY KEY (professor_id, modalidade_id),
      FOREIGN KEY (professor_id) REFERENCES professor(id) ON DELETE CASCADE,
      FOREIGN KEY (modalidade_id) REFERENCES modalidade(id) ON DELETE CASCADE
    )
  ''';

  final String _inserirProfessor = '''
    INSERT INTO professor (nome, telefone)
    VALUES (?, ?)
  ''';

  final String _atualizarProfessor = '''
    UPDATE professor
    SET nome = ?, telefone = ?
    WHERE id = ?
  ''';

  final String _deletarProfessor = '''
    DELETE FROM professor
    WHERE id = ?
  ''';

  final String _deletarProfessorModalidades = '''
    DELETE FROM professor_modalidade
    WHERE professor_id = ?
  ''';

  final String _inserirProfessorModalidade = '''
    INSERT INTO professor_modalidade (professor_id, modalidade_id)
    VALUES (?, ?)
  ''';

  final String _consultarTodos = '''
    SELECT p.id, p.nome, p.telefone, 
           GROUP_CONCAT(pm.modalidade_id) as modalidades_ids,
           GROUP_CONCAT(m.nome) as modalidades_nomes
    FROM professor p
    LEFT JOIN professor_modalidade pm ON p.id = pm.professor_id
    LEFT JOIN modalidade m ON pm.modalidade_id = m.id
    GROUP BY p.id
  ''';

  final String _consultarPorId = '''
    SELECT p.id, p.nome, p.telefone,
           GROUP_CONCAT(pm.modalidade_id) as modalidades_ids,
           GROUP_CONCAT(m.nome) as modalidades_nomes
    FROM professor p
    LEFT JOIN professor_modalidade pm ON p.id = pm.professor_id
    LEFT JOIN modalidade m ON pm.modalidade_id = m.id
    WHERE p.id = ?
    GROUP BY p.id
  ''';

  Map<String, dynamic> toMap(ProfessorDTO professor) {
    return {
      'id': professor.id,
      'nome': professor.nome,
      'telefone': professor.telefone,
      'modalidades_ids': professor.ModalidadesIds,
      'modalidades_nomes': professor.ModalidadesNomes,
    };
  }

  ProfessorDTO fromMap(Map<String, dynamic> map) {
    final List<String> modalidadesIds = map['modalidades_ids'] != null
        ? (map['modalidades_ids'] as String).split(',').map((id) => id).toList()
        : [];
    final List<String>? modalidadesNomes = map['modalidades_nomes'] != null
        ? (map['modalidades_nomes'] as String).split(',')
        : null;
    return ProfessorDTO(
      id: map['id']?.toString(),
      nome: map['nome'],
      telefone: map['telefone'],
      ModalidadesIds: modalidadesIds,
      ModalidadesNomes: modalidadesNomes,
    );
  }

  Future<void> salvar(ProfessorDTO professor) async {
    final Database db = await ConexaoSQLite.database;
    try {
      await db.transaction((txn) async {
        if (professor.id == null) {
          // Insert
          final int id = await txn.rawInsert(
            _inserirProfessor,
            [professor.nome, professor.telefone],
          );
          professor.id = id.toString();

          // Insert modalities
          for (String modalidadeId in professor.ModalidadesIds) {
            await txn.rawInsert(
              _inserirProfessorModalidade,
              [id, int.parse(modalidadeId)],
            );
          }
        } else {
          // Update
          await txn.rawUpdate(
            _atualizarProfessor,
            [professor.nome, professor.telefone, int.parse(professor.id!)],
          );

          // Delete existing modalities
          await txn.rawDelete(
              _deletarProfessorModalidades, [int.parse(professor.id!)]);

          // Insert updated modalities
          for (String modalidadeId in professor.ModalidadesIds) {
            await txn.rawInsert(
              _inserirProfessorModalidade,
              [int.parse(professor.id!), int.parse(modalidadeId)],
            );
          }
        }
      });
    } catch (e) {
      throw Exception('Erro ao salvar professor: $e');
    }
  }

  Future<List<ProfessorDTO>> consultarTodos() async {
    final Database db = await ConexaoSQLite.database;
    try {
      final List<Map<String, dynamic>> maps =
          await db.rawQuery(_consultarTodos);
      return maps.map((map) => fromMap(map)).toList();
    } catch (e) {
      throw Exception('Erro ao consultar professores: $e');
    }
  }

  Future<ProfessorDTO?> consultarPorId(int id) async {
    final Database db = await ConexaoSQLite.database;
    try {
      final List<Map<String, dynamic>> maps =
          await db.rawQuery(_consultarPorId, [id]);
      if (maps.isEmpty) return null;
      return fromMap(maps.first);
    } catch (e) {
      throw Exception('Erro ao consultar professor por ID: $e');
    }
  }

  Future<void> excluir(int id) async {
    final Database db = await ConexaoSQLite.database;
    try {
      await db.transaction((txn) async {
        await txn.rawDelete(_deletarProfessorModalidades, [id]);
        await txn.rawDelete(_deletarProfessor, [id]);
      });
    } catch (e) {
      throw Exception('Erro ao excluir professor: $e');
    }
  }
}
