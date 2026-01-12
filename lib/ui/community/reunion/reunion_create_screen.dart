import 'package:flutter/material.dart';
import '../../../theme/design_system.dart';

class ReunionCreateScreen extends StatefulWidget {
  const ReunionCreateScreen({super.key});

  @override
  State<ReunionCreateScreen> createState() => _ReunionCreateScreenState();
}

class _ReunionCreateScreenState extends State<ReunionCreateScreen> {
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _date = 'mm/dd/yy';
  String _time = '--:-- --';
  int _selectedType = 0; // 0: Physical, 1: Virtual
  int _visibleTo = 0; // 0: Everyone, 1: My Batch

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignSystem.scaffoldBg,
      appBar: AppBar(
        backgroundColor: DesignSystem.scaffoldBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Create Reunion Event',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel('Event Title'),
            _buildTextField(_titleController, 'e.g. Class of 2024 Gala Night'),
            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Date'),
                      _buildDateTimePicker(
                        Icons.calendar_today,
                        _date,
                        _pickDate,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Time'),
                      _buildDateTimePicker(Icons.access_time, _time, _pickTime),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            _buildLabel('Location'),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFF24122E),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  _buildTypeOption(0, 'Physical'),
                  _buildTypeOption(1, 'Virtual'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _buildTextField(
              _locationController,
              'Add location or paste meeting link',
              icon: Icons.location_on,
            ),

            const SizedBox(height: 24),

            _buildLabel('Description'),
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFF24122E),
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextField(
                controller: _descriptionController,
                maxLines: 5,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText:
                      'Tell everyone what\'s happening! Agenda, dress code, etc.',
                  hintStyle: TextStyle(color: Colors.white30),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                ),
              ),
            ),

            const SizedBox(height: 24),

            Row(
              children: [
                const Icon(
                  Icons.visibility,
                  color: DesignSystem.purpleAccent,
                  size: 18,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Visible to',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildVisibilityOption(0, 'Everyone'),
                const SizedBox(width: 12),
                _buildVisibilityOption(1, 'My Batch Only'),
              ],
            ),

            const SizedBox(height: 40),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white24),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _createEvent,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: DesignSystem.purpleAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Create Event',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward),
                      ],
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

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: DesignSystem.purpleAccent,
              onPrimary: Colors.white,
              surface: DesignSystem.purpleDark,
              onSurface: Colors.white,
            ),
            dialogTheme: const DialogThemeData(
              backgroundColor: Color(0xFF1E1E2E),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _date = "${picked.month}/${picked.day}/${picked.year}";
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: DesignSystem.purpleAccent,
              onPrimary: Colors.white,
              surface: Color(0xFF24122E),
              onSurface: Colors.white,
            ),
            timePickerTheme: TimePickerThemeData(
              backgroundColor: const Color(0xFF1B0423),
              hourMinuteTextColor: Colors.white,
              dayPeriodTextColor: Colors.white,
              dialHandColor: DesignSystem.purpleAccent,
              dialBackgroundColor: const Color(0xFF24122E),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      if (!mounted) return;
      setState(() {
        _time = picked.format(context);
      });
    }
  }

  void _showToast(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF2A1727),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isError
                  ? Colors.redAccent.withValues(alpha: 0.5)
                  : DesignSystem.purpleAccent.withValues(alpha: 0.3),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                isError ? Icons.error_outline : Icons.check_circle,
                color: isError ? Colors.redAccent : DesignSystem.purpleAccent,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _createEvent() {
    if (_titleController.text.trim().isEmpty) {
      _showToast('Please enter an event title', isError: true);
      return;
    }
    if (_selectedType == 0 && _locationController.text.trim().isEmpty) {
      _showToast('Please enter a location', isError: true);
      return;
    }

    _showToast('Reunion Event Created (Simulated)');
    Navigator.pop(context);
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFFD6C9E6),
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint, {
    IconData? icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF24122E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white30),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
          prefixIcon: icon != null
              ? Icon(icon, color: DesignSystem.purpleAccent)
              : null,
        ),
      ),
    );
  }

  Widget _buildDateTimePicker(IconData icon, String value, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF24122E),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: DesignSystem.purpleAccent, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            if (value == 'mm/dd/yy' || value == '--:-- --')
              const Icon(Icons.arrow_drop_down, color: Colors.white30, size: 20)
            else
              const Icon(
                Icons.check_circle,
                color: Colors.greenAccent,
                size: 16,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeOption(int index, String label) {
    final isSelected = _selectedType == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedType = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF4A1070) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? DesignSystem.purpleAccent : Colors.white54,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVisibilityOption(int index, String label) {
    final isSelected = _visibleTo == index;
    return GestureDetector(
      onTap: () => setState(() => _visibleTo = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4A1070) : const Color(0xFF24122E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? DesignSystem.purpleAccent : Colors.transparent,
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
