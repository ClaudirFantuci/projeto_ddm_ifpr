class DTOExercicio {
  String? id;
  String nome;
  String equipamentoId;
  String? equipamentoNome;
  String? equipamentoSecundarioId;
  String? equipamentoSecundarioNome;

  DTOExercicio({
    this.id,
    required this.nome,
    required this.equipamentoId,
    this.equipamentoNome,
    this.equipamentoSecundarioId,
    this.equipamentoSecundarioNome,
  });
}
