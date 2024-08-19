import 'package:flutter/material.dart';
import 'package:premiumprice/model/produto.dart';
import 'package:premiumprice/routes/routes.dart';

class DetalheProdutoWidget extends StatelessWidget {
  const DetalheProdutoWidget({
    super.key,
    required this.produto,
  });

  final Produto produto;

  Widget _buildImage() {
    return Container(
      margin: const EdgeInsets.all(8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(
          'https://docs.flutter.dev/cookbook'
          '/img-files/effects/split-check/Food1.jpg',
          fit: BoxFit.cover,
          width: 100,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        //_buildImage(),
        Expanded(
            child: Column(
          children: [
            Text(produto.nome),
            Text(produto.localizacao ?? ""),
            Text('R\$${produto.preco}'),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: const Icon(Icons.pin_drop),
                  onPressed: () {
                    Navigator.pushNamed(context, Routes.listarProdutosMapa,
                        arguments: <String, Object>{
                          "produtos": List.filled(1, produto),
                          "fromDetail": true
                          });
                  },
                ),
                Icon(Icons.edit)
              ],
            )
          ],
        ))
      ],
    );
  }
}
