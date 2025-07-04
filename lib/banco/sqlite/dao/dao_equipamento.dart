import 'package:sqflite/sqflite.dart';
import 'package:projeto_ddm_ifpr/banco/sqlite/conexao.dart';
import 'package:projeto_ddm_ifpr/dto/dto_equipamento.dart';

class DAOEquipamento {
  final String _tabela = 'equipamento';
  final String _sqlInserir = '''
    INSERT INTO equipamento (nome) VALUES (?)
  ''';
  final String _sqlAlterar = '''
    UPDATE equipamento SET nome = ? WHERE id = ?
  ''';
  final String _sqlConsultarTodos = '''
    SELECT id, nome FROM equipamento
  ''';
  final String _sqlConsultarPorId = '''
    SELECT id, nome FROM equipamento WHERE id = ?
  ''';
  final String _sqlExcluir = '''
    DELETE FROM equipamento WHERE id = ?
  ''';

  Map<String, dynamic> toMap(DTOEquipamento equipamento) {
    return {
      'id': equipamento.id,
      'nome': equipamento.nome,
    };
  }

  DTOEquipamento fromMap(Map<String, dynamic> map) {
    return DTOEquipamento(
      id: map['id']?.toString(),
      nome: map['nome'] as String,
    );
  }

  Future<int> salvar(DTOEquipamento equipamento) async {
    final Database db = await ConexaoSQLite.database;
    if (equipamento.id == null) {
      // Inserir novo equipamento
      return await db.rawInsert(
        _sqlInserir,
        [equipamento.nome],
      );
    } else {
      // Alterar equipamento existente
      return await db.rawUpdate(
        _sqlAlterar,
        [equipamento.nome, equipamento.id],
      );
    }
  }

  Future<List<DTOEquipamento>> consultarTodos() async {
    final Database db = await ConexaoSQLite.database;
    final List<Map<String, dynamic>> maps =
        await db.rawQuery(_sqlConsultarTodos);
    return maps.map((map) => fromMap(map)).toList();
  }

  Future<DTOEquipamento?> consultarPorId(int id) async {
    final Database db = await ConexaoSQLite.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      _sqlConsultarPorId,
      [id],
    );
    if (maps.isEmpty) return null;
    return fromMap(maps.first);
  }

  Future<int> excluir(int id) async {
    final Database db = await ConexaoSQLite.database;
    return await db.rawDelete(_sqlExcluir, [id]);
  }
}
