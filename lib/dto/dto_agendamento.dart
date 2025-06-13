class DTOAgendamento {
  String? id;
  String alunoId; // Reference to DTOAluno ID
  String academiaId; // Reference to DTOAcademia ID
  String diaSemana;
  String horario;

  DTOAgendamento({
    this.id,
    required this.alunoId,
    required this.academiaId,
    required this.diaSemana,
    required this.horario,
  });
}
