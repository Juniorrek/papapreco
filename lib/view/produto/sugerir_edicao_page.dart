import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:papapreco/exception/unauthorized_exception.dart';
import 'package:papapreco/helper/error.dart';
import 'package:papapreco/misc/auth/auth_provider.dart';
import 'package:papapreco/model/produto.dart';
import 'package:papapreco/repositories/produto_repository.dart';
import 'package:papapreco/routes/routes.dart';
import 'package:papapreco/view/produto/filtrar_produtos_page.dart';
import 'package:provider/provider.dart';

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
  final NumberFormat _moneyFormatter = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
    decimalDigits: 2,
  );
  bool _isLoading = false;

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
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;

    if (token == null) {
      showError(context, "Erro", "Token de autenticação não encontrado.");
      return;
    }
    final idUsuario = authProvider.usuario!.id;

    setState(() {
      _isLoading = true;
    });
    try {
      String novoPrecoTexto = _novoPrecoController.text
          .replaceAll('R\$', '')
          .replaceAll('.', '')
          .replaceAll(',', '.')
          .trim();
      _novoProduto!.preco = Decimal.parse(novoPrecoTexto);
      _novoProduto?.dataObservacao = DateTime.now();
      _novoProduto?.id = null;

      if (_descricaoController.text != "") {
        _novoProduto?.descricao = _descricaoController.text;
      }

      _novoProduto!.usuario!.id = idUsuario;

      await _repository.inserir(_novoProduto!, token).then((p) {
        if (mounted) {
          Navigator.pop(context, p);
        }
      });
    } on UnauthorizedException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login expirado, entre novamente!'), behavior: SnackBarBehavior.floating),
      );
      Navigator.pushNamed(context, Routes.login, arguments: <String, Object>{"fromUrl": Routes.sugerirEdicao});
    } catch (exception) {
      showError(context, "Erro inserindo produto", exception.toString());
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Papa Preço"),
          //automaticallyImplyLeading: false,
        ),
        body: SingleChildScrollView(child:  Column(
          children: [
            Padding(
                padding: const EdgeInsets.all(10.0),
                child: _sugerirEdicaoPage())
          ],
        )));
  }

  Row _sugerirEdicaoPage() {
    return Row(
      children: [
        Expanded(
            child: Column(
          children: [
            Text(widget.produto.nome,
                style: const TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                )),
            Text(widget.produto.localizacao.descricao ?? "",
                style: const TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.normal,
                )),
            Text(_moneyFormatter.format(widget.produto.preco.toDouble()),
                style: const TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.normal,
                )),
            const SizedBox(height: 20),
            const Text("Novo Preço",
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
            Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        MoneyInputFormatter(),
                      ],
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(), /*labelText: 'Produto:'*/
                      ),
                      controller: _novoPrecoController,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Campo não pode ser vazio';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Descrição",
                            style: TextStyle(
                                fontSize: 20.0, fontWeight: FontWeight.bold)),
                        Text(" (vazio mantém a atual)",
                            style: TextStyle(
                                fontSize: 18.0, fontWeight: FontWeight.normal))
                      ],
                    ),
                    TextFormField(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(), /*labelText: 'Produto:'*/
                      ),
                      controller: _descricaoController,
                    ),
                    const SizedBox(height: 20),
                    Row(children: [
                      Expanded(
                          child: OutlinedButton(
                        onPressed: _isLoading
                            ? null
                            : () {
                                if (_formKey.currentState!.validate()) {
                                  _sugerirEdicao();
                                }
                              },
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.0,
                                ),
                              )
                            : const Text('Editar'),
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
