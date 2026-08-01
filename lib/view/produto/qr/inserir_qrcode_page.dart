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

class InserirQrcodePage extends StatefulWidget {

  const InserirQrcodePage(
      {super.key});

  static const String routeName = '/digitalizar/inserir_qr';

  @override
  State<StatefulWidget> createState() => _CadastrarProdutoPageState();
}

class _CadastrarProdutoPageState extends State<InserirQrcodePage> {
  /// NFC-e URL used to pre-fill the field during development, to avoid having
  /// to scan a real QR code on every run:
  ///
  /// ```
  /// flutter run --dart-define=DEV_QRCODE_URL=https://www.fazenda.pr.gov.br/nfce/qrcode?p=...
  /// ```
  ///
  /// Empty by default, so the normal behaviour is to pre-fill nothing.
  static const String _devQrcodeUrl = String.fromEnvironment('DEV_QRCODE_URL');

  final _formKey = GlobalKey<FormState>();
  final _qrCodeController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (_devQrcodeUrl.isNotEmpty) {
      _qrCodeController.text = _devQrcodeUrl;
    }
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
                padding: const EdgeInsets.all(10.0), child: _inserirQrcodePage())
          ],
        ));
  }

  Row _inserirQrcodePage() {
    return Row(
      children: [
        Expanded(
            child: Column(
          children: [
            Form(
                key: _formKey,
                child: Column(
                  children: [
                    const Text("URL QR Code",
                        style: TextStyle(
                            fontSize: 20.0, fontWeight: FontWeight.bold)),
                    TextFormField(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(), /*labelText: 'Produto:'*/
                      ),
                      controller: _qrCodeController,
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
                        onPressed:  (){
                                if (_formKey.currentState!.validate()) {
                                  Navigator.pushNamed(
                            context, Routes.confirmarDigitalizacao,
                            arguments: <String, String>{
                              "urlQr": _qrCodeController.text
                                  //"https://www.fazenda.pr.gov.br/nfce/qrcode?p=41240778116670001994650110000706859008861151|2|1|19|191.37|36424547706431514c323277326e5933526a4272497a356d31746b3d|1|1E71BE91A8A04C4D104650E2FB2AB5B14CDB91E8"
                            });
                                }
                              },
                        child: const Text('Cadastrar'),
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
