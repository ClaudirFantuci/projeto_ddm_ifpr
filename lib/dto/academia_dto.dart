import 'dart:convert';

class AcademiaDTO {
  final String nome;
  final String endereco;
  final String? telefone;
  final String cidade;

  AcademiaDTO({
    required this.nome,
    required this.endereco,
    this.telefone,
    required this.cidade,
  });

  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'endereco': endereco,
      'telefone': telefone,
      'cidade': cidade,
    };
  }

  factory AcademiaDTO.fromJson(Map<String, dynamic> json) {
    return AcademiaDTO(
      nome: json['nome'] as String,
      endereco: json['endereco'] as String,
      telefone: json['telefone'] as String?,
      cidade: json['cidade'] as String,
    );
  }

  String toJsonString() => jsonEncode(toJson());

  factory AcademiaDTO.fromJsonString(String jsonString) =>
      AcademiaDTO.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
}
