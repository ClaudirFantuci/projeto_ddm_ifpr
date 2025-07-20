class DTOExercicio {
  String? id;
  String nome;
  List<String> equipamentosIds;
  List<String>? equipamentosNomes;

  DTOExercicio({
    this.id,
    required this.nome,
    required this.equipamentosIds,
    this.equipamentosNomes,
  });
}
