import 'package:sqflite/sqflite.dart';
import 'package:projeto_ddm_ifpr/banco/sqlite/conexao.dart';
import 'package:projeto_ddm_ifpr/dto/dto_treino.dart';
import 'package:projeto_ddm_ifpr/dto/dto_exercicio.dart';
import 'package:projeto_ddm_ifpr/banco/sqlite/dao/dao_exercicio.dart';

class DAOTreino {
  final String _sqlSalvarTreino = '''
    INSERT OR REPLACE INTO treino (id, nome)
    VALUES (?, ?)
  ''';

  final String _sqlSalvarTreinoExercicio = '''
    INSERT OR REPLACE INTO treino_exercicio (treino_id, exercicio_id)
    VALUES (?, ?)
  ''';

  final String _sqlConsultarTodos = '''
    SELECT id, nome FROM treino
  ''';

  final String _sqlConsultarPorId = '''
    SELECT id, nome FROM treino WHERE id = ?
  ''';

  final String _sqlConsultarExerciciosPorTreino = '''
    SELECT e.id, e.nome
    FROM treino_exercicio te
    JOIN exercicio e ON te.exercicio_id = e.id
    WHERE te.treino_id = ?
  ''';

  final String _sqlExcluirTreino = '''
    DELETE FROM treino WHERE id = ?
  ''';

  final String _sqlExcluirTreinoExercicio = '''
    DELETE FROM treino_exercicio WHERE treino_id = ?
  ''';

  Map<String, dynamic> toMap(DTOTreino dto) {
    return {
      'id': dto.id != null ? int.tryParse(dto.id!) : null,
      'nome': dto.nome,
      'exerciciosIds': dto.exerciciosIds,
      'exerciciosNomes': dto.exerciciosNomes,
    };
  }

  DTOTreino fromMap(Map<String, dynamic> map, List<String> exerciciosIds,
      List<String> exerciciosNomes) {
    return DTOTreino(
      id: map['id']?.toString(),
      nome: map['nome'] as String,
      exerciciosIds: exerciciosIds,
      exerciciosNomes: exerciciosNomes,
    );
  }

  Future<void> salvar(DTOTreino dto) async {
    final db = await ConexaoSQLite.database;
    await db.transaction((txn) async {
      try {
        final treinoId = await txn.rawInsert(
          _sqlSalvarTreino,
          [dto.id != null ? int.tryParse(dto.id!) : null, dto.nome],
        );

        await txn.rawDelete(_sqlExcluirTreinoExercicio, [treinoId]);

        for (var exercicioId in dto.exerciciosIds) {
          await txn.rawInsert(
            _sqlSalvarTreinoExercicio,
            [treinoId, int.tryParse(exercicioId)],
          );
        }
      } catch (e) {
        throw Exception('Erro ao salvar treino: $e');
      }
    });
  }

  Future<List<DTOExercicio>> consultarExerciciosPorTreino(int treinoId) async {
    final db = await ConexaoSQLite.database;
    try {
      final List<Map<String, dynamic>> maps =
          await db.rawQuery(_sqlConsultarExerciciosPorTreino, [treinoId]);
      final exercicios = <DTOExercicio>[];
      for (var map in maps) {
        final equipamentos =
            await DAOExercicio().consultarEquipamentosPorExercicio(map['id']);
        exercicios.add(DAOExercicio().fromMap(
          map,
          equipamentos.map((e) => e.id!).toList(),
          equipamentos.map((e) => e.nome).toList(),
        ));
      }
      return exercicios;
    } catch (e) {
      throw Exception('Erro ao consultar exercícios do treino: $e');
    }
  }

  Future<List<DTOTreino>> consultarTodos() async {
    final db = await ConexaoSQLite.database;
    try {
      final List<Map<String, dynamic>> maps =
          await db.rawQuery(_sqlConsultarTodos);
      final treinos = <DTOTreino>[];
      for (var map in maps) {
        final exercicios = await consultarExerciciosPorTreino(map['id']);
        treinos.add(fromMap(
          map,
          exercicios.map((e) => e.id!).toList(),
          exercicios.map((e) => e.nome).toList(),
        ));
      }
      return treinos;
    } catch (e) {
      throw Exception('Erro ao consultar treinos: $e');
    }
  }

  Future<DTOTreino?> consultarPorId(int id) async {
    final db = await ConexaoSQLite.database;
    try {
      final List<Map<String, dynamic>> maps =
          await db.rawQuery(_sqlConsultarPorId, [id]);
      if (maps.isNotEmpty) {
        final exercicios = await consultarExerciciosPorTreino(id);
        return fromMap(
          maps.first,
          exercicios.map((e) => e.id!).toList(),
          exercicios.map((e) => e.nome).toList(),
        );
      }
      return null;
    } catch (e) {
      throw Exception('Erro ao consultar treino por ID: $e');
    }
  }

  Future<void> excluir(int id) async {
    final db = await ConexaoSQLite.database;
    await db.transaction((txn) async {
      try {
        await txn.rawDelete(_sqlExcluirTreinoExercicio, [id]);
        await txn.rawDelete(_sqlExcluirTreino, [id]);
      } catch (e) {
        throw Exception('Erro ao excluir treino: $e');
      }
    });
  }
}
