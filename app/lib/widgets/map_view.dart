import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../core/constants/app_constants.dart';
import '../core/theme/app_colors.dart';
import '../models/suggestion.dart';

/// Zone carte — carte réelle OpenStreetMap via `flutter_map` (aucune clé API).
///
/// Affiche les suggestions, la position de l'utilisateur, et recentre la carte
/// sur l'épingle sélectionnée (ou sur l'utilisateur à défaut). L'interface
/// publique reste minimale : `map_screen.dart` ne dépend que de ces champs.
class MapView extends StatefulWidget {
  const MapView({
    super.key,
    required this.suggestions,
    this.selectedId,
    this.onPinTap,
    this.userLocation,
  });

  final List<Suggestion> suggestions;
  final String? selectedId;
  final ValueChanged<Suggestion>? onPinTap;
  final LatLng? userLocation;

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  final MapController _mapController = MapController();
  bool _mapReady = false;

  @override
  void didUpdateWidget(covariant MapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedId != oldWidget.selectedId) {
      _centerOnSelected();
    } else if (widget.userLocation != oldWidget.userLocation &&
        widget.selectedId == null) {
      _centerOnUser();
    }
  }

  Suggestion? _findSelected() {
    for (final s in widget.suggestions) {
      if (s.id == widget.selectedId) return s;
    }
    return null;
  }

  void _centerOnSelected() {
    if (!_mapReady) return;
    final selected = _findSelected();
    if (selected == null) return;
    _moveTo(LatLng(selected.latitude, selected.longitude), 14);
  }

  void _centerOnUser() {
    final loc = widget.userLocation;
    if (!_mapReady || loc == null) return;
    _moveTo(loc, 14);
  }

  void _moveTo(LatLng target, double zoom) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _mapController.move(target, zoom);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: widget.userLocation ??
              LatLng(AppGeo.defaultLat, AppGeo.defaultLng),
          initialZoom: 12,
          onMapReady: () {
            _mapReady = true;
            if (widget.selectedId != null) {
              _centerOnSelected();
            } else {
              _centerOnUser();
            }
          },
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.goodmaps_app',
          ),
          MarkerLayer(markers: _buildMarkers()),
        ],
      ),
    );
  }

  List<Marker> _buildMarkers() {
    final markers = <Marker>[];

    final loc = widget.userLocation;
    if (loc != null) {
      markers.add(
        Marker(
          point: loc,
          width: 24,
          height: 24,
          child: const Icon(Icons.my_location, color: Colors.blue, size: 24),
        ),
      );
    }

    for (final s in widget.suggestions) {
      final selected = s.id == widget.selectedId;
      markers.add(
        Marker(
          point: LatLng(s.latitude, s.longitude),
          width: selected ? 56 : 40,
          height: selected ? 56 : 40,
          child: GestureDetector(
            onTap: () => widget.onPinTap?.call(s),
            child: Icon(
              Icons.location_on,
              color: AppColors.coral,
              size: selected ? 52 : 36,
            ),
          ),
        ),
      );
    }
    return markers;
  }
}
