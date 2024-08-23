import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:premiumprice/model/produto.dart';

class ProdutosUsuarioPage extends StatefulWidget {
  const ProdutosUsuarioPage({super.key});

  static const String routeName = '/usuario/produtos';

  @override
  State<ProdutosUsuarioPage> createState() => _ProdutosUsuarioPageState();
}

class _ProdutosUsuarioPageState extends State<ProdutosUsuarioPage> {
  TextEditingController _searchController = TextEditingController();
  List<Produto> _allProdutos = []; // Lista completa de produtos
  List<Produto> _filteredProdutos = []; // Lista filtrada

  @override
  void initState() {
    super.initState();
    // Simular a obtenção de produtos de uma fonte de dados
    _allProdutos = _getProdutos();
    _filteredProdutos = _allProdutos;
    _searchController.addListener(_filterProdutos);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterProdutos() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredProdutos = _allProdutos.where((produto) {
        return produto.nome.toLowerCase().contains(query);
      }).toList();
    });
  }

  List<Produto> _getProdutos() {
    // Simulação de dados
    return [
      Produto(1, 'Banana','', Decimal.parse(4.50.toString()), -25.469680, -49.235317, null, null),
      Produto(2, 'Pão de Forma','', Decimal.parse(4.50.toString()), -25.469780, -49.235417, null, null)
      // Adicione mais produtos conforme necessário
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Meus Produtos'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Buscar por nome',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredProdutos.length,
              itemBuilder: (context, index) {
                final produto = _filteredProdutos[index];
                return ListTile(
                  title: Text(produto.nome),
                  subtitle: Text('Preço: ${produto.preco}'),
                  // Adicione mais informações ou ações, se necessário
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
