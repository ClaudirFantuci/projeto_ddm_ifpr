import 'package:sqflite/sqflite.dart';
import 'package:projeto_ddm_ifpr/banco/sqlite/conexao.dart';
import 'package:projeto_ddm_ifpr/dto/dto_aluno.dart';
import 'package:projeto_ddm_ifpr/dto/dto_objetivo.dart';

class DAOAluno {
  final String _sqlSalvarAluno = '''
    INSERT OR REPLACE INTO aluno (id, nome, telefone, objetivo_principal_id)
    VALUES (?, ?, ?, ?)
  ''';

  final String _sqlSalvarAlunoObjetivo = '''
    INSERT OR REPLACE INTO aluno_objetivo (aluno_id, objetivo_id)
    VALUES (?, ?)
  ''';

  final String _sqlConsultarTodos = '''
    SELECT id, nome, telefone, objetivo_principal_id
    FROM aluno
  ''';

  final String _sqlConsultarPorId = '''
    SELECT id, nome, telefone, objetivo_principal_id
    FROM aluno
    WHERE id = ?
  ''';

  final String _sqlConsultarObjetivosPorAluno = '''
    SELECT o.id, o.nome
    FROM aluno_objetivo ao
    JOIN objetivo o ON ao.objetivo_id = o.id
    WHERE ao.aluno_id = ?
  ''';

  final String _sqlConsultarObjetivoPrincipal = '''
    SELECT nome
    FROM objetivo
    WHERE id = ?
  ''';

  final String _sqlExcluirAluno = '''
    DELETE FROM aluno WHERE id = ?
  ''';

  final String _sqlExcluirAlunoObjetivo = '''
    DELETE FROM aluno_objetivo WHERE aluno_id = ?
  ''';

  Map<String, dynamic> toMap(AlunoDTO dto) {
    return {
      'id': dto.id != null ? int.tryParse(dto.id!) : null,
      'nome': dto.nome,
      'telefone': dto.telefone,
      'objetivo_principal_id': dto.objetivoPrincipalId != null
          ? int.tryParse(dto.objetivoPrincipalId!)
          : null,
      'objetivosAdicionaisIds': dto.objetivosAdicionaisIds,
      'objetivoPrincipalNome': dto.objetivoPrincipalNome,
      'objetivosAdicionaisNomes': dto.objetivosAdicionaisNomes,
    };
  }

  AlunoDTO fromMap(
      Map<String, dynamic> map,
      String? objetivoPrincipalNome,
      List<String> objetivosAdicionaisIds,
      List<String> objetivosAdicionaisNomes) {
    return AlunoDTO(
      id: map['id']?.toString(),
      nome: map['nome'] as String,
      telefone: map['telefone'] as String,
      objetivoPrincipalId: map['objetivo_principal_id']?.toString(),
      objetivosAdicionaisIds: objetivosAdicionaisIds,
      objetivoPrincipalNome: objetivoPrincipalNome,
      objetivosAdicionaisNomes: objetivosAdicionaisNomes,
    );
  }

  Future<void> salvar(AlunoDTO dto) async {
    final db = await ConexaoSQLite.database;
    await db.transaction((txn) async {
      try {
        final alunoId = await txn.rawInsert(
          _sqlSalvarAluno,
          [
            dto.id != null ? int.tryParse(dto.id!) : null,
            dto.nome,
            dto.telefone,
            dto.objetivoPrincipalId != null
                ? int.tryParse(dto.objetivoPrincipalId!)
                : null,
          ],
        );
        await txn.rawDelete(_sqlExcluirAlunoObjetivo, [alunoId]);
        for (var objetivoId in dto.objetivosAdicionaisIds) {
          await txn.rawInsert(
            _sqlSalvarAlunoObjetivo,
            [alunoId, int.tryParse(objetivoId)],
          );
        }
      } catch (e) {
        print('Erro ao salvar aluno: $e');
        throw Exception('Erro ao salvar aluno: $e');
      }
    });
  }

  Future<List<AlunoDTO>> consultarTodos() async {
    final db = await ConexaoSQLite.database;
    try {
      final List<Map<String, dynamic>> maps =
          await db.rawQuery(_sqlConsultarTodos);
      final alunos = <AlunoDTO>[];
      for (var map in maps) {
        final objetivos = await _consultarObjetivosPorAluno(map['id']);
        String? objetivoPrincipalNome;
        if (map['objetivo_principal_id'] != null) {
          final objetivoPrincipalMaps = await db.rawQuery(
            _sqlConsultarObjetivoPrincipal,
            [map['objetivo_principal_id']],
          );
          if (objetivoPrincipalMaps.isNotEmpty) {
            objetivoPrincipalNome =
                objetivoPrincipalMaps.first['nome'] as String?;
          }
        }
        alunos.add(fromMap(
          map,
          objetivoPrincipalNome,
          objetivos.map((o) => o.id!).toList(),
          objetivos.map((o) => o.nome).toList(),
        ));
      }
      return alunos;
    } catch (e) {
      print('Erro ao consultar alunos: $e');
      throw Exception('Erro ao consultar alunos: $e');
    }
  }

  Future<List<DTOObjetivo>> _consultarObjetivosPorAluno(int alunoId) async {
    final db = await ConexaoSQLite.database;
    try {
      final List<Map<String, dynamic>> maps =
          await db.rawQuery(_sqlConsultarObjetivosPorAluno, [alunoId]);
      return maps
          .map((map) => DTOObjetivo(
              id: map['id']?.toString(), nome: map['nome'] as String))
          .toList();
    } catch (e) {
      print('Erro ao consultar objetivos do aluno $alunoId: $e');
      throw Exception('Erro ao consultar objetivos do aluno: $e');
    }
  }

  Future<AlunoDTO?> consultarPorId(int id) async {
    final db = await ConexaoSQLite.database;
    try {
      final List<Map<String, dynamic>> maps =
          await db.rawQuery(_sqlConsultarPorId, [id]);
      if (maps.isNotEmpty) {
        final objetivos = await _consultarObjetivosPorAluno(id);
        String? objetivoPrincipalNome;
        if (maps.first['objetivo_principal_id'] != null) {
          final objetivoPrincipalMaps = await db.rawQuery(
            _sqlConsultarObjetivoPrincipal,
            [maps.first['objetivo_principal_id']],
          );
          if (objetivoPrincipalMaps.isNotEmpty) {
            objetivoPrincipalNome =
                objetivoPrincipalMaps.first['nome'] as String?;
          }
        }
        return fromMap(
          maps.first,
          objetivoPrincipalNome,
          objetivos.map((o) => o.id!).toList(),
          objetivos.map((o) => o.nome).toList(),
        );
      }
      return null;
    } catch (e) {
      print('Erro ao consultar aluno por ID $id: $e');
      throw Exception('Erro ao consultar aluno por ID: $e');
    }
  }

  Future<void> excluir(int id) async {
    final db = await ConexaoSQLite.database;
    await db.transaction((txn) async {
      try {
        await txn.rawDelete(_sqlExcluirAlunoObjetivo, [id]);
        await txn.rawDelete(_sqlExcluirAluno, [id]);
      } catch (e) {
        print('Erro ao excluir aluno $id: $e');
        throw Exception('Erro ao excluir aluno: $e');
      }
    });
  }
}
