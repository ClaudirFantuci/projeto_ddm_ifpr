import 'package:sqflite/sqflite.dart';
import 'package:projeto_ddm_ifpr/banco/sqlite/conexao.dart';

class ScriptSQLite {
  static const int _databaseVersion = 1; // Banco recriado

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
      FOREIGN KEY (exercicio_id) REFERENCES exercicio(id) ON DELETE CASCADE,
      FOREIGN KEY (equipamento_id) REFERENCES equipamento(id) ON DELETE CASCADE
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
      FOREIGN KEY (treino_id) REFERENCES treino(id) ON DELETE CASCADE,
      FOREIGN KEY (exercicio_id) REFERENCES exercicio(id) ON DELETE CASCADE
    )
  ''';

  static const String _criarTabelaAluno = '''
    CREATE TABLE aluno (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nome TEXT NOT NULL,
      telefone TEXT NOT NULL CHECK(length(telefone) <= 15),
      objetivo_principal_id INTEGER,
      FOREIGN KEY (objetivo_principal_id) REFERENCES objetivo(id) ON DELETE SET NULL
    )
  ''';

  static const String _criarTabelaAlunoObjetivo = '''
    CREATE TABLE aluno_objetivo (
      aluno_id INTEGER NOT NULL,
      objetivo_id INTEGER NOT NULL,
      PRIMARY KEY (aluno_id, objetivo_id),
      FOREIGN KEY (aluno_id) REFERENCES aluno(id) ON DELETE CASCADE,
      FOREIGN KEY (objetivo_id) REFERENCES objetivo(id) ON DELETE CASCADE
    )
  ''';

  static const String _criarTabelaModalidade = '''
    CREATE TABLE modalidade (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
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
      modalidade_id INTEGER NOT NULL,
      PRIMARY KEY (professor_id, modalidade_id),
      FOREIGN KEY (professor_id) REFERENCES professor(id) ON DELETE CASCADE,
      FOREIGN KEY (modalidade_id) REFERENCES modalidade(id) ON DELETE CASCADE
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
      ingredientes TEXT,
      modo_preparo TEXT,
      valor_nutricional TEXT
    )
  ''';

  static const String _criarTabelaReceitaDieta = '''
    CREATE TABLE receita_dieta (
      receita_id INTEGER NOT NULL,
      dieta_id INTEGER NOT NULL,
      PRIMARY KEY (receita_id, dieta_id),
      FOREIGN KEY (receita_id) REFERENCES receita(id) ON DELETE CASCADE,
      FOREIGN KEY (dieta_id) REFERENCES dieta(id) ON DELETE CASCADE
    )
  ''';

  static const String _criarTabelaTurma = '''
    CREATE TABLE turma (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nome TEXT NOT NULL,
      horario_inicio TEXT,
      horario_fim TEXT,
      dia_semana TEXT
    )
  ''';

  static const String _criarTabelaTurmaAluno = '''
    CREATE TABLE turma_aluno (
      turma_id INTEGER NOT NULL,
      aluno_id INTEGER NOT NULL,
      PRIMARY KEY (turma_id, aluno_id),
      FOREIGN KEY (turma_id) REFERENCES turma(id) ON DELETE CASCADE,
      FOREIGN KEY (aluno_id) REFERENCES aluno(id) ON DELETE CASCADE
    )
  ''';

  static const String _criarTabelaTurmaProfessor = '''
    CREATE TABLE turma_professor (
      turma_id INTEGER NOT NULL,
      professor_id INTEGER NOT NULL,
      PRIMARY KEY (turma_id, professor_id),
      FOREIGN KEY (turma_id) REFERENCES turma(id) ON DELETE CASCADE,
      FOREIGN KEY (professor_id) REFERENCES professor(id) ON DELETE CASCADE
    )
  ''';

  static const String _criarTabelaAgendamento = '''
    CREATE TABLE agendamento (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      dia_semana TEXT NOT NULL,
      horario_inicio TEXT NOT NULL,
      horario_fim TEXT NOT NULL,
      academia_id INTEGER NOT NULL,
      academia_nome TEXT NOT NULL,
      turma_id INTEGER,
      turma_nome TEXT,
      alunos_ids TEXT,
      alunos_nomes TEXT,
      FOREIGN KEY (academia_id) REFERENCES academia(id) ON DELETE CASCADE,
      FOREIGN KEY (turma_id) REFERENCES turma(id) ON DELETE SET NULL
    )
  ''';

  static const String _criarTabelaAgendamentoAluno = '''
    CREATE TABLE agendamento_aluno (
      agendamento_id INTEGER NOT NULL,
      aluno_id INTEGER NOT NULL,
      aluno_nome TEXT NOT NULL,
      PRIMARY KEY (agendamento_id, aluno_id),
      FOREIGN KEY (agendamento_id) REFERENCES agendamento(id) ON DELETE CASCADE,
      FOREIGN KEY (aluno_id) REFERENCES aluno(id) ON DELETE CASCADE
    )
  ''';

  static const List<String> _insercoesAcademia = [
    "INSERT INTO academia (nome, endereco, telefone_contato, cidade, ativo) VALUES ('Academia Fit', 'Rua Principal, 123', '41987654321', 'Curitiba', 1)",
    "INSERT INTO academia (nome, endereco, telefone_contato, cidade, ativo) VALUES ('Academia Power', 'Av. Central, 456', '41912345678', 'São Paulo', 1)",
    "INSERT INTO academia (nome, endereco, telefone_contato, cidade, ativo) VALUES ('Academia Top', 'Rua das Flores, 789', '41998765432', 'Florianópolis', 1)",
    "INSERT INTO academia (nome, endereco, telefone_contato, cidade, ativo) VALUES ('Academia Energy', 'Av. Brasil, 101', '41987651234', 'Porto Alegre', 1)",
    "INSERT INTO academia (nome, endereco, telefone_contato, cidade, ativo) VALUES ('Academia Viva', 'Rua do Sol, 202', '41912348765', 'Rio de Janeiro', 1)",
    "INSERT INTO academia (nome, endereco, telefone_contato, cidade, ativo) VALUES ('Academia Move', 'Av. Liberdade, 303', '41987654322', 'Belo Horizonte', 1)",
    "INSERT INTO academia (nome, endereco, telefone_contato, cidade, ativo) VALUES ('Academia Ativa', 'Rua da Paz, 404', '41912345679', 'Salvador', 1)",
  ];

  static const List<String> _insercoesEquipamento = [
    "INSERT INTO equipamento (nome) VALUES ('Halteres')",
    "INSERT INTO equipamento (nome) VALUES ('Esteira')",
    "INSERT INTO equipamento (nome) VALUES ('Bicicleta Ergométrica')",
    "INSERT INTO equipamento (nome) VALUES ('Leg Press')",
    "INSERT INTO equipamento (nome) VALUES ('Barra Fixa')",
    "INSERT INTO equipamento (nome) VALUES ('Máquina de Supino')",
    "INSERT INTO equipamento (nome) VALUES ('Corda Naval')",
  ];

  static const List<String> _insercoesObjetivo = [
    "INSERT INTO objetivo (nome) VALUES ('Hipertrofia')",
    "INSERT INTO objetivo (nome) VALUES ('Emagrecimento')",
    "INSERT INTO objetivo (nome) VALUES ('Resistência')",
    "INSERT INTO objetivo (nome) VALUES ('Saúde Geral')",
    "INSERT INTO objetivo (nome) VALUES ('Força')",
    "INSERT INTO objetivo (nome) VALUES ('Flexibilidade')",
    "INSERT INTO objetivo (nome) VALUES ('Condicionamento')",
  ];

  static const List<String> _insercoesExercicio = [
    "INSERT INTO exercicio (nome) VALUES ('Supino Reto')",
    "INSERT INTO exercicio (nome) VALUES ('Agachamento Livre')",
    "INSERT INTO exercicio (nome) VALUES ('Levantamento Terra')",
    "INSERT INTO exercicio (nome) VALUES ('Rosca Bíceps')",
    "INSERT INTO exercicio (nome) VALUES ('Abdominal Crunch')",
    "INSERT INTO exercicio (nome) VALUES ('Remada Baixa')",
    "INSERT INTO exercicio (nome) VALUES ('Corrida na Esteira')",
  ];

  static const List<String> _insercoesExercicioEquipamento = [
    "INSERT INTO exercicio_equipamento (exercicio_id, equipamento_id) VALUES (1, 6)", // Supino Reto com Máquina de Supino
    "INSERT INTO exercicio_equipamento (exercicio_id, equipamento_id) VALUES (2, 4)", // Agachamento Livre com Leg Press
    "INSERT INTO exercicio_equipamento (exercicio_id, equipamento_id) VALUES (3, 1)", // Levantamento Terra com Halteres
    "INSERT INTO exercicio_equipamento (exercicio_id, equipamento_id) VALUES (4, 1)", // Rosca Bíceps com Halteres
    "INSERT INTO exercicio_equipamento (exercicio_id, equipamento_id) VALUES (5, 7)", // Abdominal Crunch com Corda Naval
    "INSERT INTO exercicio_equipamento (exercicio_id, equipamento_id) VALUES (6, 6)", // Remada Baixa com Máquina de Supino
    "INSERT INTO exercicio_equipamento (exercicio_id, equipamento_id) VALUES (7, 2)", // Corrida na Esteira com Esteira
  ];

  static const List<String> _insercoesTreino = [
    "INSERT INTO treino (nome) VALUES ('Treino de Peito')",
    "INSERT INTO treino (nome) VALUES ('Treino de Pernas')",
    "INSERT INTO treino (nome) VALUES ('Treino de Costas')",
    "INSERT INTO treino (nome) VALUES ('Treino de Braços')",
    "INSERT INTO treino (nome) VALUES ('Treino de Core')",
    "INSERT INTO treino (nome) VALUES ('Treino de Cardio')",
    "INSERT INTO treino (nome) VALUES ('Treino Full Body')",
  ];

  static const List<String> _insercoesTreinoExercicio = [
    "INSERT INTO treino_exercicio (treino_id, exercicio_id) VALUES (1, 1)", // Treino de Peito com Supino Reto
    "INSERT INTO treino_exercicio (treino_id, exercicio_id) VALUES (2, 2)", // Treino de Pernas com Agachamento Livre
    "INSERT INTO treino_exercicio (treino_id, exercicio_id) VALUES (3, 3)", // Treino de Costas com Levantamento Terra
    "INSERT INTO treino_exercicio (treino_id, exercicio_id) VALUES (4, 4)", // Treino de Braços com Rosca Bíceps
    "INSERT INTO treino_exercicio (treino_id, exercicio_id) VALUES (5, 5)", // Treino de Core com Abdominal Crunch
    "INSERT INTO treino_exercicio (treino_id, exercicio_id) VALUES (6, 7)", // Treino de Cardio com Corrida na Esteira
    "INSERT INTO treino_exercicio (treino_id, exercicio_id) VALUES (7, 6)", // Treino Full Body com Remada Baixa
  ];

  static const List<String> _insercoesAluno = [
    "INSERT INTO aluno (nome, telefone, objetivo_principal_id) VALUES ('João Silva', '41987654321', 1)",
    "INSERT INTO aluno (nome, telefone, objetivo_principal_id) VALUES ('Maria Oliveira', '41912345678', 2)",
    "INSERT INTO aluno (nome, telefone, objetivo_principal_id) VALUES ('Pedro Santos', '41998765432', 3)",
    "INSERT INTO aluno (nome, telefone, objetivo_principal_id) VALUES ('Ana Costa', '41987651234', 4)",
    "INSERT INTO aluno (nome, telefone, objetivo_principal_id) VALUES ('Lucas Pereira', '41912348765', 5)",
    "INSERT INTO aluno (nome, telefone, objetivo_principal_id) VALUES ('Clara Mendes', '41987654322', 6)",
    "INSERT INTO aluno (nome, telefone, objetivo_principal_id) VALUES ('Rafael Lima', '41912345679', 7)",
  ];

  static const List<String> _insercoesAlunoObjetivo = [
    "INSERT INTO aluno_objetivo (aluno_id, objetivo_id) VALUES (1, 2)", // João Silva com Emagrecimento
    "INSERT INTO aluno_objetivo (aluno_id, objetivo_id) VALUES (2, 1)", // Maria Oliveira com Hipertrofia
    "INSERT INTO aluno_objetivo (aluno_id, objetivo_id) VALUES (3, 3)", // Pedro Santos com Resistência
    "INSERT INTO aluno_objetivo (aluno_id, objetivo_id) VALUES (4, 4)", // Ana Costa com Saúde Geral
    "INSERT INTO aluno_objetivo (aluno_id, objetivo_id) VALUES (5, 5)", // Lucas Pereira com Força
    "INSERT INTO aluno_objetivo (aluno_id, objetivo_id) VALUES (6, 6)", // Clara Mendes com Flexibilidade
    "INSERT INTO aluno_objetivo (aluno_id, objetivo_id) VALUES (7, 7)", // Rafael Lima com Condicionamento
  ];

  static const List<String> _insercoesModalidade = [
    "INSERT INTO modalidade (nome) VALUES ('Musculação')",
    "INSERT INTO modalidade (nome) VALUES ('Zumba')",
    "INSERT INTO modalidade (nome) VALUES ('Pilates')",
    "INSERT INTO modalidade (nome) VALUES ('Spinning')",
    "INSERT INTO modalidade (nome) VALUES ('Yoga')",
    "INSERT INTO modalidade (nome) VALUES ('CrossFit')",
    "INSERT INTO modalidade (nome) VALUES ('Funcional')",
  ];

  static const List<String> _insercoesProfessor = [
    "INSERT INTO professor (nome, telefone) VALUES ('Carlos Souza', '41987654321')",
    "INSERT INTO professor (nome, telefone) VALUES ('Ana Lima', '41912345678')",
    "INSERT INTO professor (nome, telefone) VALUES ('Mariana Rocha', '41998765432')",
    "INSERT INTO professor (nome, telefone) VALUES ('Felipe Almeida', '41987651234')",
    "INSERT INTO professor (nome, telefone) VALUES ('Sofia Mendes', '41912348765')",
    "INSERT INTO professor (nome, telefone) VALUES ('Ricardo Silva', '41987654322')",
    "INSERT INTO professor (nome, telefone) VALUES ('Laura Ferreira', '41912345679')",
  ];

  static const List<String> _insercoesProfessorModalidade = [
    "INSERT INTO professor_modalidade (professor_id, modalidade_id) VALUES (1, 1)", // Carlos Souza com Musculação
    "INSERT INTO professor_modalidade (professor_id, modalidade_id) VALUES (2, 2)", // Ana Lima com Zumba
    "INSERT INTO professor_modalidade (professor_id, modalidade_id) VALUES (3, 3)", // Mariana Rocha com Pilates
    "INSERT INTO professor_modalidade (professor_id, modalidade_id) VALUES (4, 4)", // Felipe Almeida com Spinning
    "INSERT INTO professor_modalidade (professor_id, modalidade_id) VALUES (5, 5)", // Sofia Mendes com Yoga
    "INSERT INTO professor_modalidade (professor_id, modalidade_id) VALUES (6, 6)", // Ricardo Silva com CrossFit
    "INSERT INTO professor_modalidade (professor_id, modalidade_id) VALUES (7, 7)", // Laura Ferreira com Funcional
  ];

  static const List<String> _insercoesDieta = [
    "INSERT INTO dieta (nome, descricao, objetivo) VALUES ('Dieta de Corte', 'Dieta para redução de gordura', 'Emagrecimento')",
    "INSERT INTO dieta (nome, descricao, objetivo) VALUES ('Dieta de Bulking', 'Dieta para ganho muscular', 'Hipertrofia')",
    "INSERT INTO dieta (nome, descricao, objetivo) VALUES ('Dieta Cetogênica', 'Alta em gorduras, baixa em carboidratos', 'Emagrecimento')",
    "INSERT INTO dieta (nome, descricao, objetivo) VALUES ('Dieta Balanceada', 'Equilíbrio de nutrientes', 'Saúde Geral')",
    "INSERT INTO dieta (nome, descricao, objetivo) VALUES ('Dieta Low Carb', 'Baixa em carboidratos', 'Emagrecimento')",
    "INSERT INTO dieta (nome, descricao, objetivo) VALUES ('Dieta Proteica', 'Alta em proteínas', 'Hipertrofia')",
    "INSERT INTO dieta (nome, descricao, objetivo) VALUES ('Dieta Mediterrânea', 'Baseada em alimentos naturais', 'Saúde Geral')",
  ];

  static const List<String> _insercoesReceita = [
    "INSERT INTO receita (nome, ingredientes, modo_preparo, valor_nutricional) VALUES ('Salada de Quinoa', '[\"Quinoa\", \"Tomate\", \"Pepino\"]', 'Misturar todos os ingredientes', '{\"Calorias\": 200, \"Proteína\": 8}')",
    "INSERT INTO receita (nome, ingredientes, modo_preparo, valor_nutricional) VALUES ('Shake de Proteína', '[\"Whey\", \"Leite\", \"Banana\"]', 'Bater no liquidificador', '{\"Calorias\": 300, \"Proteína\": 25}')",
    "INSERT INTO receita (nome, ingredientes, modo_preparo, valor_nutricional) VALUES ('Omelete de Claras', '[\"Claras de ovo\", \"Espinafre\", \"Queijo cottage\"]', 'Bater e cozinhar em frigideira', '{\"Calorias\": 150, \"Proteína\": 20}')",
    "INSERT INTO receita (nome, ingredientes, modo_preparo, valor_nutricional) VALUES ('Frango Grelhado', '[\"Peito de frango\", \"Limão\", \"Alho\"]', 'Temperar e grelhar', '{\"Calorias\": 250, \"Proteína\": 30}')",
    "INSERT INTO receita (nome, ingredientes, modo_preparo, valor_nutricional) VALUES ('Batata Doce Assada', '[\"Batata doce\", \"Azeite\", \"Sal\"]', 'Assar no forno', '{\"Calorias\": 180, \"Carboidratos\": 40}')",
    "INSERT INTO receita (nome, ingredientes, modo_preparo, valor_nutricional) VALUES ('Salmão com Brócolis', '[\"Salmão\", \"Brócolis\", \"Azeite\"]', 'Grelhar salmão e cozinhar brócolis', '{\"Calorias\": 350, \"Proteína\": 28}')",
    "INSERT INTO receita (nome, ingredientes, modo_preparo, valor_nutricional) VALUES ('Smoothie de Frutas', '[\"Morango\", \"Banana\", \"Iogurte natural\"]', 'Bater no liquidificador', '{\"Calorias\": 220, \"Carboidratos\": 35}')",
  ];

  static const List<String> _insercoesReceitaDieta = [
    "INSERT INTO receita_dieta (receita_id, dieta_id) VALUES (1, 1)", // Salada de Quinoa com Dieta de Corte
    "INSERT INTO receita_dieta (receita_id, dieta_id) VALUES (2, 2)", // Shake de Proteína com Dieta de Bulking
    "INSERT INTO receita_dieta (receita_id, dieta_id) VALUES (3, 3)", // Omelete de Claras com Dieta Cetogênica
    "INSERT INTO receita_dieta (receita_id, dieta_id) VALUES (4, 4)", // Frango Grelhado com Dieta Balanceada
    "INSERT INTO receita_dieta (receita_id, dieta_id) VALUES (5, 5)", // Batata Doce Assada com Dieta Low Carb
    "INSERT INTO receita_dieta (receita_id, dieta_id) VALUES (6, 6)", // Salmão com Brócolis com Dieta Proteica
    "INSERT INTO receita_dieta (receita_id, dieta_id) VALUES (7, 7)", // Smoothie de Frutas com Dieta Mediterrânea
  ];

  static const List<String> _insercoesTurma = [
    "INSERT INTO turma (nome, horario_inicio, horario_fim, dia_semana) VALUES ('Turma A', '08:00', '09:00', 'Segunda-feira')",
    "INSERT INTO turma (nome, horario_inicio, horario_fim, dia_semana) VALUES ('Turma B', '10:00', '11:00', 'Quarta-feira')",
    "INSERT INTO turma (nome, horario_inicio, horario_fim, dia_semana) VALUES ('Turma C', '18:00', '19:00', 'Terça-feira')",
    "INSERT INTO turma (nome, horario_inicio, horario_fim, dia_semana) VALUES ('Turma D', '07:00', '08:00', 'Quinta-feira')",
    "INSERT INTO turma (nome, horario_inicio, horario_fim, dia_semana) VALUES ('Turma E', '09:00', '10:00', 'Sexta-feira')",
    "INSERT INTO turma (nome, horario_inicio, horario_fim, dia_semana) VALUES ('Turma F', '17:00', '18:00', 'Segunda-feira')",
    "INSERT INTO turma (nome, horario_inicio, horario_fim, dia_semana) VALUES ('Turma G', '19:00', '20:00', 'Quarta-feira')",
  ];

  static const List<String> _insercoesTurmaProfessor = [
    "INSERT INTO turma_professor (turma_id, professor_id) VALUES (1, 1)", // Turma A com Carlos Souza
    "INSERT INTO turma_professor (turma_id, professor_id) VALUES (2, 2)", // Turma B com Ana Lima
    "INSERT INTO turma_professor (turma_id, professor_id) VALUES (3, 3)", // Turma C com Mariana Rocha
    "INSERT INTO turma_professor (turma_id, professor_id) VALUES (4, 4)", // Turma D com Felipe Almeida
    "INSERT INTO turma_professor (turma_id, professor_id) VALUES (5, 5)", // Turma E com Sofia Mendes
    "INSERT INTO turma_professor (turma_id, professor_id) VALUES (6, 6)", // Turma F com Ricardo Silva
    "INSERT INTO turma_professor (turma_id, professor_id) VALUES (7, 7)", // Turma G com Laura Ferreira
  ];

  static const List<String> _insercoesTurmaAluno = [
    "INSERT INTO turma_aluno (turma_id, aluno_id) VALUES (1, 1)", // Turma A com João Silva
    "INSERT INTO turma_aluno (turma_id, aluno_id) VALUES (2, 2)", // Turma B com Maria Oliveira
    "INSERT INTO turma_aluno (turma_id, aluno_id) VALUES (3, 3)", // Turma C com Pedro Santos
    "INSERT INTO turma_aluno (turma_id, aluno_id) VALUES (4, 4)", // Turma D com Ana Costa
    "INSERT INTO turma_aluno (turma_id, aluno_id) VALUES (5, 5)", // Turma E com Lucas Pereira
    "INSERT INTO turma_aluno (turma_id, aluno_id) VALUES (6, 6)", // Turma F com Clara Mendes
    "INSERT INTO turma_aluno (turma_id, aluno_id) VALUES (7, 7)", // Turma G com Rafael Lima
  ];

  static const List<String> _insercoesAgendamento = [
    "INSERT INTO agendamento (dia_semana, horario_inicio, horario_fim, academia_id, academia_nome, turma_id, turma_nome, alunos_ids, alunos_nomes) VALUES ('Segunda-feira', '08:00', '09:00', 1, 'Academia Fit', 1, 'Turma A', '1', 'João Silva')",
    "INSERT INTO agendamento (dia_semana, horario_inicio, horario_fim, academia_id, academia_nome, turma_id, turma_nome, alunos_ids, alunos_nomes) VALUES ('Quarta-feira', '10:00', '11:00', 1, 'Academia Fit', 2, 'Turma B', '2', 'Maria Oliveira')",
    "INSERT INTO agendamento (dia_semana, horario_inicio, horario_fim, academia_id, academia_nome, turma_id, turma_nome, alunos_ids, alunos_nomes) VALUES ('Terça-feira', '18:00', '19:00', 2, 'Academia Power', 3, 'Turma C', '3', 'Pedro Santos')",
    "INSERT INTO agendamento (dia_semana, horario_inicio, horario_fim, academia_id, academia_nome, turma_id, turma_nome, alunos_ids, alunos_nomes) VALUES ('Quinta-feira', '07:00', '08:00', 3, 'Academia Top', 4, 'Turma D', '4', 'Ana Costa')",
    "INSERT INTO agendamento (dia_semana, horario_inicio, horario_fim, academia_id, academia_nome, turma_id, turma_nome, alunos_ids, alunos_nomes) VALUES ('Sexta-feira', '09:00', '10:00', 4, 'Academia Energy', 5, 'Turma E', '5', 'Lucas Pereira')",
    "INSERT INTO agendamento (dia_semana, horario_inicio, horario_fim, academia_id, academia_nome, turma_id, turma_nome, alunos_ids, alunos_nomes) VALUES ('Segunda-feira', '17:00', '18:00', 5, 'Academia Viva', 6, 'Turma F', '6', 'Clara Mendes')",
    "INSERT INTO agendamento (dia_semana, horario_inicio, horario_fim, academia_id, academia_nome, turma_id, turma_nome, alunos_ids, alunos_nomes) VALUES ('Quarta-feira', '19:00', '20:00', 6, 'Academia Move', 7, 'Turma G', '7', 'Rafael Lima')",
  ];

  static const List<String> _insercoesAgendamentoAluno = [
    "INSERT INTO agendamento_aluno (agendamento_id, aluno_id, aluno_nome) VALUES (1, 1, 'João Silva')",
    "INSERT INTO agendamento_aluno (agendamento_id, aluno_id, aluno_nome) VALUES (2, 2, 'Maria Oliveira')",
    "INSERT INTO agendamento_aluno (agendamento_id, aluno_id, aluno_nome) VALUES (3, 3, 'Pedro Santos')",
    "INSERT INTO agendamento_aluno (agendamento_id, aluno_id, aluno_nome) VALUES (4, 4, 'Ana Costa')",
    "INSERT INTO agendamento_aluno (agendamento_id, aluno_id, aluno_nome) VALUES (5, 5, 'Lucas Pereira')",
    "INSERT INTO agendamento_aluno (agendamento_id, aluno_id, aluno_nome) VALUES (6, 6, 'Clara Mendes')",
    "INSERT INTO agendamento_aluno (agendamento_id, aluno_id, aluno_nome) VALUES (7, 7, 'Rafael Lima')",
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
    _criarTabelaAgendamento,
    _criarTabelaAgendamentoAluno,
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
    _insercoesAgendamento,
    _insercoesAgendamentoAluno,
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
