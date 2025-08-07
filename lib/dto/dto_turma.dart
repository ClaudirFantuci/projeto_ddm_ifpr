class TurmaDTO {
  String? id;
  String nome;
  List<String> professoresIds;
  List<String>? professoresNomes;
  List<String> alunosIds;
  List<String>? alunosNomes;

  TurmaDTO({
    this.id,
    required this.nome,
    required this.professoresIds,
    this.professoresNomes,
    required this.alunosIds,
    this.alunosNomes,
  });
}
