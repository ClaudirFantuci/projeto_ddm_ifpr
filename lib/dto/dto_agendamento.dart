class DTOAgendamento {
  final String? id;
  final String diaSemana;
  final String horarioInicio;
  final String horarioFim;
  final String academiaId;
  final String? academiaNome;
  final String? turmaId;
  final String? turmaNome;
  final List<String>? alunosIds;
  final List<String>? alunosNomes;

  DTOAgendamento({
    this.id,
    required this.diaSemana,
    required this.horarioInicio,
    required this.horarioFim,
    required this.academiaId,
    this.academiaNome,
    this.turmaId,
    this.turmaNome,
    this.alunosIds,
    this.alunosNomes,
  });
}
