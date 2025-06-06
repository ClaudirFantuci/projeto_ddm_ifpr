import 'dart:convert';

class ObjetivoDTO {
  final String nome;

  ObjetivoDTO({
    required this.nome,
  });

  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
    };
  }

  factory ObjetivoDTO.fromJson(Map<String, dynamic> json) {
    return ObjetivoDTO(
      nome: json['nome'] as String,
    );
  }

  String toJsonString() => jsonEncode(toJson());

  factory ObjetivoDTO.fromJsonString(String jsonString) =>
      ObjetivoDTO.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
}
