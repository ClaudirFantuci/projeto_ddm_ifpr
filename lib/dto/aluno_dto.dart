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
}
