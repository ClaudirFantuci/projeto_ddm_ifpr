import 'package:sqflite/sqflite.dart';
import 'package:projeto_ddm_ifpr/banco/sqlite/conexao.dart';
import 'package:projeto_ddm_ifpr/dto/dto_modalidade.dart';

class DAOModalidade {
  final String _sqlSalvarModalidade = '''
    INSERT OR REPLACE INTO modalidade (id, nome)
    VALUES (?, ?)
  ''';

  final String _sqlConsultarTodos = '''
    SELECT id, nome FROM modalidade
  ''';

  final String _sqlConsultarPorId = '''
    SELECT id, nome FROM modalidade WHERE id = ?
  ''';

  final String _sqlExcluirModalidade = '''
    DELETE FROM modalidade WHERE id = ?
  ''';

  Map<String, dynamic> toMap(DtoModalidade dto) {
    return {
      'id': dto.id,
      'nome': dto.nome,
    };
  }

  DtoModalidade fromMap(Map<String, dynamic> map) {
    return DtoModalidade(
      id: map['id'] as String?,
      nome: map['nome'] as String,
    );
  }

  Future<void> salvar(DtoModalidade dto) async {
    final db = await ConexaoSQLite.database;
    try {
      await db.rawInsert(
        _sqlSalvarModalidade,
        [dto.id, dto.nome],
      );
    } catch (e) {
      throw Exception('Erro ao salvar modalidade: $e');
    }
  }

  Future<List<DtoModalidade>> consultarTodos() async {
    final db = await ConexaoSQLite.database;
    try {
      final List<Map<String, dynamic>> maps =
          await db.rawQuery(_sqlConsultarTodos);
      return maps.map((map) => fromMap(map)).toList();
    } catch (e) {
      throw Exception('Erro ao consultar modalidades: $e');
    }
  }

  Future<DtoModalidade?> consultarPorId(String id) async {
    final db = await ConexaoSQLite.database;
    try {
      final List<Map<String, dynamic>> maps =
          await db.rawQuery(_sqlConsultarPorId, [id]);
      if (maps.isNotEmpty) {
        return fromMap(maps.first);
      }
      return null;
    } catch (e) {
      throw Exception('Erro ao consultar modalidade por ID: $e');
    }
  }

  Future<void> excluir(String id) async {
    final db = await ConexaoSQLite.database;
    try {
      await db.rawDelete(_sqlExcluirModalidade, [id]);
    } catch (e) {
      throw Exception('Erro ao excluir modalidade: $e');
    }
  }
}
