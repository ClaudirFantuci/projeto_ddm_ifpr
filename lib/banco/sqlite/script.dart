import 'package:sqflite/sqflite.dart';
import 'package:projeto_ddm_ifpr/banco/sqlite/conexao.dart';

class ScriptSQLite {
  static const int _databaseVersion = 1;

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

  static const String _criarTabelaObjetivo = '''
    CREATE TABLE objetivo (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nome TEXT NOT NULL
    )
  ''';

  static const String _criarTabelaExercicio = '''
    CREATE TABLE exercicio (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nome TEXT NOT NULL
    )
  ''';

  static const String _criarTabelaExercicioEquipamento = '''
    CREATE TABLE exercicio_equipamento (
      exercicio_id INTEGER NOT NULL,
      equipamento_id INTEGER NOT NULL,
      PRIMARY KEY (exercicio_id, equipamento_id),
      FOREIGN KEY (exercicio_id) REFERENCES exercicio(id),
      FOREIGN KEY (equipamento_id) REFERENCES equipamento(id)
    )
  ''';

  static const String _criarTabelaTreino = '''
    CREATE TABLE treino (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nome TEXT NOT NULL
    )
  ''';

  static const String _criarTabelaTreinoExercicio = '''
    CREATE TABLE treino_exercicio (
      treino_id INTEGER NOT NULL,
      exercicio_id INTEGER NOT NULL,
      PRIMARY KEY (treino_id, exercicio_id),
      FOREIGN KEY (treino_id) REFERENCES treino(id),
      FOREIGN KEY (exercicio_id) REFERENCES exercicio(id)
    )
  ''';

  static const String _criarTabelaAluno = '''
    CREATE TABLE aluno (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nome TEXT NOT NULL,
      telefone TEXT NOT NULL,
      objetivo_principal_id INTEGER,
      FOREIGN KEY (objetivo_principal_id) REFERENCES objetivo(id)
    )
  ''';

  static const String _criarTabelaAlunoObjetivo = '''
    CREATE TABLE aluno_objetivo (
      aluno_id INTEGER NOT NULL,
      objetivo_id INTEGER NOT NULL,
      PRIMARY KEY (aluno_id, objetivo_id),
      FOREIGN KEY (aluno_id) REFERENCES aluno(id),
      FOREIGN KEY (objetivo_id) REFERENCES objetivo(id)
    )
  ''';

  static const String _criarTabelaModalidade = '''
    CREATE TABLE modalidade (
      id TEXT PRIMARY KEY,
      nome TEXT NOT NULL
    )
  ''';

  static const String _criarTabelaProfessor = '''
    CREATE TABLE professor (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nome TEXT NOT NULL,
      telefone TEXT NOT NULL CHECK(length(telefone) <= 15)
    )
  ''';

  static const String _criarTabelaProfessorModalidade = '''
    CREATE TABLE professor_modalidade (
      professor_id INTEGER NOT NULL,
      modalidade_id TEXT NOT NULL,
      PRIMARY KEY (professor_id, modalidade_id),
      FOREIGN KEY (professor_id) REFERENCES professor(id),
      FOREIGN KEY (modalidade_id) REFERENCES modalidade(id)
    )
  ''';

  static const String _criarTabelaDieta = '''
    CREATE TABLE dieta (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nome TEXT NOT NULL,
      descricao TEXT,
      objetivo TEXT
    )
  ''';

  static const String _criarTabelaReceita = '''
    CREATE TABLE receita (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nome TEXT NOT NULL,
      ingredientes TEXT NOT NULL,
      modo_preparo TEXT,
      valor_nutricional TEXT,
      dieta_id INTEGER,
      FOREIGN KEY (dieta_id) REFERENCES dieta(id)
    )
  ''';

  static const String _criarTabelaReceitaDieta = '''
    CREATE TABLE receita_dieta (
      receita_id INTEGER NOT NULL,
      dieta_id INTEGER NOT NULL,
      PRIMARY KEY (receita_id, dieta_id),
      FOREIGN KEY (receita_id) REFERENCES receita(id),
      FOREIGN KEY (dieta_id) REFERENCES dieta(id)
    )
  ''';

  static const String _criarTabelaTurma = '''
    CREATE TABLE turma (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nome TEXT NOT NULL,
      horario_inicio TEXT NOT NULL,
      horario_fim TEXT NOT NULL,
      dia_semana TEXT NOT NULL
    )
  ''';

  static const String _criarTabelaTurmaAluno = '''
    CREATE TABLE turma_aluno (
      turma_id INTEGER NOT NULL,
      aluno_id INTEGER NOT NULL,
      PRIMARY KEY (turma_id, aluno_id),
      FOREIGN KEY (turma_id) REFERENCES turma(id),
      FOREIGN KEY (aluno_id) REFERENCES aluno(id)
    )
  ''';

  static const String _criarTabelaTurmaProfessor = '''
    CREATE TABLE turma_professor (
      turma_id INTEGER NOT NULL,
      professor_id INTEGER NOT NULL,
      PRIMARY KEY (turma_id, professor_id),
      FOREIGN KEY (turma_id) REFERENCES turma(id),
      FOREIGN KEY (professor_id) REFERENCES professor(id)
    )
  ''';

  static const List<String> _insercoesAcademia = [
    "INSERT INTO academia (nome, endereco, telefone_contato, cidade, ativo) VALUES ('Academia Fit', 'Rua das Flores, 123', '44999999999', 'Cascavel', 1)",
    "INSERT INTO academia (nome, endereco, telefone_contato, cidade, ativo) VALUES ('Academia Power', 'Avenida Brasil, 456', '44988888888', 'Toledo', 1)",
  ];

  static const List<String> _insercoesEquipamento = [
    "INSERT INTO equipamento (nome) VALUES ('Esteira')",
    "INSERT INTO equipamento (nome) VALUES ('Bicicleta Ergométrica')",
    "INSERT INTO equipamento (nome) VALUES ('Halteres')",
  ];

  static const List<String> _insercoesObjetivo = [
    "INSERT INTO objetivo (nome) VALUES ('Ganho de Massa Muscular')",
    "INSERT INTO objetivo (nome) VALUES ('Perda de Peso')",
    "INSERT INTO objetivo (nome) VALUES ('Manutenção da Saúde')",
  ];

  static const List<String> _insercoesExercicio = [
    "INSERT INTO exercicio (nome) VALUES ('Supino Reto')",
    "INSERT INTO exercicio (nome) VALUES ('Agachamento Livre')",
    "INSERT INTO exercicio (nome) VALUES ('Corrida na Esteira')",
  ];

  static const List<String> _insercoesExercicioEquipamento = [
    "INSERT INTO exercicio_equipamento (exercicio_id, equipamento_id) VALUES (1, 3)", // Supino Reto - Halteres
    "INSERT INTO exercicio_equipamento (exercicio_id, equipamento_id) VALUES (3, 1)", // Corrida na Esteira - Esteira
  ];

  static const List<String> _insercoesTreino = [
    "INSERT INTO treino (nome) VALUES ('Treino de Força')",
    "INSERT INTO treino (nome) VALUES ('Treino Cardio')",
  ];

  static const List<String> _insercoesTreinoExercicio = [
    "INSERT INTO treino_exercicio (treino_id, exercicio_id) VALUES (1, 1)", // Treino de Força - Supino Reto
    "INSERT INTO treino_exercicio (treino_id, exercicio_id) VALUES (1, 2)", // Treino de Força - Agachamento Livre
    "INSERT INTO treino_exercicio (treino_id, exercicio_id) VALUES (2, 3)", // Treino Cardio - Corrida na Esteira
  ];

  static const List<String> _insercoesAluno = [
    "INSERT INTO aluno (nome, telefone, objetivo_principal_id) VALUES ('João Silva', '44997777777', 1)",
    "INSERT INTO aluno (nome, telefone, objetivo_principal_id) VALUES ('Maria Oliveira', '44996666666', 2)",
  ];

  static const List<String> _insercoesAlunoObjetivo = [
    "INSERT INTO aluno_objetivo (aluno_id, objetivo_id) VALUES (1, 1)", // João - Ganho de Massa
    "INSERT INTO aluno_objetivo (aluno_id, objetivo_id) VALUES (2, 2)", // Maria - Perda de Peso
  ];

  static const List<String> _insercoesModalidade = [
    "INSERT INTO modalidade (id, nome) VALUES ('MUSC', 'Musculação')",
    "INSERT INTO modalidade (id, nome) VALUES ('CARD', 'Cardio')",
  ];

  static const List<String> _insercoesProfessor = [
    "INSERT INTO professor (nome, telefone) VALUES ('Carlos Souza', '44995555555')",
    "INSERT INTO professor (nome, telefone) VALUES ('Ana Pereira', '44994444444')",
  ];

  static const List<String> _insercoesProfessorModalidade = [
    "INSERT INTO professor_modalidade (professor_id, modalidade_id) VALUES (1, 'MUSC')",
    "INSERT INTO professor_modalidade (professor_id, modalidade_id) VALUES (2, 'CARD')",
  ];

  static const List<String> _insercoesDieta = [
    "INSERT INTO dieta (nome, descricao, objetivo) VALUES ('Dieta de Ganho de Massa', 'Alta em proteínas e carboidratos', 'Ganho Muscular')",
    "INSERT INTO dieta (nome, descricao, objetivo) VALUES ('Dieta de Perda de Peso', 'Baixa em calorias', 'Emagrecimento')",
    "INSERT INTO dieta (nome, descricao, objetivo) VALUES ('Dieta de Manutenção', 'Balanceada', 'Manutenção')",
  ];

  static const List<String> _insercoesReceita = [
    "INSERT INTO receita (nome, ingredientes, modo_preparo, valor_nutricional, dieta_id) VALUES ('Shake de Proteína', '[\"Whey protein\",\"leite\",\"banana\"]', 'Bater no liquidificador por 30 segundos', '{\"calorias\":300,\"proteinas\":30}', 1)",
    "INSERT INTO receita (nome, ingredientes, modo_preparo, valor_nutricional, dieta_id) VALUES ('Omelete de Claras', '[\"6 claras\",\"espinafre\",\"tomate\"]', 'Misturar os ingredientes e fritar em frigideira antiaderente', '{\"calorias\":150,\"proteinas\":20}', 1)",
    "INSERT INTO receita (nome, ingredientes, modo_preparo, valor_nutricional, dieta_id) VALUES ('Salada de Quinoa', '[\"Quinoa\",\"frango desfiado\",\"rúcula\",\"azeite\"]', 'Cozinhar quinoa e misturar com os demais ingredientes', '{\"calorias\":200,\"proteinas\":15}', 2)",
    "INSERT INTO receita (nome, ingredientes, modo_preparo, valor_nutricional, dieta_id) VALUES ('Sopa de Legumes', '[\"Cenoura\",\"abobrinha\",\"brócolis\",\"cebola\"]', 'Cozinhar todos os ingredientes em água e temperar', '{\"calorias\":100,\"proteinas\":5}', 2)",
    "INSERT INTO receita (nome, ingredientes, modo_preparo, valor_nutricional, dieta_id) VALUES ('Smoothie de Frutas', '[\"Morango\",\"banana\",\"iogurte natural\"]', 'Bater no liquidificador até ficar homogêneo', '{\"calorias\":180,\"proteinas\":8}', 3)",
  ];

  static const List<String> _insercoesReceitaDieta = [
    "INSERT INTO receita_dieta (receita_id, dieta_id) VALUES (1, 1)", // Shake de Proteína: Dieta de Ganho de Massa
    "INSERT INTO receita_dieta (receita_id, dieta_id) VALUES (2, 1)", // Omelete de Claras: Dieta de Ganho de Massa
    "INSERT INTO receita_dieta (receita_id, dieta_id) VALUES (3, 2)", // Salada de Quinoa: Dieta de Perda de Peso
    "INSERT INTO receita_dieta (receita_id, dieta_id) VALUES (4, 2)", // Sopa de Legumes: Dieta de Perda de Peso
    "INSERT INTO receita_dieta (receita_id, dieta_id) VALUES (5, 3)", // Smoothie de Frutas: Dieta de Manutenção
    "INSERT INTO receita_dieta (receita_id, dieta_id) VALUES (3, 3)", // Salada de Quinoa: Dieta de Manutenção (exemplo de múltiplas dietas)
  ];

  static const List<String> _insercoesTurma = [
    "INSERT INTO turma (nome, horario_inicio, horario_fim, dia_semana) VALUES ('Turma A', '08:00', '09:00', 'Segunda')",
    "INSERT INTO turma (nome, horario_inicio, horario_fim, dia_semana) VALUES ('Turma B', '09:00', '10:00', 'Terça')",
  ];

  static const List<String> _insercoesTurmaProfessor = [
    "INSERT INTO turma_professor (turma_id, professor_id) VALUES (1, 1)",
    "INSERT INTO turma_professor (turma_id, professor_id) VALUES (2, 2)",
  ];

  static const List<String> _insercoesTurmaAluno = [
    "INSERT INTO turma_aluno (turma_id, aluno_id) VALUES (1, 1)",
    "INSERT INTO turma_aluno (turma_id, aluno_id) VALUES (2, 2)",
  ];

  static const List<String> comandosCriarTabelas = [
    _criarTabelaAcademia,
    _criarTabelaEquipamento,
    _criarTabelaObjetivo,
    _criarTabelaExercicio,
    _criarTabelaExercicioEquipamento,
    _criarTabelaTreino,
    _criarTabelaTreinoExercicio,
    _criarTabelaAluno,
    _criarTabelaAlunoObjetivo,
    _criarTabelaModalidade,
    _criarTabelaProfessor,
    _criarTabelaProfessorModalidade,
    _criarTabelaDieta,
    _criarTabelaReceita,
    _criarTabelaReceitaDieta,
    _criarTabelaTurma,
    _criarTabelaTurmaAluno,
    _criarTabelaTurmaProfessor,
  ];

  static const List<List<String>> comandosInsercoes = [
    _insercoesAcademia,
    _insercoesEquipamento,
    _insercoesObjetivo,
    _insercoesExercicio,
    _insercoesExercicioEquipamento,
    _insercoesTreino,
    _insercoesTreinoExercicio,
    _insercoesAluno,
    _insercoesAlunoObjetivo,
    _insercoesModalidade,
    _insercoesProfessor,
    _insercoesProfessorModalidade,
    _insercoesDieta,
    _insercoesReceita,
    _insercoesReceitaDieta,
    _insercoesTurma,
    _insercoesTurmaProfessor,
    _insercoesTurmaAluno,
  ];

  Future<void> criarTabelas(Database db) async {
    for (var comando in comandosCriarTabelas) {
      await db.execute(comando);
    }
    await db.execute('PRAGMA user_version = $_databaseVersion');
  }

  Future<void> inserirDadosIniciais(Database db) async {
    for (var listaInsercoes in comandosInsercoes) {
      for (var comando in listaInsercoes) {
        await db.execute(comando);
      }
    }
  }
}
