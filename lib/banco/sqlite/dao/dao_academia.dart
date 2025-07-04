import 'package:projeto_ddm_ifpr/banco/sqlite/conexao.dart';
import 'package:projeto_ddm_ifpr/dto/dto_academia.dart';
import 'package:sqflite/sqflite.dart';

class DAOAcademia {
  final String _sqlSalvar = '''
    INSERT OR REPLACE INTO academia (id, nome, endereco, telefone_contato, cidade, ativo)
    VALUES (?, ?, ?, ?, ?, ?)
  ''';

  final String _sqlConsultarTodos = '''
    SELECT * FROM academia
  ''';

  final String _sqlConsultarPorId = '''
    SELECT * FROM academia WHERE id = ?
  ''';

  final String _sqlExcluir = '''
    DELETE FROM academia WHERE id = ?
  ''';

  Future<DTOAcademia> _fromMap(Map<String, dynamic> map) async {
    return DTOAcademia(
      id: map['id']?.toString(),
      nome: map['nome'] as String,
      endereco: map['endereco'] as String,
      telefone: map['telefone_contato'] as String,
      cidade: map['cidade'] as String,
    );
  }

  Map<String, dynamic> _toMap(DTOAcademia dto) {
    return {
      'id': dto.id != null ? int.tryParse(dto.id!) : null,
      'nome': dto.nome,
      'endereco': dto.endereco,
      'telefone_contato': dto.telefone,
      'cidade': dto.cidade,
      'ativo': 1, // Padrão ativo = 1, conforme tabela
    };
  }

  Future<void> salvar(DTOAcademia dto) async {
    final db = await ConexaoSQLite.database;
    try {
      await db.rawInsert(_sqlSalvar, [
        dto.id != null ? int.tryParse(dto.id!) : null,
        dto.nome,
        dto.endereco,
        dto.telefone,
        dto.cidade,
        1, // Padrão ativo = 1
      ]);
    } catch (e) {
      throw Exception('Erro ao salvar academia: $e');
    }
  }

  Future<List<DTOAcademia>> consultarTodos() async {
    final db = await ConexaoSQLite.database;
    try {
      final List<Map<String, dynamic>> maps =
          await db.rawQuery(_sqlConsultarTodos);
      return Future.wait(maps.map((map) => _fromMap(map)));
    } catch (e) {
      throw Exception('Erro ao consultar academias: $e');
    }
  }

  Future<DTOAcademia?> consultarPorId(int id) async {
    final db = await ConexaoSQLite.database;
    try {
      final List<Map<String, dynamic>> maps =
          await db.rawQuery(_sqlConsultarPorId, [id]);
      if (maps.isNotEmpty) {
        return await _fromMap(maps.first);
      }
      return null;
    } catch (e) {
      throw Exception('Erro ao consultar academia por ID: $e');
    }
  }

  Future<void> excluir(int id) async {
    final db = await ConexaoSQLite.database;
    try {
      await db.rawDelete(_sqlExcluir, [id]);
    } catch (e) {
      throw Exception('Erro ao excluir academia: $e');
    }
  }
}
