import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../models/order_model.dart';
import '../providers/ride_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/services/location_service.dart';

class RideProgressScreen extends StatefulWidget {
  final Order order;

  const RideProgressScreen({super.key, required this.order});

  @override
  State<RideProgressScreen> createState() => _RideProgressScreenState();
}

class _RideProgressScreenState extends State<RideProgressScreen> {
  final MapController _mapController = MapController();
  final LocationService _location = LocationService.instance;
  late LatLng _currentPos;
  Timer? _locationTimer;

  @override
  void initState() {
    super.initState();
    _currentPos = _location.currentPosition;
    _startTracking();
  }

  void _startTracking() {
    _locationTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) return;
      final newPos = _location.currentPosition;
      setState(() => _currentPos = newPos);
      context.read<RideProvider>().updateLocation(newPos);
    });
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RideProvider>(
      builder: (context, ride, _) {
        return Scaffold(
          backgroundColor: const Color(0xFF1A1A2E),
          body: Stack(
            children: [
              _buildMap(ride),
              _buildFloatingInfo(ride),
              Positioned(
                left: 16,
                right: 16,
                bottom: 0,
                child: _buildBottomPanel(ride),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMap(RideProvider ride) {
    final points = _buildRoutePoints(ride);

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: _currentPos,
        initialZoom: 16,
        maxZoom: 18,
        minZoom: 14,
      ),
      children: [
        TileLayer(
          retinaMode: MediaQuery.of(context).devicePixelRatio > 1.0,
          urlTemplate: 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
          subdomains: const ['a', 'b', 'c', 'd'],
          userAgentPackageName: 'com.novataxi.driver',
        ),
        if (points.isNotEmpty)
          PolylineLayer(
            polylines: [
              Polyline(
                points: points,
                color: ride.status == RideStatus.inTrip
                    ? NovaColors.amber
                    : NovaColors.online,
                strokeWidth: 5,
              ),
            ],
          ),
        MarkerLayer(markers: [
          Marker(
            point: _currentPos,
            width: 56,
            height: 56,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF3B82F6).withValues(alpha: 0.5),
                    blurRadius: 16,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(Icons.local_taxi_rounded, color: Colors.white, size: 26),
            ),
          ),
          if (ride.pickupLocation != null && ride.status == RideStatus.navigatingToPickup)
            Marker(
              point: ride.pickupLocation!,
              width: 48,
              height: 48,
              child: Container(
                decoration: BoxDecoration(
                  color: NovaColors.online,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: NovaColors.online.withValues(alpha: 0.5),
                      blurRadius: 14,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(Icons.person, color: Colors.white, size: 24),
              ),
            ),
          if (ride.destinationLocation != null && ride.status == RideStatus.inTrip)
            Marker(
              point: ride.destinationLocation!,
              width: 48,
              height: 48,
              child: Container(
                decoration: BoxDecoration(
                  color: NovaColors.amber,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: NovaColors.amber.withValues(alpha: 0.5),
                      blurRadius: 14,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(Icons.place_rounded, color: Colors.white, size: 24),
              ),
            ),
        ]),
      ],
    );
  }

  List<LatLng> _buildRoutePoints(RideProvider ride) {
    final dest = ride.status == RideStatus.inTrip
        ? ride.destinationLocation
        : ride.pickupLocation;
    if (dest == null) return [];

    return [
      _currentPos,
      LatLng(
        (_currentPos.latitude + dest.latitude) / 2 + 0.002,
        (_currentPos.longitude + dest.longitude) / 2 - 0.001,
      ),
      dest,
    ];
  }

  Widget _buildFloatingInfo(RideProvider ride) {
    final topPad = MediaQuery.paddingOf(context).top;
    final isPickup = ride.status == RideStatus.navigatingToPickup ||
        ride.status == RideStatus.arrivedAtPickup;

    return Positioned(
      top: topPad + 12,
      left: 16,
      right: 16,
      child: Column(
        children: [
          Row(
            children: [
              _GlassBackButton(
                onTap: () => Navigator.pop(context),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: NovaColors.online,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'GPS faol',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: (isPickup ? NovaColors.online : NovaColors.amber)
                                .withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            isPickup ? Icons.navigation_rounded : Icons.place_rounded,
                            color: isPickup ? NovaColors.online : NovaColors.amber,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            isPickup
                                ? 'Mijozni olib ketishga boring'
                                : 'Mijozni manzilga olib boring',
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _InfoTile(
                          icon: Icons.straighten_rounded,
                          value: isPickup
                              ? '${ride.distanceToPickup.toStringAsFixed(1)} km'
                              : '${ride.tripDistance.toStringAsFixed(1)} km',
                          color: const Color(0xFF3B82F6),
                        ),
                        const SizedBox(width: 8),
                        _InfoTile(
                          icon: Icons.access_time_rounded,
                          value: isPickup
                              ? '${ride.etaToPickup} daqiqa'
                              : ride.formattedTripDuration,
                          color: NovaColors.amber,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomPanel(RideProvider ride) {
    final isPickup = ride.status == RideStatus.navigatingToPickup;
    final isArrived = ride.status == RideStatus.arrivedAtPickup;
    final isInTrip = ride.status == RideStatus.inTrip;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.95),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 30,
                offset: const Offset(0, -8),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(height: 16),

                if (isPickup) _buildPickupAddress(),
                if (isArrived || isInTrip) _buildDestinationAddress(),

                const SizedBox(height: 14),

                if (isPickup) ...[
                  _RideActionButton(
                    label: 'MIJOZGA YETIB KELDIM',
                    icon: Icons.check_circle_rounded,
                    color: NovaColors.amber,
                    shadowColor: NovaColors.amber.withValues(alpha: 0.5),
                    onTap: () => ride.driverArrived(),
                  ),
                ] else if (isArrived) ...[
                  _RideActionButton(
                    label: 'SAFARNI BOSHLASH',
                    icon: Icons.play_arrow_rounded,
                    color: NovaColors.online,
                    shadowColor: NovaColors.online.withValues(alpha: 0.5),
                    onTap: () => ride.startTrip(),
                  ),
                ] else if (isInTrip) ...[
                  _RideActionButton(
                    label: 'SAFARNI TUGATISH',
                    icon: Icons.stop_circle_rounded,
                    color: NovaColors.danger,
                    shadowColor: NovaColors.danger.withValues(alpha: 0.5),
                    onTap: () => _showEndTripDialog(ride),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPickupAddress() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on_rounded, color: Color(0xFF3B82F6), size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              widget.order.pickupAddress,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: NovaColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDestinationAddress() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: NovaColors.amberLight,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.place_rounded, color: NovaColors.amberDeep, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              widget.order.destinationAddress,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: NovaColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _showEndTripDialog(RideProvider ride) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: const Text(
          'Safarni tugatish',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
        content: Text(
          'Narxi: ${widget.order.formattedPrice}\nSafar vaqti: ${ride.formattedTripDuration}\n\nSafarni tugatilganini tasdiqlaysizmi?',
          style: const TextStyle(fontSize: 16, height: 1.4),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Bekor',
                style: TextStyle(fontSize: 16, color: NovaColors.textSecondary, fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ride.endTrip();
              _showTripCompleteDialog();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: NovaColors.online,
              foregroundColor: Colors.white,
              minimumSize: const Size(0, 48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Ha, tugatish',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  void _showTripCompleteDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: NovaColors.online.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded, color: NovaColors.online, size: 48),
            ),
            const SizedBox(height: 16),
            const Text(
              'Safar yakunlandi!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              widget.order.formattedPrice,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: NovaColors.amberDeep,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Safar vaqti: ${context.read<RideProvider>().formattedTripDuration}',
              style: const TextStyle(fontSize: 16, color: NovaColors.textSecondary),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                context.read<RideProvider>().reset();
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: NovaColors.amber,
                foregroundColor: NovaColors.textPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text(
                'ORQAGA',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassBackButton extends StatelessWidget {
  final VoidCallback onTap;

  const _GlassBackButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.2),
              border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
            ),
            child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 22),
          ),
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String value;
  final Color color;

  const _InfoTile({
    required this.icon,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RideActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final Color shadowColor;
  final VoidCallback onTap;

  const _RideActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.shadowColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 64,
      child: ElevatedButton(
        onPressed: () {
          HapticFeedback.heavyImpact();
          onTap();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: shadowColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 26),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
