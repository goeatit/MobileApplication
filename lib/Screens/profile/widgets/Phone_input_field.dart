import 'package:eatit/common/constants/colors.dart';
import 'package:flutter/material.dart';

class ProfileInputField extends StatefulWidget {
  final String label;
  final IconData icon;
  final String value;
  final Function(String) onSave;
  final bool isDropdown;
  final bool editIcon;

  const ProfileInputField({
    super.key,
    required this.label,
    required this.icon,
    required this.value,
    required this.onSave,
    this.isDropdown = false,
    required this.editIcon,
  });

  @override
  State<ProfileInputField> createState() => _ProfileInputFieldState();
}

class _ProfileInputFieldState extends State<ProfileInputField> {
  late TextEditingController _controller;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    if (widget.editIcon) {
      setState(() {
        _isEditing = !_isEditing;
      });
      if (!_isEditing) {
        widget.onSave(_controller.text);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(color: Colors.grey, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              Icon(widget.icon, color: Colors.grey),
              const SizedBox(width: 16),
              Expanded(
                child: _isEditing
                    ? TextField(
                  controller: _controller,
                  autofocus: true,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                  ),
                )
                    : Text(
                  widget.value,
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                ),
              ),
              if (widget.editIcon)
                GestureDetector(
                  onTap: _toggleEdit,
                  child: Icon(
                    _isEditing ? Icons.check : Icons.edit,
                    color: primaryColor,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
