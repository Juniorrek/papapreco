import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:location_picker_flutter_map/location_picker_flutter_map.dart';
import 'package:papapreco/exception/unauthorized_exception.dart';
import 'package:papapreco/helper/error.dart';
import 'package:papapreco/misc/auth/auth_provider.dart';
import 'package:papapreco/misc/auth/map_provider.dart';
import 'package:papapreco/model/localizacao.dart';
import 'package:papapreco/model/produto.dart';
import 'package:papapreco/repositories/produto_repository.dart';
import 'package:papapreco/routes/routes.dart';
import 'package:papapreco/view/produto/filtrar_produtos_page.dart';
import 'package:papapreco/widgets/map/definir_localizacao_widget.dart';
import 'package:provider/provider.dart';

class EditarDigitalizacaoPage extends StatefulWidget {
  final Produto produto;

  const EditarDigitalizacaoPage({super.key, required this.produto});

  static const String routeName = '/digitalizar/confirmar/editar';

  @override
  State<StatefulWidget> createState() => _CadastrarProdutoPageState();
}

class _CadastrarProdutoPageState extends State<EditarDigitalizacaoPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeProdutoController = TextEditingController();
  final _descricaoProdutoController = TextEditingController();

  @override
  void initState() {
    super.initState();

    setState(() {
      _nomeProdutoController.text = widget.produto.nome;
      _descricaoProdutoController.text = widget.produto.descricao ?? '';
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text("Papa Preço"),
          //automaticallyImplyLeading: false,
        ),
        body: Column(
          children: [
            Padding(
                padding: const EdgeInsets.all(10.0),
                child: _editarDigitalizacaoPage())
          ],
        ));
  }

  Row _editarDigitalizacaoPage() {
    return Row(
      children: [
        Expanded(
            child: Column(
          children: [
            Form(
                key: _formKey,
                child: Column(
                  children: [
                    const Text("Nome do produto",
                        style: TextStyle(
                            fontSize: 20.0, fontWeight: FontWeight.bold)),
                    TextFormField(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(), /*labelText: 'Produto:'*/
                      ),
                      controller: _nomeProdutoController,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Campo não pode ser vazio';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    const Text("Descrição do produto",
                        style: TextStyle(
                            fontSize: 20.0, fontWeight: FontWeight.bold)),
                    TextFormField(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      controller: _descricaoProdutoController,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Campo não pode ser vazio';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    Row(children: [
                      Expanded(
                          child: OutlinedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            Navigator.pop(context, <String, Object?>{
                              "nome": _nomeProdutoController.text,
                              "descricao": _descricaoProdutoController.text
                            });
                          }
                        },
                        child: const Text('Editar'),
                      ))
                    ]),
                  ],
                )),
          ],
        ))
      ],
    );
  }
}
