import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:projeto_ddm_ifpr/banco/sqlite/conexao.dart';
import 'package:projeto_ddm_ifpr/dto/dto_receita.dart';
import 'dart:convert';

class DAOReceitas {
  final String _inserirReceita = '''
    INSERT INTO receita (nome, ingredientes, modo_preparo, valor_nutricional, dieta_id)
    VALUES (?, ?, ?, ?, ?)
  ''';

  final String _atualizarReceita = '''
    UPDATE receita
    SET nome = ?, ingredientes = ?, modo_preparo = ?, valor_nutricional = ?, dieta_id = ?
    WHERE id = ?
  ''';

  final String _deletarReceita = '''
    DELETE FROM receita
    WHERE id = ?
  ''';

  final String _deletarReceitaDietas = '''
    DELETE FROM receita_dieta
    WHERE receita_id = ?
  ''';

  final String _inserirReceitaDieta = '''
    INSERT INTO receita_dieta (receita_id, dieta_id)
    VALUES (?, ?)
  ''';

  final String _consultarTodos = '''
    SELECT r.id, r.nome, r.ingredientes, r.modo_preparo, r.valor_nutricional, r.dieta_id,
           GROUP_CONCAT(rd.dieta_id) as dietas_ids,
           GROUP_CONCAT(COALESCE(d.nome, '')) as dietas_nomes
    FROM receita r
    LEFT JOIN receita_dieta rd ON r.id = rd.receita_id
    LEFT JOIN dieta d ON rd.dieta_id = d.id
    GROUP BY r.id
  ''';

  final String _consultarPorId = '''
    SELECT r.id, r.nome, r.ingredientes, r.modo_preparo, r.valor_nutricional, r.dieta_id,
           GROUP_CONCAT(rd.dieta_id) as dietas_ids,
           GROUP_CONCAT(COALESCE(d.nome, '')) as dietas_nomes
    FROM receita r
    LEFT JOIN receita_dieta rd ON r.id = rd.receita_id
    LEFT JOIN dieta d ON rd.dieta_id = d.id
    WHERE r.id = ?
    GROUP BY r.id
  ''';

  Map<String, dynamic> toMap(ReceitaDTO receita) {
    return {
      'id': receita.id,
      'nome': receita.nome,
      'ingredientes': jsonEncode(receita.ingredientes),
      'modo_preparo': receita.modoPreparo,
      'valor_nutricional': receita.valorNutricional != null
          ? jsonEncode(receita.valorNutricional)
          : null,
      'dieta_id': receita.dietaId,
      'dietas_nomes': receita.dietasNomes?.join(','),
    };
  }

  ReceitaDTO fromMap(Map<String, dynamic> map) {
    try {
      final List<String>? dietasIds = map['dietas_ids'] != null
          ? (map['dietas_ids'] as String).split(',')
          : null;
      final List<String>? dietasNomes = map['dietas_nomes'] != null
          ? (map['dietas_nomes'] as String).split(',')
          : null;

      return ReceitaDTO(
        id: map['id']?.toString(),
        nome: map['nome'] as String? ?? 'Nome desconhecido',
        ingredientes: map['ingredientes'] != null
            ? List<String>.from(jsonDecode(map['ingredientes'] as String))
            : [],
        modoPreparo: map['modo_preparo'] as String?,
        valorNutricional: map['valor_nutricional'] != null
            ? Map<String, double>.from(
                jsonDecode(map['valor_nutricional'] as String).map(
                  (key, value) =>
                      MapEntry(key, value is int ? value.toDouble() : value),
                ),
              )
            : null,
        dietaId: map['dieta_id']?.toString(),
        dietasNomes: dietasNomes,
      );
    } catch (e) {
      debugPrint('Erro ao parsear mapa para ReceitaDTO: $e');
      throw Exception('Erro ao parsear receita: $e');
    }
  }

  Future<ReceitaDTO> salvar(ReceitaDTO receita) async {
    final Database db = await ConexaoSQLite.database;
    try {
      await db.transaction((txn) async {
        if (receita.id == null) {
          // Inserção
          final int id = await txn.rawInsert(
            _inserirReceita,
            [
              receita.nome,
              jsonEncode(receita.ingredientes),
              receita.modoPreparo,
              receita.valorNutricional != null
                  ? jsonEncode(receita.valorNutricional)
                  : null,
              receita.dietaId != null ? int.tryParse(receita.dietaId!) : null,
            ],
          );
          receita.id = id.toString();

          // Inserir associações com dietas
          if (receita.dietasNomes != null) {
            for (String dietaId in receita.dietasNomes!) {
              final parsedDietaId = int.tryParse(dietaId);
              if (parsedDietaId != null) {
                await txn.rawInsert(
                  _inserirReceitaDieta,
                  [id, parsedDietaId],
                );
              } else {
                debugPrint('ID de dieta inválido ignorado: $dietaId');
              }
            }
          }
        } else {
          // Atualização
          await txn.rawUpdate(
            _atualizarReceita,
            [
              receita.nome,
              jsonEncode(receita.ingredientes),
              receita.modoPreparo,
              receita.valorNutricional != null
                  ? jsonEncode(receita.valorNutricional)
                  : null,
              receita.dietaId != null ? int.tryParse(receita.dietaId!) : null,
              int.parse(receita.id!),
            ],
          );

          // Deletar associações existentes
          await txn.rawDelete(_deletarReceitaDietas, [int.parse(receita.id!)]);

          // Inserir novas associações
          if (receita.dietasNomes != null) {
            for (String dietaId in receita.dietasNomes!) {
              final parsedDietaId = int.tryParse(dietaId);
              if (parsedDietaId != null) {
                await txn.rawInsert(
                  _inserirReceitaDieta,
                  [int.parse(receita.id!), parsedDietaId],
                );
              } else {
                debugPrint('ID de dieta inválido ignorado: $dietaId');
              }
            }
          }
        }
      });
      return receita;
    } catch (e) {
      debugPrint('Erro ao salvar receita: $e');
      throw Exception('Erro ao salvar receita: $e');
    }
  }

  Future<List<ReceitaDTO>> consultarTodos() async {
    final Database db = await ConexaoSQLite.database;
    try {
      final List<Map<String, dynamic>> maps =
          await db.rawQuery(_consultarTodos);
      debugPrint('Receitas carregadas: ${maps.length}');
      return maps.map((map) => fromMap(map)).toList();
    } catch (e) {
      debugPrint('Erro ao consultar receitas: $e');
      throw Exception('Erro ao consultar receitas: $e');
    }
  }

  Future<ReceitaDTO?> consultarPorId(int id) async {
    final Database db = await ConexaoSQLite.database;
    try {
      final List<Map<String, dynamic>> maps =
          await db.rawQuery(_consultarPorId, [id]);
      if (maps.isEmpty) return null;
      return fromMap(maps.first);
    } catch (e) {
      debugPrint('Erro ao consultar receita por ID: $e');
      throw Exception('Erro ao consultar receita por ID: $e');
    }
  }

  Future<void> excluir(int id) async {
    final Database db = await ConexaoSQLite.database;
    try {
      await db.transaction((txn) async {
        await txn.rawDelete(_deletarReceitaDietas, [id]);
        await txn.rawDelete(_deletarReceita, [id]);
      });
    } catch (e) {
      debugPrint('Erro ao excluir receita: $e');
      throw Exception('Erro ao excluir receita: $e');
    }
  }
}
