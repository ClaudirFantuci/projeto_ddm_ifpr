import 'package:projeto_ddm_ifpr/banco/sqlite/conexao.dart';
import 'package:projeto_ddm_ifpr/dto/dto_receita.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:convert';

class DAOReceita {
  Future<Database> _getDatabase() async {
    return await ConexaoSQLite.get();
  }

  Future<ReceitaDTO> salvar(ReceitaDTO receita) async {
    final db = await _getDatabase();
    try {
      await db.transaction((txn) async {
        final receitaMap = {
          'nome': receita.nome,
          'ingredientes': jsonEncode(receita.ingredientes),
          'modo_preparo': receita.modoPreparo,
          'valor_nutricional': receita.valorNutricional != null
              ? jsonEncode(receita.valorNutricional)
              : null,
          'dieta_id':
              receita.dietaId != null ? int.parse(receita.dietaId!) : null,
        };

        if (receita.id == null) {
          // Inserção
          final id = await txn.insert('receita', receitaMap);
          receita.id = id.toString();
        } else {
          // Atualização
          await txn.update(
            'receita',
            receitaMap,
            where: 'id = ?',
            whereArgs: [int.parse(receita.id!)],
          );
        }
      });
      return receita;
    } catch (e) {
      throw Exception('Erro ao salvar receita: $e');
    }
  }

  Future<void> excluir(int id) async {
    final db = await _getDatabase();
    try {
      await db.transaction((txn) async {
        await txn.delete(
          'receita',
          where: 'id = ?',
          whereArgs: [id],
        );
      });
    } catch (e) {
      throw Exception('Erro ao excluir receita: $e');
    }
  }

  Future<List<ReceitaDTO>> consultarTodos() async {
    final db = await _getDatabase();
    try {
      final resultado = await db.query('receita');
      return resultado.map((map) {
        return ReceitaDTO(
          id: map['id'].toString(),
          nome: map['nome'] as String,
          ingredientes:
              List<String>.from(jsonDecode(map['ingredientes'] as String)),
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
        );
      }).toList();
    } catch (e) {
      throw Exception('Erro ao consultar receitas: $e');
    }
  }
}
