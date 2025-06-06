import 'dart:convert';

class ExercicioDTO {
  final String nome;

  ExercicioDTO({
    required this.nome,
  });

  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
    };
  }

  factory ExercicioDTO.fromJson(Map<String, dynamic> json) {
    return ExercicioDTO(
      nome: json['nome'] as String,
    );
  }

  String toJsonString() => jsonEncode(toJson());

  factory ExercicioDTO.fromJsonString(String jsonString) =>
      ExercicioDTO.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
}
