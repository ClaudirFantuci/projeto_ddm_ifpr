import 'package:flutter/material.dart';
import 'package:projeto_ddm_ifpr/banco/sqlite/dao/dao_objetivo.dart';
import 'package:projeto_ddm_ifpr/dto/dto_objetivo.dart';

class WidgetCadastroObjetivos extends StatefulWidget {
  final DTOObjetivo? objetivo;

  const WidgetCadastroObjetivos({super.key, this.objetivo});

  @override
  State<WidgetCadastroObjetivos> createState() =>
      _WidgetCadastroObjetivosState();
}

class _WidgetCadastroObjetivosState extends State<WidgetCadastroObjetivos> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _dao = DAOObjetivo();

  @override
  void initState() {
    super.initState();
    if (widget.objetivo != null) {
      _nomeController.text = widget.objetivo!.nome;
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (_formKey.currentState!.validate()) {
      final objetivo = DTOObjetivo(
        id: widget.objetivo?.id,
        nome: _nomeController.text,
      );

      try {
        await _dao.salvar(objetivo);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.objetivo == null
                  ? 'Objetivo cadastrado com sucesso!'
                  : 'Objetivo atualizado com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao salvar objetivo: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: Text(
          widget.objetivo == null ? 'Cadastro de Objetivos' : 'Editar Objetivo',
          style: const TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome do Objetivo',
                  hintText: 'Insira o nome do objetivo',
                  labelStyle: TextStyle(color: Colors.amber),
                  hintStyle: TextStyle(color: Colors.amber),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.amber),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.amber),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'O nome do objetivo é obrigatório';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                ),
                onPressed: _salvar,
                child: Text(widget.objetivo == null ? 'Salvar' : 'Atualizar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
