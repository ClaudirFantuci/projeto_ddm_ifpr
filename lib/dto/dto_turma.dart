class TurmaDTO {
  String? id;
  String nome;
  String? horario;
  List<String> professoresIds;
  List<String>? professoresNomes;
  List<String> alunosIds;
  List<String>? alunosNomes;

  TurmaDTO({
    this.id,
    required this.nome,
    this.horario,
    required this.professoresIds,
    this.professoresNomes,
    required this.alunosIds,
    this.alunosNomes,
  });
}
