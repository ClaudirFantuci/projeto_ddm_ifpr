import 'package:projeto_ddm_ifpr/banco/sqlite/conexao.dart';
import 'package:projeto_ddm_ifpr/dto/dto_agendamento.dart';
import 'package:sqflite/sqflite.dart';

class DAOAgendamento {
  final String _sqlSalvar = '''
    INSERT OR REPLACE INTO agendamento (id, dia_semana, horario_inicio, horario_fim, academia_id, academia_nome, turma_id, turma_nome, alunos_ids, alunos_nomes)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
  ''';

  final String _sqlConsultarTodos = '''
    SELECT id, dia_semana, horario_inicio, horario_fim, academia_id, academia_nome, turma_id, turma_nome, alunos_ids, alunos_nomes
    FROM agendamento
  ''';

  final String _sqlExcluir = '''
    DELETE FROM agendamento WHERE id = ?
  ''';

  Map<String, dynamic> toMap(DTOAgendamento dto) {
    return {
      'id': dto.id != null ? int.tryParse(dto.id!) : null,
      'dia_semana': dto.diaSemana,
      'horario_inicio': dto.horarioInicio,
      'horario_fim': dto.horarioFim,
      'academia_id': int.tryParse(dto.academiaId),
      'academia_nome': dto.academiaNome,
      'turma_id': dto.turmaId != null ? int.tryParse(dto.turmaId!) : null,
      'turma_nome': dto.turmaNome,
      'alunos_ids': dto.alunosIds?.join(','),
      'alunos_nomes': dto.alunosNomes?.join(','),
    };
  }

  DTOAgendamento fromMap(Map<String, dynamic> map) {
    return DTOAgendamento(
      id: map['id']?.toString(),
      diaSemana: map['dia_semana'] as String,
      horarioInicio: map['horario_inicio'] as String,
      horarioFim: map['horario_fim'] as String,
      academiaId: map['academia_id'].toString(),
      academiaNome: map['academia_nome'] as String?,
      turmaId: map['turma_id']?.toString(),
      turmaNome: map['turma_nome'] as String?,
      alunosIds: map['alunos_ids'] != null
          ? (map['alunos_ids'] as String).split(',')
          : null,
      alunosNomes: map['alunos_nomes'] != null
          ? (map['alunos_nomes'] as String).split(',')
          : null,
    );
  }

  Future<void> salvar(DTOAgendamento dto) async {
    final db = await ConexaoSQLite.database;
    try {
      await db.rawInsert(_sqlSalvar, [
        dto.id != null ? int.tryParse(dto.id!) : null,
        dto.diaSemana,
        dto.horarioInicio,
        dto.horarioFim,
        int.tryParse(dto.academiaId),
        dto.academiaNome,
        dto.turmaId != null ? int.tryParse(dto.turmaId!) : null,
        dto.turmaNome,
        dto.alunosIds?.join(','),
        dto.alunosNomes?.join(','),
      ]);
    } catch (e) {
      throw Exception('Erro ao salvar agendamento: $e');
    }
  }

  Future<List<DTOAgendamento>> consultarTodos() async {
    final db = await ConexaoSQLite.database;
    try {
      final List<Map<String, dynamic>> maps =
          await db.rawQuery(_sqlConsultarTodos);
      return maps.map((map) => fromMap(map)).toList();
    } catch (e) {
      throw Exception('Erro ao consultar agendamentos: $e');
    }
  }

  Future<void> excluir(String id) async {
    final db = await ConexaoSQLite.database;
    try {
      await db.rawDelete(_sqlExcluir, [int.parse(id)]);
    } catch (e) {
      throw Exception('Erro ao excluir agendamento: $e');
    }
  }
}
