import 'package:sqflite/sqflite.dart';
import 'package:projeto_ddm_ifpr/banco/sqlite/conexao.dart';
import 'package:projeto_ddm_ifpr/dto/dto_exercicio.dart';
import 'package:projeto_ddm_ifpr/banco/sqlite/dao/dao_equipamento.dart';
import 'package:projeto_ddm_ifpr/dto/dto_equipamento.dart';

class DAOExercicio {
  final String _sqlSalvarExercicio = '''
    INSERT OR REPLACE INTO exercicio (id, nome)
    VALUES (?, ?)
  ''';

  final String _sqlSalvarExercicioEquipamento = '''
    INSERT OR REPLACE INTO exercicio_equipamento (exercicio_id, equipamento_id)
    VALUES (?, ?)
  ''';

  final String _sqlConsultarTodos = '''
    SELECT id, nome FROM exercicio
  ''';

  final String _sqlConsultarPorId = '''
    SELECT id, nome FROM exercicio WHERE id = ?
  ''';

  final String _sqlConsultarEquipamentosPorExercicio = '''
    SELECT eq.id, eq.nome
    FROM exercicio_equipamento ee
    JOIN equipamento eq ON ee.equipamento_id = eq.id
    WHERE ee.exercicio_id = ?
  ''';

  final String _sqlExcluirExercicio = '''
    DELETE FROM exercicio WHERE id = ?
  ''';

  final String _sqlExcluirExercicioEquipamento = '''
    DELETE FROM exercicio_equipamento WHERE exercicio_id = ?
  ''';

  Map<String, dynamic> toMap(DTOExercicio dto) {
    return {
      'id': dto.id != null ? int.tryParse(dto.id!) : null,
      'nome': dto.nome,
      'equipamentosIds': dto.equipamentosIds,
      'equipamentosNomes': dto.equipamentosNomes,
    };
  }

  DTOExercicio fromMap(Map<String, dynamic> map, List<String> equipamentosIds,
      List<String> equipamentosNomes) {
    return DTOExercicio(
      id: map['id']?.toString(),
      nome: map['nome'] as String,
      equipamentosIds: equipamentosIds,
      equipamentosNomes: equipamentosNomes,
    );
  }

  Future<void> salvar(DTOExercicio dto) async {
    final db = await ConexaoSQLite.database;
    await db.transaction((txn) async {
      try {
        final exercicioId = await txn.rawInsert(
          _sqlSalvarExercicio,
          [dto.id != null ? int.tryParse(dto.id!) : null, dto.nome],
        );

        await txn.rawDelete(_sqlExcluirExercicioEquipamento, [exercicioId]);

        for (var equipamentoId in dto.equipamentosIds) {
          await txn.rawInsert(
            _sqlSalvarExercicioEquipamento,
            [exercicioId, int.tryParse(equipamentoId)],
          );
        }
      } catch (e) {
        throw Exception('Erro ao salvar exercício: $e');
      }
    });
  }

  Future<List<DTOExercicio>> consultarTodosComNomeEquipamento() async {
    final db = await ConexaoSQLite.database;
    try {
      final List<Map<String, dynamic>> maps =
          await db.rawQuery(_sqlConsultarTodos);
      final exercicios = <DTOExercicio>[];
      for (var map in maps) {
        final equipamentos = await consultarEquipamentosPorExercicio(map['id']);
        exercicios.add(fromMap(
          map,
          equipamentos.map((e) => e.id!).toList(),
          equipamentos.map((e) => e.nome).toList(),
        ));
      }
      return exercicios;
    } catch (e) {
      throw Exception('Erro ao consultar exercícios: $e');
    }
  }

  Future<List<DTOEquipamento>> consultarEquipamentosPorExercicio(
      int exercicioId) async {
    final db = await ConexaoSQLite.database;
    try {
      final List<Map<String, dynamic>> maps = await db
          .rawQuery(_sqlConsultarEquipamentosPorExercicio, [exercicioId]);
      return maps.map((map) => DAOEquipamento().fromMap(map)).toList();
    } catch (e) {
      throw Exception('Erro ao consultar equipamentos do exercício: $e');
    }
  }

  Future<DTOExercicio?> consultarPorId(int id) async {
    final db = await ConexaoSQLite.database;
    try {
      final List<Map<String, dynamic>> maps =
          await db.rawQuery(_sqlConsultarPorId, [id]);
      if (maps.isNotEmpty) {
        final equipamentos = await consultarEquipamentosPorExercicio(id);
        return fromMap(
          maps.first,
          equipamentos.map((e) => e.id!).toList(),
          equipamentos.map((e) => e.nome).toList(),
        );
      }
      return null;
    } catch (e) {
      throw Exception('Erro ao consultar exercício por ID: $e');
    }
  }

  Future<void> excluir(int id) async {
    final db = await ConexaoSQLite.database;
    await db.transaction((txn) async {
      try {
        await txn.rawDelete(_sqlExcluirExercicioEquipamento, [id]);
        await txn.rawDelete(_sqlExcluirExercicio, [id]);
      } catch (e) {
        throw Exception('Erro ao excluir exercício: $e');
      }
    });
  }
}
