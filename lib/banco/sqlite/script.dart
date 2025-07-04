class ScriptSQLite {
  static const String _criarTabelaAcademia = '''
    CREATE TABLE academia (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nome TEXT NOT NULL,
      endereco TEXT NOT NULL,
      telefone_contato TEXT NOT NULL CHECK(length(telefone_contato) <= 15),
      cidade TEXT NOT NULL,
      ativo INTEGER NOT NULL DEFAULT 1
    )
  ''';

  static const String _criarTabelaEquipamento = '''
    CREATE TABLE equipamento (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nome TEXT NOT NULL
    )
  ''';

  static const List<String> comandosCriarTabelas = [
    _criarTabelaAcademia,
    _criarTabelaEquipamento,
  ];

  static const List<String> _insercoesAcademia = [
    "INSERT INTO academia (nome, endereco, telefone_contato, cidade, ativo) VALUES ('FitLife', 'Rua Principal, 123', '(44) 99999-1234', 'Paranavaí', 1)",
    "INSERT INTO academia (nome, endereco, telefone_contato, cidade, ativo) VALUES ('PowerGym', 'Av. Central, 456', '(44) 98888-5678', 'Maringá', 1)",
    "INSERT INTO academia (nome, endereco, telefone_contato, cidade, ativo) VALUES ('Vida Saudável', 'Rua das Flores, 789', '(44) 97777-9012', 'Cianorte', 0)",
  ];

  static const List<String> _insercoesEquipamento = [
    "INSERT INTO equipamento (nome) VALUES ('Halteres')",
    "INSERT INTO equipamento (nome) VALUES ('Barra Olímpica')",
    "INSERT INTO equipamento (nome) VALUES ('Máquina de Smith')",
    "INSERT INTO equipamento (nome) VALUES ('Cabo de Aço')",
    "INSERT INTO equipamento (nome) VALUES ('Banco Ajustável')",
    "INSERT INTO equipamento (nome) VALUES ('Kettlebell')",
    "INSERT INTO equipamento (nome) VALUES ('Leg Press')",
    "INSERT INTO equipamento (nome) VALUES ('Esteira')",
  ];

  static const List<List<String>> comandosInsercoes = [
    _insercoesAcademia,
    _insercoesEquipamento,
  ];
}
