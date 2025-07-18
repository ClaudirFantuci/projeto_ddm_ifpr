import 'package:sqflite/sqflite.dart';
import 'package:projeto_ddm_ifpr/banco/sqlite/conexao.dart';
import 'package:projeto_ddm_ifpr/dto/dto_objetivo.dart';

class DAOObjetivo {
  final String _sqlSalvar = '''
    INSERT OR REPLACE INTO objetivo (id, nome)
    VALUES (?, ?)
  ''';

  final String _sqlConsultarTodos = '''
    SELECT * FROM objetivo
  ''';

  final String _sqlConsultarPorId = '''
    SELECT * FROM objetivo WHERE id = ?
  ''';

  final String _sqlExcluir = '''
    DELETE FROM objetivo WHERE id = ?
  ''';

  Future<DTOObjetivo> _fromMap(Map<String, dynamic> map) async {
    return DTOObjetivo(
      id: map['id']?.toString(),
      nome: map['nome'] as String,
    );
  }

  Map<String, dynamic> _toMap(DTOObjetivo dto) {
    return {
      'id': dto.id != null ? int.tryParse(dto.id!) : null,
      'nome': dto.nome,
    };
  }

  Future<void> salvar(DTOObjetivo dto) async {
    final db = await ConexaoSQLite.database;
    try {
      await db.rawInsert(_sqlSalvar, [
        dto.id != null ? int.tryParse(dto.id!) : null,
        dto.nome,
      ]);
    } catch (e) {
      throw Exception('Erro ao salvar objetivo: $e');
    }
  }

  Future<List<DTOObjetivo>> consultarTodos() async {
    final db = await ConexaoSQLite.database;
    try {
      final List<Map<String, dynamic>> maps =
          await db.rawQuery(_sqlConsultarTodos);
      return Future.wait(maps.map((map) => _fromMap(map)).toList());
    } catch (e) {
      throw Exception('Erro ao consultar objetivos: $e');
    }
  }

  Future<DTOObjetivo?> consultarPorId(int id) async {
    final db = await ConexaoSQLite.database;
    try {
      final List<Map<String, dynamic>> maps =
          await db.rawQuery(_sqlConsultarPorId, [id]);
      if (maps.isNotEmpty) {
        return await _fromMap(maps.first);
      }
      return null;
    } catch (e) {
      throw Exception('Erro ao consultar objetivo por ID: $e');
    }
  }

  Future<void> excluir(int id) async {
    final db = await ConexaoSQLite.database;
    try {
      await db.rawDelete(_sqlExcluir, [id]);
    } catch (e) {
      throw Exception('Erro ao excluir objetivo: $e');
    }
  }
}
