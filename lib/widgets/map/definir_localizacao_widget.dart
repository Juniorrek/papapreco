import 'package:flutter/material.dart';
import 'package:location_picker_flutter_map/location_picker_flutter_map.dart';
import 'package:papapreco/routes/routes.dart';
import 'package:papapreco/misc/map/map_lib.dart' as map_lib;

class DefinirLocalizacaoWidget extends StatefulWidget {
  const DefinirLocalizacaoWidget(
      {super.key,
      required this.onData,
      required this.latitude,
      required this.longitude,
      required this.localizacaoString,
      this.distancia});

  final Function(double, double, String) onData;
  final double latitude;
  final double longitude;
  final String localizacaoString;
  final double? distancia;

  @override
  State<DefinirLocalizacaoWidget> createState() =>
      _DefinirLocaliacaoWidgetState();
}

class _DefinirLocaliacaoWidgetState extends State<DefinirLocalizacaoWidget> {
  bool _isLoading = false;
  bool _isBuscando = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _setLocalizacaoAtualString(double latitude, double longitude) async {
    setState(() {
      _isBuscando = true;
    });
    
    String reverseGeocodingString =
        await map_lib.reverseGeocodingString(latitude, longitude);

    setState(() {
      _isBuscando = false;
    });

    widget.onData(latitude, longitude, reverseGeocodingString);
  }

  Future<void> _navigateDefinirLocalizacaoPage(context) async {
    final LatLong? result = await Navigator.pushNamed(
        context, Routes.definirLocalizacao,
        arguments: <String, Object>{
          "latitude": widget.latitude,
          "longitude": widget.longitude,
        }) as LatLong?;

    //clicou em retornar
    if (result == null) return;

    // When a BuildContext is used from a StatefulWidget, the mounted property
    // must be checked after an asynchronous gap.
    if (!context.mounted) return;

    await _setLocalizacaoAtualString(result.latitude, result.longitude);
  }

  @override
  Widget build(BuildContext context) {
    // Verifica se o estado precisa ser atualizado quando o widget é reconstruído
    if (!widget.localizacaoString.isEmpty && !_isBuscando) {
      setState(() {
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = true;
      });
    }

    return TextButton(
        onPressed: () {
          _navigateDefinirLocalizacaoPage(context);
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _text(),
            const Icon(Icons.arrow_drop_down)
          ],
        )
      );
  }

  Widget _text() {
    if (!_isLoading) {
      return Flexible(
      child:Text(widget.localizacaoString +
                (widget.distancia != null ? ' (${widget.distancia?.toInt().toString()}km)' : ''),
                style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.normal)),
                );
    } else {
      return const SizedBox(
            width: 15,  // Largura desejada
            height: 15, // Altura desejada
            child: CircularProgressIndicator(),
          );
    }
  }
}
