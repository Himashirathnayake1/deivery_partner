import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/delivery_order.dart';

class MultipleOrdersNotification extends StatefulWidget {
  final List<DeliveryOrder> orders;
  final Function(DeliveryOrder) onAccept;
  final Function(DeliveryOrder) onReject;

  const MultipleOrdersNotification({
    Key? key,
    required this.orders,
    required this.onAccept,
    required this.onReject,
  }) : super(key: key);

  @override
  State<MultipleOrdersNotification> createState() => _MultipleOrdersNotificationState();
}

class _MultipleOrdersNotificationState extends State<MultipleOrdersNotification> {
  Map<String, int> _remainingTimes = {};
  Map<String, Timer> _timers = {};

  @override
  void initState() {
    super.initState();
    _initializeTimers();
  }

  void _initializeTimers() {
    for (DeliveryOrder order in widget.orders) {
      _remainingTimes[order.id] = 15; // 15 seconds for each order
      _timers[order.id] = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (mounted) {
          setState(() {
            _remainingTimes[order.id] = (_remainingTimes[order.id] ?? 0) - 1;
          });

          if (_remainingTimes[order.id]! <= 0) {
            timer.cancel();
            widget.onReject(order);
          }
        }
      });
    }
  }

  @override
  void dispose() {
    _timers.values.forEach((timer) => timer.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1A1A2E),
            const Color(0xFF16213E),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF10B981).withOpacity(0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF10B981),
                  const Color(0xFF5A4FCF),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.notifications_active,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'New Delivery Requests',
                        style: GoogleFonts.orbitron(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '${widget.orders.length} orders available',
                        style: GoogleFonts.orbitron(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '15s each',
                    style: GoogleFonts.orbitron(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Orders list
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.5,
              ),
              child: ListView.builder(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                itemCount: widget.orders.length,
                itemBuilder: (context, index) {
                final order = widget.orders[index];
                final remainingTime = _remainingTimes[order.id] ?? 0;
                final progressValue = remainingTime / 15.0;
                
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Colors.black.withOpacity(0.3),
                        Colors.black.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: remainingTime <= 5 
                          ? Colors.red.withOpacity(0.5)
                          : const Color(0xFF10B981).withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Order header with timer
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4CAF50).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.delivery_dining,
                              color: const Color(0xFF4CAF50),
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Order #${order.id.substring(order.id.length - 6)}',
                                  style: GoogleFonts.orbitron(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  order.customerName,
                                  style: GoogleFonts.orbitron(
                                    fontSize: 10,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: remainingTime <= 5 
                                  ? Colors.red.withOpacity(0.3)
                                  : Colors.green.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${remainingTime}s',
                              style: GoogleFonts.orbitron(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: remainingTime <= 5 ? Colors.red : Colors.green,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Progress bar
                      LinearProgressIndicator(
                        value: progressValue,
                        backgroundColor: Colors.grey.withOpacity(0.3),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          remainingTime <= 5 ? Colors.red : const Color(0xFF4CAF50),
                        ),
                        minHeight: 3,
                      ),

                      const SizedBox(height: 8),

                      // Order details in compact format
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Rs. ${order.totalAmount?.toStringAsFixed(0) ?? '0'}',
                                  style: GoogleFonts.orbitron(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFFFFD700),
                                  ),
                                ),
                                Text(
                                  '${order.distance} km • ${order.estimatedTime} min',
                                  style: GoogleFonts.orbitron(
                                    fontSize: 10,
                                    color: Colors.white60,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '📍 ${order.pickupLocation}',
                                  style: GoogleFonts.orbitron(
                                    fontSize: 9,
                                    color: Colors.green.shade200,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  '🏠 ${order.deliveryLocation}',
                                  style: GoogleFonts.orbitron(
                                    fontSize: 9,
                                    color: Colors.orange.shade200,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Action buttons
                      Row(
                        children: [
                          Expanded(
                            child: _buildQuickActionButton(
                              'DECLINE',
                              Icons.close,
                              Colors.red,
                              () => widget.onReject(order),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 2,
                            child: _buildQuickActionButton(
                              'ACCEPT',
                              Icons.check,
                              const Color(0xFF4CAF50),
                              () => widget.onAccept(order),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ).animate()
                  .slideX(
                    begin: index.isEven ? -0.3 : 0.3,
                    end: 0,
                    duration: Duration(milliseconds: 300 + (index * 100)),
                  )
                  .fadeIn(duration: Duration(milliseconds: 200 + (index * 50)));
              },
            ),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    ).animate()
      .slideY(
        begin: -0.5,
        end: 0,
        duration: const Duration(milliseconds: 400),
        curve: Curves.elasticOut,
      )
      .fadeIn(duration: const Duration(milliseconds: 300));
  }

  Widget _buildQuickActionButton(String text, IconData icon, Color color, VoidCallback onPressed) {
    return Container(
      height: 35,
      child: ElevatedButton(
        onPressed: () {
          HapticFeedback.mediumImpact();
          onPressed();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: color.withOpacity(0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14),
            const SizedBox(width: 4),
            Text(
              text,
              style: GoogleFonts.orbitron(
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
