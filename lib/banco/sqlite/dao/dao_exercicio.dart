import 'package:sqflite/sqflite.dart';
import 'package:projeto_ddm_ifpr/banco/sqlite/conexao.dart';
import 'package:projeto_ddm_ifpr/dto/dto_exercicio.dart';

class DAOExercicio {
  final String _sqlSalvar = '''
    INSERT OR REPLACE INTO exercicio (id, nome, equipamento)
    VALUES (?, ?, ?)
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

  DTOExercicio _fromMap(Map<String, dynamic> map) {
    return DTOExercicio(
      id: map['id']?.toString(),
      nome: map['nome'] as String,
      equipamento: map['equipamento'] as String,
    );
  }

  Map<String, dynamic> _toMap(DTOExercicio dto) {
    return {
      'id': dto.id != null ? int.tryParse(dto.id!) : null,
      'nome': dto.nome,
      'equipamento': dto.equipamento,
    };
  }

  Future<void> salvar(DTOExercicio dto) async {
    final db = await ConexaoSQLite.database;
    try {
      await db.rawInsert(_sqlSalvar, [
        dto.id != null ? int.tryParse(dto.id!) : null,
        dto.nome,
        dto.equipamento,
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
