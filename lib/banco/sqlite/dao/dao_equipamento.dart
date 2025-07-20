import 'package:sqflite/sqflite.dart';
import 'package:projeto_ddm_ifpr/banco/sqlite/conexao.dart';
import 'package:projeto_ddm_ifpr/dto/dto_equipamento.dart';

class DAOEquipamento {
  final String _sqlSalvarEquipamento = '''
    INSERT OR REPLACE INTO equipamento (id, nome)
    VALUES (?, ?)
  ''';

  final String _sqlConsultarTodos = '''
    SELECT id, nome FROM equipamento
  ''';

  final String _sqlConsultarPorId = '''
    SELECT id, nome FROM equipamento WHERE id = ?
  ''';

  final String _sqlExcluirEquipamento = '''
    DELETE FROM equipamento WHERE id = ?
  ''';

  Map<String, dynamic> toMap(DTOEquipamento dto) {
    return {
      'id': dto.id != null ? int.tryParse(dto.id!) : null,
      'nome': dto.nome,
    };
  }

  DTOEquipamento fromMap(Map<String, dynamic> map) {
    return DTOEquipamento(
      id: map['id']?.toString(),
      nome: map['nome'] as String,
    );
  }

  Future<void> salvar(DTOEquipamento dto) async {
    final db = await ConexaoSQLite.database;
    try {
      await db.rawInsert(
        _sqlSalvarEquipamento,
        [dto.id != null ? int.tryParse(dto.id!) : null, dto.nome],
      );
    } catch (e) {
      throw Exception('Erro ao salvar equipamento: $e');
    }
  }

  Future<List<DTOEquipamento>> consultarTodos() async {
    final db = await ConexaoSQLite.database;
    try {
      final List<Map<String, dynamic>> maps =
          await db.rawQuery(_sqlConsultarTodos);
      return maps.map((map) => fromMap(map)).toList();
    } catch (e) {
      throw Exception('Erro ao consultar equipamentos: $e');
    }
  }

  Future<DTOEquipamento?> consultarPorId(int id) async {
    final db = await ConexaoSQLite.database;
    try {
      final List<Map<String, dynamic>> maps =
          await db.rawQuery(_sqlConsultarPorId, [id]);
      if (maps.isNotEmpty) {
        return fromMap(maps.first);
      }
      return null;
    } catch (e) {
      throw Exception('Erro ao consultar equipamento por ID: $e');
    }
  }

  Future<void> excluir(int id) async {
    final db = await ConexaoSQLite.database;
    try {
      await db.rawDelete(_sqlExcluirEquipamento, [id]);
    } catch (e) {
      throw Exception('Erro ao excluir equipamento: $e');
    }
  }
}
