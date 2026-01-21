import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/design_system.dart';
import '../../../state/reunion_state.dart';
import '../../../state/profile_state.dart';
import '../../widgets/toast_helper.dart';
import '../../widgets/global_background.dart';

// Database-aligned visibility constants
class ReunionVisibility {
  static const String public = 'public'; // Visible to everyone
  static const String batch = 'batch'; // Visible to same batch
  static const String specificBatch = 'specific_batch'; // Future use
}

/*
  Create Reunion Event Screen.
  
  Form to organize a new reunion.
  Inputs:
  - Event Title & Description
  - Date & Time selectors
  - Location (Physical vs Virtual)
  - Visibility settings (Everyone vs Batch only)
*/
class ReunionCreateScreen extends ConsumerStatefulWidget {
  const ReunionCreateScreen({super.key});

  @override
  ConsumerState<ReunionCreateScreen> createState() =>
      _ReunionCreateScreenState();
}

class _ReunionCreateScreenState extends ConsumerState<ReunionCreateScreen> {
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _date = 'mm/dd/yy';
  String _time = '--:-- --';
  int _selectedType = 0; // 0: Physical, 1: Virtual
  int _visibleTo = 0; // 0: Everyone, 1: My Batch

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reunionState = ref.watch(reunionProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
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
      body: GlobalBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (reunionState.isLoading)
                  const LinearProgressIndicator(
                    color: DesignSystem.purpleAccent,
                  ),
                const SizedBox(height: 8),

                _buildLabel('Event Title'),
                _buildTextField(
                  _titleController,
                  'e.g. Class of 2024 Gala Night',
                ),
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
                          _buildDateTimePicker(
                            Icons.access_time,
                            _time,
                            _pickTime,
                          ),
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
                        onPressed: reunionState.isLoading
                            ? null
                            : () => Navigator.pop(context),
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
                        onPressed: reunionState.isLoading ? null : _createEvent,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: DesignSystem.purpleAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              reunionState.isLoading
                                  ? 'Creating...'
                                  : 'Create Event',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (!reunionState.isLoading)
                              const Icon(Icons.arrow_forward),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
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
    ToastHelper.show(context, message, isError: isError);
  }

  Future<void> _createEvent() async {
    final title = _titleController.text.trim();
    final location = _locationController.text.trim();
    final description = _descriptionController.text.trim();

    if (title.isEmpty) {
      _showToast('Please enter an event title', isError: true);
      return;
    }
    if (_date == 'mm/dd/yy') {
      _showToast('Please select a date', isError: true);
      return;
    }
    if (location.isEmpty) {
      _showToast('Please enter a location', isError: true);
      return;
    }

    try {
      final notifier = ref.read(reunionProvider.notifier);
      final profile = ref.read(profileProvider);

      await notifier.createReunion(
        title: title,
        description: description,
        date: _date,
        time: _time,
        locationType: _selectedType == 0 ? 'physical' : 'virtual',
        locationValue: location,
        visibility: _visibleTo == 0
            ? ReunionVisibility.public
            : ReunionVisibility.batch,
        batchYear: int.tryParse(profile.year),
      );

      _showToast('Reunion Event Created Successfully!');
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      _showToast('Error creating event: $e', isError: true);
    }
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
