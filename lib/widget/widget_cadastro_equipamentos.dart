import 'package:flutter/material.dart';
import 'package:projeto_ddm_ifpr/banco/sqlite/dao/dao_equipamento.dart';
import 'package:projeto_ddm_ifpr/dto/dto_equipamento.dart';
import 'package:projeto_ddm_ifpr/configuracao/rotas.dart';

class WidgetCadastroEquipamentos extends StatefulWidget {
  final DTOEquipamento? equipamento;

  const WidgetCadastroEquipamentos({super.key, this.equipamento});

  @override
  State<WidgetCadastroEquipamentos> createState() =>
      _WidgetCadastroEquipamentosState();
}

class _WidgetCadastroEquipamentosState
    extends State<WidgetCadastroEquipamentos> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _dao = DAOEquipamento();

  @override
  void initState() {
    super.initState();
    if (widget.equipamento != null) {
      _nomeController.text = widget.equipamento!.nome;
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (_formKey.currentState!.validate()) {
      final equipamento = DTOEquipamento(
        id: widget.equipamento?.id,
        nome: _nomeController.text,
      );

      try {
        final result = await _dao.salvar(equipamento);
        print(
            'Salvar equipamento: ${equipamento.nome}, ID: ${equipamento.id}, Resultado: $result');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.equipamento == null
                  ? 'Equipamento cadastrado com sucesso!'
                  : 'Equipamento atualizado com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true); // Return true to trigger list refresh
        }
      } catch (e) {
        print('Erro ao salvar equipamento: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao salvar equipamento: $e'),
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
          widget.equipamento == null
              ? 'Cadastro de Equipamentos'
              : 'Editar Equipamento',
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
                  labelText: 'Nome do Equipamento',
                  hintText: 'Insira o nome do equipamento',
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
                    return 'Por favor, insira o nome do equipamento';
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
                child:
                    Text(widget.equipamento == null ? 'Salvar' : 'Atualizar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
