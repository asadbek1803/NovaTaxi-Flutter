import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:provider/provider.dart';

import '../models/order_model.dart';
import '../providers/home_provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/services/websocket_service.dart';
import '../widgets/glassmorphism_button.dart';
import '../widgets/pulsing_marker.dart';
import 'order_details_screen.dart';

class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen>
    with TickerProviderStateMixin {
  final MapController _mapController = MapController();

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, home, _) {
        final showOrder = home.isOnline && home.incomingOrder != null;

        return Scaffold(
          backgroundColor: const Color(0xFF1A1A2E),
          body: Stack(
            fit: StackFit.expand,
            children: [
              _buildMap(home),

              if (!home.isOnline)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.35),
                  ),
                ),

              _buildTopButtons(home, context),

              if (home.isOnline && !showOrder)
                _buildWaitingBanner(home),

              if (showOrder)
                _buildIncomingOrderOverlay(home),

              if (!showOrder)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _buildBottomSheet(home, context),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMap(HomeProvider home) {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: home.currentPosition,
        initialZoom: AppConstants.defaultZoom,
        maxZoom: 18,
        minZoom: 12,
        onMapReady: () {},
      ),
      children: [
        TileLayer(
          retinaMode: MediaQuery.of(context).devicePixelRatio > 1.0,
          urlTemplate: 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
          subdomains: const ['a', 'b', 'c', 'd'],
          userAgentPackageName: 'com.novataxi.driver',
        ),
        MarkerLayer(
          markers: [
            Marker(
              point: home.currentPosition,
              width: 120,
              height: 120,
              child: PulsingCarMarker(isOnline: home.isOnline),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTopButtons(HomeProvider home, BuildContext context) {
    final topPad = MediaQuery.paddingOf(context).top;

    return Positioned(
      top: topPad + 12,
      left: 16,
      right: 16,
      child: Row(
        children: [
          GlassActionChip(
            icon: home.isOnline ? Icons.wifi_rounded : Icons.wifi_off_rounded,
            label: home.isOnline ? 'Onlayn' : 'Oflayn',
            isActive: home.isOnline,
            onTap: home.isToggling
                ? null
                : () => home.toggleOnline(!home.isOnline, context),
          ),
          const Spacer(),
          if (home.isOnline && home.wsState != WsConnectionState.connected)
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.orange.withValues(alpha: 0.4),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.sync_rounded, size: 14, color: Colors.orange),
                  SizedBox(width: 4),
                  Text(
                    'Qayta ulanmoqda...',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
            ),
          GlassButton(
            onTap: () {
              _mapController.move(
                home.currentPosition,
                _mapController.camera.zoom,
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Joylashuv yangilandi',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              );
            },
            child: const Icon(
              Icons.my_location_rounded,
              size: 22,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaitingBanner(HomeProvider home) {
    return Positioned(
      top: MediaQuery.paddingOf(context).top + 72,
      left: 16,
      right: 16,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: const Row(
              children: [
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: NovaColors.amber,
                    strokeCap: StrokeCap.round,
                  ),
                ),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Buyurtma kutilmoqda...',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Ovozli bildirishnoma bilan xabar beriladi',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIncomingOrderOverlay(HomeProvider home) {
    return Positioned(
      left: 12,
      right: 12,
      bottom: 100,
      child: _IncomingOrderOverlay(
        order: home.incomingOrder!,
        secondsLeft: home.orderSecondsLeft,
        onAccept: () {
          final order = home.incomingOrder!;
          home.acceptOrder();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OrderDetailsScreen(order: order),
            ),
          );
        },
        onDecline: () => home.declineOrder(),
      ),
    );
  }

  Widget _buildBottomSheet(HomeProvider home, BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          decoration: BoxDecoration(
            color: home.isOnline
                ? Colors.white.withValues(alpha: 0.92)
                : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
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
                _buildStatusText(home),
                const SizedBox(height: 16),
                _buildStatsRow(home),
                const SizedBox(height: 18),
                if (home.isToggling)
                  const SizedBox(
                    height: 68,
                    child: Center(
                      child: CircularProgressIndicator(color: NovaColors.amber),
                    ),
                  )
                else
                  PremiumGoOnlineButton(
                    isOnline: home.isOnline,
                    onToggle: (v) => home.toggleOnline(v, context),
                  ),
                if (!home.isOnline) ...[
                  const SizedBox(height: 10),
                  const Center(
                    child: Text(
                      'Fon xizmati va ovozli buyurtmalar yoqiladi',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: NovaColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusText(HomeProvider home) {
    return Row(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: home.isOnline ? NovaColors.online : NovaColors.offline,
            shape: BoxShape.circle,
            boxShadow: home.isOnline
                ? [
                    BoxShadow(
                      color: NovaColors.online.withValues(alpha: 0.6),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          home.isOnline
              ? 'Siz buyurtma olishingiz mumkin'
              : 'Ishni boshlash uchun chiqing',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: home.isOnline
                ? NovaColors.onlineDark
                : NovaColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow(HomeProvider home) {
    return Row(
      children: [
        Expanded(
          child: _PremiumStatBlock(
            label: 'Bugun',
            value: home.formattedEarnings,
            highlight: true,
          ),
        ),
        Container(width: 1, height: 44, color: const Color(0xFFE5E7EB)),
        Expanded(
          child: _PremiumStatBlock(
            label: 'Safarlar',
            value: '${home.todayTrips} ta',
          ),
        ),
        Container(width: 1, height: 44, color: const Color(0xFFE5E7EB)),
        Expanded(
          child: _PremiumStatBlock(
            label: 'Vaqt',
            value: '${home.todayHours.toStringAsFixed(1)} soat',
          ),
        ),
      ],
    );
  }
}

class _PremiumStatBlock extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;

  const _PremiumStatBlock({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: NovaColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: highlight ? 15 : 16,
                fontWeight: FontWeight.w800,
                color: highlight ? NovaColors.amberDeep : NovaColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IncomingOrderOverlay extends StatefulWidget {
  final Order order;
  final int secondsLeft;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const _IncomingOrderOverlay({
    required this.order,
    required this.secondsLeft,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  State<_IncomingOrderOverlay> createState() => _IncomingOrderOverlayState();
}

class _IncomingOrderOverlayState extends State<_IncomingOrderOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.015).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = widget.secondsLeft / 30;

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: child,
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 32,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
                  decoration: const BoxDecoration(
                    color: NovaColors.amber,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Yangi buyurtma',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF5C4A00),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.order.formattedPrice,
                              style: const TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.w900,
                                color: NovaColors.textPrimary,
                                letterSpacing: -0.5,
                                height: 1.1,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 56,
                        height: 56,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CircularProgressIndicator(
                              value: progress,
                              strokeWidth: 4,
                              backgroundColor: NovaColors.textPrimary.withValues(alpha: 0.15),
                              valueColor: const AlwaysStoppedAnimation<Color>(NovaColors.textPrimary),
                            ),
                            Text(
                              '${widget.secondsLeft}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: NovaColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          _SmallChip(
                            icon: Icons.route_rounded,
                            label: widget.order.distance,
                          ),
                          const SizedBox(width: 8),
                          _SmallChip(
                            icon: Icons.schedule_rounded,
                            label: widget.order.estimatedTime,
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _OrderAddressRow(
                        color: NovaColors.online,
                        label: 'Olish joyi',
                        address: widget.order.pickupAddress,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 15),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            width: 2,
                            height: 16,
                            color: const Color(0xFFE5E7EB),
                          ),
                        ),
                      ),
                      _OrderAddressRow(
                        color: NovaColors.amberDeep,
                        label: 'Boradigan joy',
                        address: widget.order.destinationAddress,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 18),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 60,
                        height: 60,
                        child: Material(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(18),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(18),
                            onTap: () {
                              HapticFeedback.lightImpact();
                              widget.onDecline();
                            },
                            child: const Icon(
                              Icons.close_rounded,
                              size: 28,
                              color: NovaColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 60,
                          child: ElevatedButton(
                            onPressed: () {
                              HapticFeedback.mediumImpact();
                              widget.onAccept();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: NovaColors.online,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shadowColor: NovaColors.online.withValues(alpha: 0.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check_circle_rounded, size: 24),
                                SizedBox(width: 8),
                                Text(
                                  'QABUL QILISH',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SmallChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SmallChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: NovaColors.textSecondary),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: NovaColors.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderAddressRow extends StatelessWidget {
  final Color color;
  final String label;
  final String address;

  const _OrderAddressRow({
    required this.color,
    required this.label,
    required this.address,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.4),
                  blurRadius: 6,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: NovaColors.textSecondary,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                address,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: NovaColors.textPrimary,
                  height: 1.25,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
