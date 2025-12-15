import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

enum NotificationType {
  success,
  error,
  warning,
  info,
}

class LiquidNotification {
  static void show({
    required BuildContext context,
    required String message,
    required NotificationType type,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onTap,
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => LiquidNotificationWidget(
        message: message,
        type: type,
        onDismiss: () {
          overlayEntry.remove();
        },
        onTap: onTap,
      ),
    );

    overlay.insert(overlayEntry);

    // Auto dismiss after duration
    Future.delayed(duration, () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }

  // Convenience methods
  static void success(BuildContext context, String message) {
    show(context: context, message: message, type: NotificationType.success);
  }

  static void error(BuildContext context, String message) {
    show(context: context, message: message, type: NotificationType.error);
  }

  static void warning(BuildContext context, String message) {
    show(context: context, message: message, type: NotificationType.warning);
  }

  static void info(BuildContext context, String message) {
    show(context: context, message: message, type: NotificationType.info);
  }
}

class LiquidNotificationWidget extends StatefulWidget {
  final String message;
  final NotificationType type;
  final VoidCallback onDismiss;
  final VoidCallback? onTap;

  const LiquidNotificationWidget({
    super.key,
    required this.message,
    required this.type,
    required this.onDismiss,
    this.onTap,
  });

  @override
  State<LiquidNotificationWidget> createState() => _LiquidNotificationWidgetState();
}

class _LiquidNotificationWidgetState extends State<LiquidNotificationWidget>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _liquidController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _liquidController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _slideController.forward();
    _liquidController.repeat();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _slideController.dispose();
    _liquidController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Color get backgroundColor {
    switch (widget.type) {
      case NotificationType.success:
        return const Color(0xFF00D4AA);
      case NotificationType.error:
        return const Color(0xFFFF6B6B);
      case NotificationType.warning:
        return const Color(0xFFFFB800);
      case NotificationType.info:
        return const Color(0xFF4ECDC4);
    }
  }

  IconData get icon {
    switch (widget.type) {
      case NotificationType.success:
        return Icons.check_circle;
      case NotificationType.error:
        return Icons.error;
      case NotificationType.warning:
        return Icons.warning;
      case NotificationType.info:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      left: 16,
      right: 16,
      child: Material(
        color: Colors.transparent,
        child: GestureDetector(
          onTap: widget.onTap,
          onPanUpdate: (details) {
            if (details.delta.dy < -5) {
              _dismiss();
            }
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: backgroundColor.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  // Liquid background animation
                  Positioned.fill(
                    child: AnimatedBuilder(
                      animation: _liquidController,
                      builder: (context, child) {
                        return Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              stops: [
                                0.0,
                                0.3 + 0.2 * _liquidController.value,
                                0.7 + 0.2 * _liquidController.value,
                                1.0,
                              ],
                              colors: [
                                backgroundColor,
                                backgroundColor.withOpacity(0.8),
                                backgroundColor.withOpacity(0.9),
                                backgroundColor,
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  
                  // Glowing pulse effect
                  Positioned.fill(
                    child: AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3 * _pulseController.value),
                              width: 2,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  
                  // Content
                  Row(
                    children: [
                      // Icon with pulse animation
                      AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) {
                          return Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2 + 0.1 * _pulseController.value),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              icon,
                              color: Colors.white,
                              size: 24,
                            ),
                          );
                        },
                      ),
                      
                      const SizedBox(width: 12),
                      
                      // Message
                      Expanded(
                        child: Text(
                          widget.message,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            height: 1.4,
                          ),
                        ),
                      ),
                      
                      const SizedBox(width: 8),
                      
                      // Close button
                      GestureDetector(
                        onTap: _dismiss,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ).animate(controller: _slideController)
            .slideY(
              begin: -1.0,
              end: 0.0,
              curve: Curves.elasticOut,
            )
            .fadeIn(
              duration: const Duration(milliseconds: 300),
            ),
        ),
      ),
    );
  }

  void _dismiss() async {
    await _slideController.reverse();
    widget.onDismiss();
  }
}

// Back button notification widget
class BackButtonNotification extends StatelessWidget {
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  final String title;
  final String message;

  const BackButtonNotification({
    super.key,
    required this.onConfirm,
    required this.onCancel,
    this.title = 'Exit App',
    this.message = 'Are you sure you want to exit?',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1A1A2E),
            Color(0xFF16213E),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withOpacity(0.3),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.2),
              borderRadius: BorderRadius.circular(50),
            ),
            child: const Icon(
              Icons.exit_to_app,
              color: Color(0xFF10B981),
              size: 32,
            ),
          )
          .animate()
          .scale(
            delay: const Duration(milliseconds: 200),
            duration: const Duration(milliseconds: 600),
            curve: Curves.elasticOut,
          ),
          
          const SizedBox(height: 20),
          
          // Title
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          )
          .animate()
          .fadeIn(delay: const Duration(milliseconds: 400))
          .slideY(begin: 0.5, end: 0),
          
          const SizedBox(height: 8),
          
          // Message
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.7),
              height: 1.4,
            ),
          )
          .animate()
          .fadeIn(delay: const Duration(milliseconds: 600))
          .slideY(begin: 0.5, end: 0),
          
          const SizedBox(height: 24),
          
          // Buttons
          Row(
            children: [
              Expanded(
                child: _buildButton(
                  'Cancel',
                  Colors.grey.withOpacity(0.2),
                  Colors.white.withOpacity(0.7),
                  onCancel,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildButton(
                  'Exit',
                  const Color(0xFF10B981),
                  Colors.white,
                  onConfirm,
                ),
              ),
            ],
          )
          .animate()
          .fadeIn(delay: const Duration(milliseconds: 800))
          .slideY(begin: 0.5, end: 0),
        ],
      ),
    )
    .animate()
    .scale(
      begin: const Offset(0.8, 0.8),
      end: const Offset(1.0, 1.0),
      duration: const Duration(milliseconds: 400),
      curve: Curves.elasticOut,
    )
    .fadeIn();
  }

  Widget _buildButton(String text, Color backgroundColor, Color textColor, VoidCallback onPressed) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

// Show back button dialog
void showBackButtonDialog(BuildContext context, {
  String title = 'Exit App',
  String message = 'Are you sure you want to exit?',
  VoidCallback? onConfirm,
}) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: '',
    barrierColor: Colors.black.withOpacity(0.5),
    transitionDuration: const Duration(milliseconds: 400),
    pageBuilder: (context, animation1, animation2) {
      return Center(
        child: BackButtonNotification(
          title: title,
          message: message,
          onConfirm: () {
            Navigator.of(context).pop();
            onConfirm?.call();
          },
          onCancel: () {
            Navigator.of(context).pop();
          },
        ),
      );
    },
  );
}
