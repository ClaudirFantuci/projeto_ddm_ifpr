class AlunoDTO {
  String? id;
  String nome;
  String telefone;
  String? objetivoPrincipalId;
  List<String> objetivosAdicionaisIds;
  String? objetivoPrincipalNome;
  List<String>? objetivosAdicionaisNomes;

  AlunoDTO({
    this.id,
    required this.nome,
    required this.telefone,
    this.objetivoPrincipalId,
    required this.objetivosAdicionaisIds,
    this.objetivoPrincipalNome,
    this.objetivosAdicionaisNomes,
  });
}
