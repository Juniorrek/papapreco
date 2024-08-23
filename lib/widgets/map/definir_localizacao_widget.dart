import 'package:flutter/material.dart';
import 'package:location_picker_flutter_map/location_picker_flutter_map.dart';
import 'package:premiumprice/routes/routes.dart';
import 'package:premiumprice/misc/map/map_lib.dart' as map_lib;

class DefinirLocaliacaoWidget extends StatefulWidget {
  const DefinirLocaliacaoWidget(
      {super.key,
      required this.onData,
      required this.latitude,
      required this.longitude,
      this.distancia});

  final Function(double, double) onData;
  final double latitude;
  final double longitude;
  final double? distancia;

  @override
  State<DefinirLocaliacaoWidget> createState() =>
      _DefinirLocaliacaoWidgetState();
}

class _DefinirLocaliacaoWidgetState extends State<DefinirLocaliacaoWidget> {
  String _localizacaoString = '';

  @override
  void initState() {
    super.initState();

    _setLocalizacaoAtualString(widget.latitude, widget.longitude);
  }

  Future<void> _setLocalizacaoAtualString(double latitude, double longitude) async {
    String reverseGeocodingString =
        await map_lib.reverseGeocodingString(latitude, longitude);
    setState(() {
      _localizacaoString = reverseGeocodingString;
    });
  }

  Future<void> _navigateDefinirLocalizacaoPage(context) async {
    final LatLong result = await Navigator.pushNamed(
        context, Routes.definirLocalizacao,
        arguments: <String, Object>{
          "latitude": widget.latitude,
          "longitude": widget.longitude,
        }) as LatLong;

    // When a BuildContext is used from a StatefulWidget, the mounted property
    // must be checked after an asynchronous gap.
    if (!context.mounted) return;

    widget.onData(result.latitude, result.longitude);

    await _setLocalizacaoAtualString(result.latitude, result.longitude);
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
        onPressed: () {
          _navigateDefinirLocalizacaoPage(context);
        },
        child: Flexible(
            child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_localizacaoString +
                (widget.distancia != null ? ' (${widget.distancia?.toInt().toString()}km)' : '')),
            const Icon(Icons.arrow_drop_down)
          ],
        ))
      );
  }
}
