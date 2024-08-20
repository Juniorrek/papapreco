import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:premiumprice/helper/error.dart';
import 'package:premiumprice/model/produto.dart';
import 'package:premiumprice/repositories/produto_repository.dart';

class SugerirEdicaoPage extends StatefulWidget {
  final Produto produto;

  const SugerirEdicaoPage({super.key, required this.produto});

  static const String routeName = '/produtos/sugerir';

  @override
  State<StatefulWidget> createState() => _SugerirEdicaoPageState();
}

class _SugerirEdicaoPageState extends State<SugerirEdicaoPage> {
  final _formKey = GlobalKey<FormState>();
  final _novoPrecoController = TextEditingController();
  final _descricaoController = TextEditingController();
  final ProdutoRepository _repository = ProdutoRepository();
  Produto? _novoProduto;


  @override
  void initState() {
    super.initState();

    setState(() {
      _novoProduto = widget.produto;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _sugerirEdicao() async {
    try {
      _novoProduto!.preco = Decimal.parse(_novoPrecoController.text);
      _novoProduto?.id = null;

      if (_descricaoController.text != null && _descricaoController.text != "") {
        _novoProduto?.descricao = _descricaoController.text;
      }

      _repository.inserir(_novoProduto!).then((p) {
        Navigator.pop(context, p);
      });
    } catch (exception) {
      showError(context, "Erro inserindo produto", exception.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Premium Price"),
          //automaticallyImplyLeading: false,
        ),
        body: Column(
          children: [
            _sugerirEdicaoPage()
          ],
        ));
  }

  Row _sugerirEdicaoPage() {
    return Row(
      children: [
        Expanded(
            child: Column(
          children: [
            Text(widget.produto.nome),
            Text(widget.produto.localizacao ?? ""),
            Text('R\$${widget.produto.preco}'),
            const Text("Novo Preço"),
            Form(
                key: _formKey,
                child: Column(
                  children: [
                    Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 8),
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            border:
                                OutlineInputBorder(), /*labelText: 'Produto:'*/
                          ),
                          controller: _novoPrecoController,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Campo não pode ser vazio';
                            }
                            return null;
                          },
                        )),
                    const Text("Descrição (vazio mantém a atual)"),
                    Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 8),
                        child: TextFormField(
                          decoration: const InputDecoration(
                            border:
                                OutlineInputBorder(), /*labelText: 'Produto:'*/
                          ),
                          controller: _descricaoController,
                        )),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _sugerirEdicao();
                        }
                      },
                      child: const Text('Editar'),
                    ),
                  ],
                )),
          ],
        ))
      ],
    );
  }
}
