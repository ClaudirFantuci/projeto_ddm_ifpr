class TurmaDTO {
  String? id;
  String nome;
  String? horarioInicio;
  String? horarioFim;
  String? diaSemana;
  List<String> professoresIds;
  List<String>? professoresNomes;
  List<String> alunosIds;
  List<String>? alunosNomes;

  TurmaDTO({
    this.id,
    required this.nome,
    this.horarioInicio,
    this.horarioFim,
    this.diaSemana,
    required this.professoresIds,
    this.professoresNomes,
    required this.alunosIds,
    this.alunosNomes,
  });
}
