import 'package:flutter/material.dart';
import 'package:premiumprice/view/produto/listar_produtos_page.dart';

import 'routes/routes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Premium Price',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Premium Price'),
      routes: {
        Routes.home: (context) => const MyHomePage(title: 'Premium Price'),
        Routes.listarProdutos: (context) => const ListarProdutosPage()
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  static const String routeName = '/home';

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _formKey = GlobalKey<FormState>();

  final _nomeProdutoController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Form(
          key: _formKey,
          child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Image(
              image: AssetImage('assets/images/pp.png'),
              height: 150,
            ),
            const Text("Premium Price"),
            TextFormField(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Produto:'
              ),
              controller: _nomeProdutoController,
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Campo não pode ser vazio';
                }
                return null;
              },
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  Navigator.pushNamed(
                    context, 
                    ListarProdutosPage.routeName,
                    arguments: <String, String>{
                      "nomeProduto": _nomeProdutoController.text
                    }
                  );
                }
              },
              child: Text('Pesquisar'),
            )
          ],
        ))
        ,
      ),
    );
  }
}
