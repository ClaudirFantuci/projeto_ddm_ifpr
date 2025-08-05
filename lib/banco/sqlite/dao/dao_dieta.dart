import 'package:flutter/foundation.dart';
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

  final String _deletarReceitaDietas = '''
    DELETE FROM receita_dieta
    WHERE dieta_id = ?
  ''';

  final String _inserirReceitaDieta = '''
    INSERT INTO receita_dieta (receita_id, dieta_id)
    VALUES (?, ?)
  ''';

  final String _consultarTodos = '''
    SELECT d.id, d.nome, d.descricao, d.objetivo,
           GROUP_CONCAT(rd.receita_id) as receitas_ids,
           GROUP_CONCAT(COALESCE(r.nome, '')) as receitas_nomes
    FROM dieta d
    LEFT JOIN receita_dieta rd ON d.id = rd.dieta_id
    LEFT JOIN receita r ON rd.receita_id = r.id
    GROUP BY d.id
  ''';

  final String _consultarPorId = '''
    SELECT d.id, d.nome, d.descricao, d.objetivo,
           GROUP_CONCAT(rd.receita_id) as receitas_ids,
           GROUP_CONCAT(COALESCE(r.nome, '')) as receitas_nomes
    FROM dieta d
    LEFT JOIN receita_dieta rd ON d.id = rd.dieta_id
    LEFT JOIN receita r ON rd.receita_id = r.id
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
    try {
      final List<String> receitasIds = map['receitas_ids'] != null
          ? (map['receitas_ids'] as String).split(',')
          : [];
      final List<String>? receitasNomes = map['receitas_nomes'] != null
          ? (map['receitas_nomes'] as String).split(',')
          : null;

      return DietaDTO(
        id: map['id']?.toString(),
        nome: map['nome'] as String? ?? 'Nome desconhecido',
        descricao: map['descricao'],
        objetivo: map['objetivo'],
        receitasIds: receitasIds,
        receitasNomes: receitasNomes,
      );
    } catch (e) {
      debugPrint('Erro ao parsear mapa para DietaDTO: $e');
      throw Exception('Erro ao parsear dieta: $e');
    }
  }

  Future<void> salvar(DietaDTO dieta) async {
    final Database db = await ConexaoSQLite.database;
    try {
      await db.transaction((txn) async {
        int id;
        if (dieta.id == null) {
          // Inserção
          id = await txn.rawInsert(
            _inserirDieta,
            [dieta.nome, dieta.descricao, dieta.objetivo],
          );
          dieta.id = id.toString();
        } else {
          // Atualização
          id = int.parse(dieta.id!);
          await txn.rawUpdate(
            _atualizarDieta,
            [dieta.nome, dieta.descricao, dieta.objetivo, id],
          );
          // Deletar associações existentes
          await txn.rawDelete(_deletarReceitaDietas, [id]);
        }

        // Inserir associações com receitas
        if (dieta.receitasIds.isNotEmpty) {
          for (String receitaId in dieta.receitasIds) {
            final parsedReceitaId = int.tryParse(receitaId);
            if (parsedReceitaId != null) {
              await txn.rawInsert(
                _inserirReceitaDieta,
                [parsedReceitaId, id],
              );
            } else {
              debugPrint('ID de receita inválido ignorado: $receitaId');
            }
          }
        }
      });
    } catch (e) {
      debugPrint('Erro ao salvar dieta: $e');
      throw Exception('Erro ao salvar dieta: $e');
    }
  }

  Future<List<DietaDTO>> consultarTodos() async {
    final Database db = await ConexaoSQLite.database;
    try {
      final List<Map<String, dynamic>> maps =
          await db.rawQuery(_consultarTodos);
      debugPrint('Dietas carregadas: ${maps.length}');
      return maps.map((map) => fromMap(map)).toList();
    } catch (e) {
      debugPrint('Erro ao consultar dietas: $e');
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
      debugPrint('Erro ao consultar dieta por ID: $e');
      throw Exception('Erro ao consultar dieta por ID: $e');
    }
  }

  Future<void> excluir(int id) async {
    final Database db = await ConexaoSQLite.database;
    try {
      await db.transaction((txn) async {
        await txn.rawDelete(_deletarReceitaDietas, [id]);
        await txn.rawDelete(_deletarDieta, [id]);
      });
    } catch (e) {
      debugPrint('Erro ao excluir dieta: $e');
      throw Exception('Erro ao excluir dieta: $e');
    }
  }
}
