import 'dart:convert';

class TreinoDTO {
  final String nome;
  final List<String> exercicios;

  TreinoDTO({
    required this.nome,
    required this.exercicios,
  });

  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'exercicios': exercicios,
    };
  }

  factory TreinoDTO.fromJson(Map<String, dynamic> json) {
    return TreinoDTO(
      nome: json['nome'] as String,
      exercicios: List<String>.from(json['exercicios'] as List),
    );
  }

  String toJsonString() => jsonEncode(toJson());

  factory TreinoDTO.fromJsonString(String jsonString) =>
      TreinoDTO.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
}
