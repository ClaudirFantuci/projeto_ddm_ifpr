final _academia = '''
CREATE TABLE academia (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nome TEXT NOT NULL,
    endereco TEXT NOT NULL,
    telefone_contato TEXT NOT NULL CHECK(length(telefone_contato) <= 15),
    cidade TEXT NOT NULL,
    ativo INTEGER NOT NULL DEFAULT 1
);
''';
final criarTabelas = [_academia];

final insertAcademias = [
  '''
INSERT INTO academia (nome, endereco, telefone_contato, cidade, ativo) VALUES
    ('FitLife', 'Rua Principal, 123', '(44) 99999-1234', 'Paranavaí', 1),
    ('PowerGym', 'Av. Central, 456', '(44) 98888-5678', 'Maringá', 1),
    ('Vida Saudável', 'Rua das Flores, 789', '(44) 97777-9012', 'Cianorte', 0);
'''
];
