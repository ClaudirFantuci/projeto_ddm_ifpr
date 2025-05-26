import 'package:flutter/material.dart';

class WidgetCadastroAlunos extends StatefulWidget {
  const WidgetCadastroAlunos({super.key});

  @override
  _WidgetCadastroAlunosState createState() => _WidgetCadastroAlunosState();
}

class _WidgetCadastroAlunosState extends State<WidgetCadastroAlunos> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Cadastro de Aluno'),
        backgroundColor: Colors.amber,
        foregroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            color: Colors.black,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      style: const TextStyle(color: Colors.amber),
                      decoration: const InputDecoration(
                        labelText: 'Nome Completo',
                        labelStyle: TextStyle(color: Colors.amber),
                        hintText: 'Insira o nome completo do aluno',
                        hintStyle: TextStyle(color: Colors.amberAccent),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.amber),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.amber),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      style: const TextStyle(color: Colors.amber),
                      decoration: const InputDecoration(
                        labelText: 'telefone',
                        labelStyle: TextStyle(color: Colors.amber),
                        hintText: 'Insira o telefone do aluno',
                        hintStyle: TextStyle(color: Colors.amberAccent),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.amber),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.amber),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      style: const TextStyle(color: Colors.amber),
                      decoration: const InputDecoration(
                        labelText: 'E-mail',
                        labelStyle: TextStyle(color: Colors.amber),
                        hintText: 'Insira o e-mail do aluno',
                        hintStyle: TextStyle(color: Colors.amberAccent),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.amber),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.amber),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.black,
                      ),
                      onPressed: () {},
                      child: const Text('Enviar'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
