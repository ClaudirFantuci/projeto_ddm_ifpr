import 'package:sqflite/sqflite.dart';
import 'package:projeto_ddm_ifpr/banco/sqlite/conexao.dart';
import 'package:projeto_ddm_ifpr/dto/dto_exercicio.dart';

class DAOExercicio {
  final String _sqlSalvar = '''
    INSERT OR REPLACE INTO exercicio (id, nome, equipamento_id, equipamento_secundario_id)
    VALUES (?, ?, ?, ?)
  ''';

  final String _sqlConsultarTodos = '''
    SELECT * FROM exercicio
  ''';

  final String _sqlConsultarPorId = '''
    SELECT * FROM exercicio WHERE id = ?
  ''';

  final String _sqlExcluir = '''
    DELETE FROM exercicio WHERE id = ?
  ''';

  final String _sqlConsultarTodosComNome = '''
    SELECT e.id, e.nome, e.equipamento_id, eq1.nome as equipamento_nome,
           e.equipamento_secundario_id, eq2.nome as equipamento_secundario_nome
    FROM exercicio e
    JOIN equipamento eq1 ON e.equipamento_id = eq1.id
    LEFT JOIN equipamento eq2 ON e.equipamento_secundario_id = eq2.id
  ''';

  DTOExercicio _fromMap(Map<String, dynamic> map) {
    return DTOExercicio(
      id: map['id']?.toString(),
      nome: map['nome'] as String,
      equipamentoId: map['equipamento_id'].toString(),
      equipamentoSecundarioId: map['equipamento_secundario_id']?.toString(),
    );
  }

  DTOExercicio _fromMapComNome(Map<String, dynamic> map) {
    return DTOExercicio(
      id: map['id']?.toString(),
      nome: map['nome'] as String,
      equipamentoId: map['equipamento_id'].toString(),
      equipamentoNome: map['equipamento_nome'] as String?,
      equipamentoSecundarioId: map['equipamento_secundario_id']?.toString(),
      equipamentoSecundarioNome: map['equipamento_secundario_nome'] as String?,
    );
  }

  Map<String, dynamic> _toMap(DTOExercicio dto) {
    return {
      'id': dto.id != null ? int.tryParse(dto.id!) : null,
      'nome': dto.nome,
      'equipamento_id': int.tryParse(dto.equipamentoId),
      'equipamento_secundario_id': dto.equipamentoSecundarioId != null
          ? int.tryParse(dto.equipamentoSecundarioId!)
          : null,
    };
  }

  Future<void> salvar(DTOExercicio dto) async {
    final db = await ConexaoSQLite.database;
    try {
      await db.rawInsert(_sqlSalvar, [
        dto.id != null ? int.tryParse(dto.id!) : null,
        dto.nome,
        int.tryParse(dto.equipamentoId),
        dto.equipamentoSecundarioId != null
            ? int.tryParse(dto.equipamentoSecundarioId!)
            : null,
      ]);
    } catch (e) {
      throw Exception('Erro ao salvar exercício: $e');
    }
  }

  Future<List<DTOExercicio>> consultarTodos() async {
    final db = await ConexaoSQLite.database;
    try {
      final List<Map<String, dynamic>> maps =
          await db.rawQuery(_sqlConsultarTodos);
      return maps.map((map) => _fromMap(map)).toList();
    } catch (e) {
      throw Exception('Erro ao consultar exercícios: $e');
    }
  }

  Future<List<DTOExercicio>> consultarTodosComNomeEquipamento() async {
    final db = await ConexaoSQLite.database;
    try {
      final List<Map<String, dynamic>> maps =
          await db.rawQuery(_sqlConsultarTodosComNome);
      return maps.map((map) => _fromMapComNome(map)).toList();
    } catch (e) {
      throw Exception(
          'Erro ao consultar exercícios com nome do equipamento: $e');
    }
  }

  Future<DTOExercicio?> consultarPorId(int id) async {
    final db = await ConexaoSQLite.database;
    try {
      final List<Map<String, dynamic>> maps =
          await db.rawQuery(_sqlConsultarPorId, [id]);
      if (maps.isNotEmpty) {
        return _fromMap(maps.first);
      }
      return null;
    } catch (e) {
      throw Exception('Erro ao consultar exercício por ID: $e');
    }
  }

  Future<void> excluir(int id) async {
    final db = await ConexaoSQLite.database;
    try {
      await db.rawDelete(_sqlExcluir, [id]);
    } catch (e) {
      throw Exception('Erro ao excluir exercício: $e');
    }
  }
}
