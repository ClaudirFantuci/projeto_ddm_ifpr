class DTOTreino {
  String? id;
  String nome;
  List<String> exerciciosIds; // References to DTOExercicio IDs

  DTOTreino({
    this.id,
    required this.nome,
    required this.exerciciosIds,
  });
}
