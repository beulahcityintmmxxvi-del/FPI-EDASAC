import 'package:flutter/material.dart';

/// A TextField that owns its own controller and disposes it safely
/// when removed from the widget tree.
///
/// Use this INSIDE dialogs to avoid the "_dependents.isEmpty" crash
/// caused by disposing a controller while the parent widget tree
/// is still mid-rebuild.
class SafeTextField extends StatefulWidget {
  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final InputDecoration? decoration;
  final TextInputType? keyboardType;
  final int? maxLines;
  final int? minLines;
  final bool autofocus;
  final String? Function(String?)? validator;
  final void Function(TextEditingController controller)? onControllerReady;

  const SafeTextField({
    super.key,
    this.initialValue,
    this.onChanged,
    this.decoration,
    this.keyboardType,
    this.maxLines = 1,
    this.minLines,
    this.autofocus = false,
    this.validator,
    this.onControllerReady,
  });

  @override
  State<SafeTextField> createState() => _SafeTextFieldState();
}

class _SafeTextFieldState extends State<SafeTextField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    // Notify parent about the controller AFTER the frame is committed
    // so the parent can read text later without owning the lifecycle.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.onControllerReady?.call(_controller);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      onChanged: widget.onChanged,
      decoration: widget.decoration,
      keyboardType: widget.keyboardType,
      maxLines: widget.maxLines,
      minLines: widget.minLines,
      autofocus: widget.autofocus,
      validator: widget.validator,
    );
  }
}