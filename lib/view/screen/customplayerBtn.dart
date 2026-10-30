import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TvIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color color;
  final double size;
  final FocusNode node;
  final bool autofocus;
  const TvIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.color = Colors.white,
    this.size = 28,
    required this.node,
    this.autofocus = false,
  });
  @override
  State<TvIconButton> createState() => _TvIconButtonState();
}

class _TvIconButtonState extends State<TvIconButton> {
  bool focused = false;
  @override
  Widget build(BuildContext context) {
    if (widget.autofocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.node.requestFocus();
      });
    }
    return GestureDetector(
      onTap: widget.onPressed,
      child: FocusableActionDetector(
        focusNode: widget.node,
        shortcuts: <LogicalKeySet, Intent>{
          LogicalKeySet(LogicalKeyboardKey.select): const ActivateIntent(),
          LogicalKeySet(LogicalKeyboardKey.enter): const ActivateIntent(),
          LogicalKeySet(LogicalKeyboardKey.space): const ActivateIntent(),
          LogicalKeySet(LogicalKeyboardKey.gameButtonA): const ActivateIntent(),
        },
        actions: <Type, Action<Intent>>{
          ActivateIntent: CallbackAction(
            onInvoke: (intent) {
              widget.onPressed();
              return null;
            },
          ),
        },
        child: Builder(
          builder: (context) {
            final hasFocus = Focus.of(context).hasFocus;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: hasFocus ? Colors.white12 : Colors.black45,
                border: Border.all(
                  color: hasFocus ? Colors.red : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Icon(widget.icon, size: widget.size, color: widget.color),
            );
          },
        ),
      ),
    );
  }
}
