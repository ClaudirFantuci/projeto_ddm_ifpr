import 'package:flutter/material.dart';
import 'package:projeto_ddm_ifpr/banco/sqlite/dao/dao_modalidade.dart';
import 'package:projeto_ddm_ifpr/dto/dto_modalidade.dart';

class WidgetCadastroModalidades extends StatefulWidget {
  final DtoModalidade? modalidade;

  const WidgetCadastroModalidades({super.key, this.modalidade});

  @override
  State<WidgetCadastroModalidades> createState() =>
      _WidgetCadastroModalidadesState();
}

class _WidgetCadastroModalidadesState extends State<WidgetCadastroModalidades> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _dao = DAOModalidade();

  @override
  void initState() {
    super.initState();
    if (widget.modalidade != null) {
      _nomeController.text = widget.modalidade!.nome;
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (_formKey.currentState!.validate()) {
      final modalidade = DtoModalidade(
        id: widget.modalidade?.id,
        nome: _nomeController.text,
      );

      try {
        await _dao.salvar(modalidade);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.modalidade == null
                  ? 'Modalidade cadastrada com sucesso!'
                  : 'Modalidade atualizada com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true); // Retorna true para indicar sucesso
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao salvar modalidade: $e'),
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
          widget.modalidade == null
              ? 'Cadastro de Modalidades'
              : 'Editar Modalidade',
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
                  labelText: 'Nome da Modalidade',
                  hintText: 'Insira o nome da modalidade',
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
                    return 'O nome da modalidade é obrigatório';
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
                child: Text(widget.modalidade == null ? 'Salvar' : 'Atualizar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
