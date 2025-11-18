import 'package:flutter/material.dart';

/// Model for Speed Dial action items
class SpeedDialAction {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const SpeedDialAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.backgroundColor,
    this.foregroundColor,
  });
}

/// Speed Dial Floating Action Button
/// Expandable FAB that shows multiple action buttons
class SpeedDialFab extends StatefulWidget {
  final List<SpeedDialAction> actions;
  final IconData icon;
  final IconData activeIcon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final String? tooltip;
  final Curve animationCurve;
  final Duration animationDuration;
  final ValueChanged<bool>? onToggle;

  const SpeedDialFab({
    super.key,
    required this.actions,
    this.icon = Icons.add,
    this.activeIcon = Icons.close,
    this.backgroundColor,
    this.foregroundColor,
    this.tooltip,
    this.animationCurve = Curves.easeInOut,
    this.animationDuration = const Duration(milliseconds: 300),
    this.onToggle,
  });

  @override
  State<SpeedDialFab> createState() => SpeedDialFabState();
}

class SpeedDialFabState extends State<SpeedDialFab>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      curve: widget.animationCurve,
      reverseCurve: widget.animationCurve,
      parent: _controller,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
      widget.onToggle?.call(_isOpen);
    });
  }

  /// Public method to close the FAB from outside
  void close() {
    if (_isOpen) {
      setState(() {
        _isOpen = false;
        _controller.reverse();
        widget.onToggle?.call(false);
      });
    }
  }

  void _close() {
    close();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56,
      height: 56,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Speed dial items
          ..._buildSpeedDialItems(),

          // Main FAB
          _buildMainFab(),
        ],
      ),
    );
  }

  Widget _buildMainFab() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return FloatingActionButton(
      onPressed: _toggle,
      backgroundColor: widget.backgroundColor ?? (isDark ? Colors.white : Colors.black),
      foregroundColor: widget.foregroundColor ?? (isDark ? Colors.black : Colors.white),
      tooltip: widget.tooltip,
      shape: const CircleBorder(),
      child: AnimatedRotation(
        duration: widget.animationDuration,
        turns: _isOpen ? 0.375 : 0, // 135 degrees (3/8 of a full rotation)
        child: Icon(_isOpen ? widget.activeIcon : widget.icon),
      ),
    );
  }

  List<Widget> _buildSpeedDialItems() {
    final children = <Widget>[];
    final count = widget.actions.length;
    
    if (count == 2) {
      // Layout for 2 items: side by side
      children.add(
        Positioned(
          bottom: 80,
          child: ScaleTransition(
            scale: _expandAnimation,
            child: FadeTransition(
              opacity: _expandAnimation,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _SpeedDialItem(
                    action: widget.actions[0],
                    onTap: () {
                      _close();
                      widget.actions[0].onTap();
                    },
                  ),
                  const SizedBox(width: 12),
                  _SpeedDialItem(
                    action: widget.actions[1],
                    onTap: () {
                      _close();
                      widget.actions[1].onTap();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    } else if (count == 4) {
      // Layout for 4 items: 2x2 grid
      children.add(
        Positioned(
          bottom: 80,
          child: ScaleTransition(
            scale: _expandAnimation,
            child: FadeTransition(
              opacity: _expandAnimation,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Top row
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _SpeedDialItem(
                        action: widget.actions[0],
                        onTap: () {
                          _close();
                          widget.actions[0].onTap();
                        },
                      ),
                      const SizedBox(width: 12),
                      _SpeedDialItem(
                        action: widget.actions[1],
                        onTap: () {
                          _close();
                          widget.actions[1].onTap();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Bottom row
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _SpeedDialItem(
                        action: widget.actions[2],
                        onTap: () {
                          _close();
                          widget.actions[2].onTap();
                        },
                      ),
                      const SizedBox(width: 12),
                      _SpeedDialItem(
                        action: widget.actions[3],
                        onTap: () {
                          _close();
                          widget.actions[3].onTap();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    } else {
      // Fallback: vertical layout
      const spacing = 152.0; // Space between buttons
      for (var i = 0; i < count; i++) {
        final action = widget.actions[i];
        final offset = spacing * (i + 1);

        children.add(
          Positioned(
            bottom: offset,
            child: ScaleTransition(
              scale: _expandAnimation,
              child: FadeTransition(
                opacity: _expandAnimation,
                child: _SpeedDialItem(
                  action: action,
                  onTap: () {
                    _close();
                    action.onTap();
                  },
                ),
              ),
            ),
          ),
        );
      }
    }

    return children;
  }
}

/// Individual Speed Dial Item
class _SpeedDialItem extends StatelessWidget {
  final SpeedDialAction action;
  final VoidCallback onTap;

  const _SpeedDialItem({
    required this.action,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(20),
      color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 160,
          height: 140,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: action.backgroundColor ?? (isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  action.icon,
                  size: 32,
                  color: action.foregroundColor ?? (isDark ? Colors.white : Colors.black),
                ),
              ),
              const SizedBox(height: 12),
              
              // Label
              Text(
                action.label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
