import 'package:flutter/material.dart';

class ReunionCreateScreen extends StatefulWidget {
  const ReunionCreateScreen({super.key});

  @override
  State<ReunionCreateScreen> createState() => _ReunionCreateScreenState();
}

class _ReunionCreateScreenState extends State<ReunionCreateScreen> {
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();

  // Simulation of date/time
  String _date = 'mm/dd/yy';
  String _time = '--:-- --';
  int _selectedType = 0; // 0: Physical, 1: Virtual
  int _visibleTo = 0; // 0: Everyone, 1: My Batch

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1c1a3c),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1c1a3c),
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
                      _buildDateTimePicker(Icons.calendar_today, _date, () {
                        setState(() => _date = '11/12/26');
                      }),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Time'),
                      _buildDateTimePicker(Icons.access_time, _time, () {
                        setState(() => _time = '08:00 PM');
                      }),
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
                  color: Color(0xFFBB00FF),
                  size: 18,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Visible to',
                  style: TextStyle(
                    color: Colors.white,
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
                      backgroundColor: const Color(0xFFBB00FF),
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

  void _createEvent() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reunion Event Created (Simulated)')),
    );
    Navigator.pop(context);
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(color: Color(0xFFD6C9E6), fontSize: 14),
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
              ? Icon(icon, color: const Color(0xFFBB00FF))
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
            Icon(icon, color: const Color(0xFFBB00FF), size: 20),
            const SizedBox(width: 12),
            Text(value, style: const TextStyle(color: Colors.white)),
            const Spacer(),
            if (value == 'mm/dd/yy' || value == '--:-- --')
              const Icon(
                Icons.calendar_month_outlined,
                color: Colors.white30,
                size: 16,
              )
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
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF4A1070) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? const Color(0xFFBB00FF) : Colors.white54,
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
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4A1070) : const Color(0xFF24122E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFFBB00FF) : Colors.transparent,
          ),
        ),
        child: Text(label, style: const TextStyle(color: Colors.white)),
      ),
    );
  }
}
