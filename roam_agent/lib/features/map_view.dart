import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';

import '../core/l10n.dart';
import '../core/theme.dart';
import '../data/catalog.dart';
import '../domain/models.dart';

class JourneyMap extends StatelessWidget {
  const JourneyMap({
    super.key,
    required this.catalog,
    required this.itinerary,
    required this.s,
    this.vehicle,
    this.highlightLeg = 0,
    this.height = 220,
  });

  final Catalog catalog;
  final Itinerary itinerary;
  final S s;
  final LatLng? vehicle;
  final int highlightLeg;
  final double height;

  @override
  Widget build(BuildContext context) {
    final pts = itinerary.geometry;
    final center = pts.isEmpty ? const LatLng(16.9, 80.8) : pts[pts.length ~/ 2];
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: height,
        child: Stack(
          children: [
            FlutterMap(
              options: MapOptions(initialCenter: center, initialZoom: 6.4),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'roam_agent',
                ),
                PolylineLayer(
                  polylines: [
                    for (var i = 0; i < itinerary.legs.length; i++)
                      Polyline(
                        points: itinerary.legs[i].polyline,
                        color: i == highlightLeg ? AppColors.sky : AppColors.navySoft.withOpacity(0.5),
                        strokeWidth: i == highlightLeg ? 5 : 3,
                      ),
                  ],
                ),
                MarkerLayer(
                  markers: [
                    for (final leg in itinerary.legs) ...[
                      _pin(catalog.stops[leg.originStopId]!.coord, AppColors.sky),
                      _pin(catalog.stops[leg.destinationStopId]!.coord, AppColors.navy),
                    ],
                    if (vehicle != null)
                      Marker(
                        point: vehicle!,
                        width: 28,
                        height: 28,
                        child: const Icon(Icons.directions_bus, color: AppColors.ember),
                      ),
                  ],
                ),
              ],
            ),
            Positioned(
              left: 8,
              bottom: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                color: Colors.white.withOpacity(0.92),
                child: Text(
                  '${s.simulatedGps} · OSM tiles',
                  style: GoogleFonts.inter(fontSize: 10, color: AppColors.muted),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Marker _pin(LatLng p, Color c) => Marker(
        point: p,
        width: 16,
        height: 16,
        child: Container(
          decoration: BoxDecoration(color: c, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
        ),
      );
}
