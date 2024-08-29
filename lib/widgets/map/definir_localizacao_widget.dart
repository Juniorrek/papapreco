import 'package:flutter/material.dart';
import 'package:location_picker_flutter_map/location_picker_flutter_map.dart';
import 'package:premiumprice/routes/routes.dart';
import 'package:premiumprice/misc/map/map_lib.dart' as map_lib;

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

  @override
  void initState() {
    super.initState();
  }

  Future<void> _setLocalizacaoAtualString(double latitude, double longitude) async {
    String reverseGeocodingString =
        await map_lib.reverseGeocodingString(latitude, longitude);

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

  void _updateLoadingState() {
    setState(() {
      _isLoading = widget.localizacaoString.isEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Verifica se o estado precisa ser atualizado quando o widget é reconstruído
    if (widget.localizacaoString.isEmpty != _isLoading) {
      _updateLoadingState();
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
                (widget.distancia != null ? ' (${widget.distancia?.toInt().toString()}km)' : '')));
    } else {
      return const SizedBox(
            width: 15,  // Largura desejada
            height: 15, // Altura desejada
            child: CircularProgressIndicator(),
          );
    }
  }
}
