import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../../../core/theme/app_theme.dart';
import '../widgets/route_map_painter.dart';

class PickupNavigationScreen extends StatefulWidget {
  final Order order;

  const PickupNavigationScreen({super.key, required this.order});

  @override
  State<PickupNavigationScreen> createState() => _PickupNavigationScreenState();
}

class _PickupNavigationScreenState extends State<PickupNavigationScreen>
    with TickerProviderStateMixin {
  late AnimationController _routeAnimController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  double _currentDistance = 4.2;
  int _etaMinutes = 15;
  double _driverLat = 41.2995;
  double _driverLng = 69.2401;
  final double _customerLat = 41.3112;
  final double _customerLng = 69.2784;
  Timer? _locationTimer;

  @override
  void initState() {
    super.initState();

    _routeAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..forward();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _startLocationUpdates();
  }

  void _startLocationUpdates() {
    _locationTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (!mounted) return;
      final rng = Random();
      setState(() {
        _driverLat += (rng.nextDouble() - 0.3) * 0.0004;
        _driverLng += (rng.nextDouble() - 0.2) * 0.0005;
        _currentDistance = max(0.1, _currentDistance - rng.nextDouble() * 0.08);
        _etaMinutes = max(1, (_currentDistance * 3.5).round());
      });
    });
  }

  @override
  void dispose() {
    _routeAnimController.dispose();
    _pulseController.dispose();
    _locationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NovaColors.backgroundLight,
      appBar: AppBar(
        title: const Text(
          'Yo\'nalish',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: NovaColors.online.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: NovaColors.online,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'GPS faol',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: NovaColors.onlineDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                _buildMap(),
                _buildDriverMarker(),
                _buildCustomerMarker(),
                _buildFloatingInfo(),
              ],
            ),
          ),
          _buildBottomPanel(),
        ],
      ),
    );
  }

  Widget _buildMap() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFDCECC8),
            Color(0xFFD0E4B8),
            Color(0xFFC5DBA8),
          ],
        ),
      ),
      child: AnimatedBuilder(
        animation: _routeAnimController,
        builder: (context, _) {
          return CustomPaint(
            painter: RouteMapPainter(
              progress: _routeAnimController.value,
            ),
            child: _buildMapOverlay(),
          );
        },
      ),
    );
  }

  Widget _buildMapOverlay() {
    return Stack(
      children: [
        Positioned(
          top: 12,
          left: 12,
          child: _buildMapLabel('A. Temur ko\'chasi'),
        ),
        Positioned(
          top: 60,
          right: 16,
          child: _buildMapLabel('Buyuk Ipak Yo\'li'),
        ),
        Positioned(
          bottom: 100,
          left: 50,
          child: _buildMapLabel('Navoiy ko\'chasi'),
        ),
        Positioned(
          top: 140,
          left: 100,
          child: _buildMapLabel('Bunyodkor ko\'chasi'),
        ),
        Positioned(
          bottom: 40,
          right: 60,
          child: _buildMapLabel('Farg\'ona yo\'li'),
        ),
      ],
    );
  }

  Widget _buildMapLabel(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
          ),
        ],
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          color: Color(0xFF555555),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildDriverMarker() {
    return Positioned(
      left: MediaQuery.of(context).size.width * 0.2 - 28,
      top: MediaQuery.of(context).size.height * 0.38 - 60,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation.value,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF3B82F6).withValues(alpha: 0.4),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Text(
                    'Siz',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 52,
                  height: 52,
                  decoration: const BoxDecoration(
                    color: Color(0xFF3B82F6),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x403B82F6),
                        blurRadius: 16,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.directions_car,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 2),
                CustomPaint(
                  size: const Size(12, 8),
                  painter: _TrianglePainter(color: const Color(0xFF3B82F6)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCustomerMarker() {
    final isClose = _currentDistance < 1.0;
    final color = isClose ? NovaColors.amber : NovaColors.online;

    return Positioned(
      right: MediaQuery.of(context).size.width * 0.2 - 28,
      top: MediaQuery.of(context).size.height * 0.12 - 40,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                ),
              ],
            ),
            child: const Text(
              'Mijoz',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: NovaColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.4),
                  blurRadius: 16,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: const Icon(
              Icons.person,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(height: 2),
          CustomPaint(
            size: const Size(12, 8),
            painter: _TrianglePainter(color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingInfo() {
    return Positioned(
      top: 16,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: NovaColors.online.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.navigation_rounded,
                    color: NovaColors.onlineDark,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Text(
                    'Mijozni olib ketishga boring',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: NovaColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                _buildMetricTile(
                  icon: Icons.straighten_rounded,
                  value: '${_currentDistance.toStringAsFixed(1)} km',
                  color: const Color(0xFF3B82F6),
                ),
                const SizedBox(width: 10),
                _buildMetricTile(
                  icon: Icons.access_time_rounded,
                  value: '$_etaMinutes daqiqa',
                  color: NovaColors.amberDeep,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _buildGpsChip(
                  label: 'Siz',
                  lat: _driverLat,
                  lng: _driverLng,
                  color: const Color(0xFF3B82F6),
                ),
                const SizedBox(width: 10),
                _buildGpsChip(
                  label: 'Mijoz',
                  lat: _customerLat,
                  lng: _customerLng,
                  color: NovaColors.online,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricTile({
    required IconData icon,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGpsChip({
    required String label,
    required double lat,
    required double lng,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.15)),
        ),
        child: Row(
          children: [
            Icon(Icons.gps_fixed_rounded, size: 14, color: color),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                  Text(
                    '${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: color.withValues(alpha: 0.8),
                      fontFamily: 'monospace',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomPanel() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.location_on_rounded,
                    color: Color(0xFF3B82F6),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
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
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 64,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded, size: 26),
                      label: const Text(
                        'Bekor qilish',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF3F4F6),
                        foregroundColor: NovaColors.textSecondary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 64,
                    child: ElevatedButton.icon(
                      onPressed: () => _showArrivedDialog(context),
                      icon: const Icon(Icons.check_circle_rounded, size: 26),
                      label: const Text(
                        'Mijozga yetib keldim',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: NovaColors.amber,
                        foregroundColor: NovaColors.textPrimary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showArrivedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: const Text(
          'Mijozga yetib keldingizmi?',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
        content: Text(
          '${widget.order.pickupAddress} manziliga yetib kelganingizni tasdiqlaysizmi?',
          style: const TextStyle(fontSize: 16, height: 1.4),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Yo\'q',
              style: TextStyle(
                fontSize: 16,
                color: NovaColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: NovaColors.online,
              foregroundColor: Colors.white,
              minimumSize: const Size(0, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Ha, tasdiqlayman',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrianglePainter extends CustomPainter {
  final Color color;

  _TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


