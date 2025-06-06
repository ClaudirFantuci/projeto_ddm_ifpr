import 'dart:convert';

class AgendamentoDTO {
  final String aluno;
  final String academia;
  final String diaSemana;
  final String horario;

  AgendamentoDTO({
    required this.aluno,
    required this.academia,
    required this.diaSemana,
    required this.horario,
  });

  Map<String, dynamic> toJson() {
    return {
      'aluno': aluno,
      'academia': academia,
      'diaSemana': diaSemana,
      'horario': horario,
    };
  }

  factory AgendamentoDTO.fromJson(Map<String, dynamic> json) {
    return AgendamentoDTO(
      aluno: json['aluno'] as String,
      academia: json['academia'] as String,
      diaSemana: json['diaSemana'] as String,
      horario: json['horario'] as String,
    );
  }

  String toJsonString() => jsonEncode(toJson());

  factory AgendamentoDTO.fromJsonString(String jsonString) =>
      AgendamentoDTO.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
}
