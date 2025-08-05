import 'package:sqflite/sqflite.dart';
import 'package:projeto_ddm_ifpr/banco/sqlite/conexao.dart';
import 'package:projeto_ddm_ifpr/dto/dto_dieta.dart';
import 'package:projeto_ddm_ifpr/dto/dto_receita.dart';

class DAODieta {
  final String _criarTabelaDieta = '''
    CREATE TABLE dieta (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nome TEXT NOT NULL,
      descricao TEXT,
      objetivo TEXT
    )
  ''';

  final String _inserirDieta = '''
    INSERT INTO dieta (nome, descricao, objetivo)
    VALUES (?, ?, ?)
  ''';

  final String _atualizarDieta = '''
    UPDATE dieta
    SET nome = ?, descricao = ?, objetivo = ?
    WHERE id = ?
  ''';

  final String _deletarDieta = '''
    DELETE FROM dieta
    WHERE id = ?
  ''';

  final String _consultarTodos = '''
    SELECT d.id, d.nome, d.descricao, d.objetivo,
           GROUP_CONCAT(r.id) as receitas_ids,
           GROUP_CONCAT(r.nome) as receitas_nomes
    FROM dieta d
    LEFT JOIN receita r ON d.id = r.dieta_id
    GROUP BY d.id
  ''';

  final String _consultarPorId = '''
    SELECT d.id, d.nome, d.descricao, d.objetivo,
           GROUP_CONCAT(r.id) as receitas_ids,
           GROUP_CONCAT(r.nome) as receitas_nomes
    FROM dieta d
    LEFT JOIN receita r ON d.id = r.dieta_id
    WHERE d.id = ?
    GROUP BY d.id
  ''';

  Map<String, dynamic> toMap(DietaDTO dieta) {
    return {
      'id': dieta.id != null ? int.tryParse(dieta.id!) : null,
      'nome': dieta.nome,
      'descricao': dieta.descricao,
      'objetivo': dieta.objetivo,
      'receitasIds': dieta.receitasIds,
      'receitasNomes': dieta.receitasNomes,
    };
  }

  DietaDTO fromMap(Map<String, dynamic> map) {
    final List<String> receitasIds = map['receitas_ids'] != null
        ? (map['receitas_ids'] as String).split(',')
        : [];
    final List<String>? receitasNomes = map['receitas_nomes'] != null
        ? (map['receitas_nomes'] as String).split(',')
        : null;

    return DietaDTO(
      id: map['id']?.toString(),
      nome: map['nome'],
      descricao: map['descricao'],
      objetivo: map['objetivo'],
      receitasIds: receitasIds,
      receitasNomes: receitasNomes,
    );
  }

  Future<void> salvar(DietaDTO dieta) async {
    final Database db = await ConexaoSQLite.database;
    try {
      await db.transaction((txn) async {
        if (dieta.id == null) {
          // Insert
          final int id = await txn.rawInsert(
            _inserirDieta,
            [dieta.nome, dieta.descricao, dieta.objetivo],
          );
          dieta.id = id.toString();
        } else {
          // Update
          await txn.rawUpdate(
            _atualizarDieta,
            [dieta.nome, dieta.descricao, dieta.objetivo, int.parse(dieta.id!)],
          );
        }
      });
    } catch (e) {
      throw Exception('Erro ao salvar dieta: $e');
    }
  }

  Future<List<DietaDTO>> consultarTodos() async {
    final Database db = await ConexaoSQLite.database;
    try {
      final List<Map<String, dynamic>> maps =
          await db.rawQuery(_consultarTodos);
      return maps.map((map) => fromMap(map)).toList();
    } catch (e) {
      throw Exception('Erro ao consultar dietas: $e');
    }
  }

  Future<DietaDTO?> consultarPorId(int id) async {
    final Database db = await ConexaoSQLite.database;
    try {
      final List<Map<String, dynamic>> maps =
          await db.rawQuery(_consultarPorId, [id]);
      if (maps.isEmpty) return null;
      return fromMap(maps.first);
    } catch (e) {
      throw Exception('Erro ao consultar dieta por ID: $e');
    }
  }

  Future<void> excluir(int id) async {
    final Database db = await ConexaoSQLite.database;
    try {
      await db.transaction((txn) async {
        // As receitas são mantidas, mas perdem a referência à dieta (dieta_id será NULL)
        await txn.rawUpdate(
          'UPDATE receita SET dieta_id = NULL WHERE dieta_id = ?',
          [id],
        );
        await txn.rawDelete(_deletarDieta, [id]);
      });
    } catch (e) {
      throw Exception('Erro ao excluir dieta: $e');
    }
  }
}
