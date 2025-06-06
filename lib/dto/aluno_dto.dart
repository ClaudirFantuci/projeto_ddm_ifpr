import 'dart:convert';

class AlunoDTO {
  final String nome;
  final String? telefone;
  final String objetivoPrincipal;
  final List<String> objetivosAdicionais;

  AlunoDTO({
    required this.nome,
    this.telefone,
    required this.objetivoPrincipal,
    required this.objetivosAdicionais,
  });

  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'telefone': telefone,
      'objetivoPrincipal': objetivoPrincipal,
      'objetivosAdicionais': objetivosAdicionais,
    };
  }

  factory AlunoDTO.fromJson(Map<String, dynamic> json) {
    return AlunoDTO(
      nome: json['nome'] as String,
      telefone: json['telefone'] as String?,
      objetivoPrincipal: json['objetivoPrincipal'] as String,
      objetivosAdicionais:
          List<String>.from(json['objetivosAdicionais'] as List),
    );
  }

  String toJsonString() => jsonEncode(toJson());

  factory AlunoDTO.fromJsonString(String jsonString) =>
      AlunoDTO.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
}
