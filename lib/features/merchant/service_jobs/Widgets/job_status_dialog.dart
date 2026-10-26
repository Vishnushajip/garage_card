import 'package:flutter/material.dart';
import 'package:garage_card/core/colors/app_colors.dart';
import 'package:garage_card/core/fonts/app_fonts.dart';
import 'package:garage_card/core/shared_widgets/app_button.dart';
import 'package:garage_card/core/shared_widgets/app_dropdown.dart';
import 'package:garage_card/core/shared_widgets/app_text_field.dart';
import 'package:garage_card/features/shared/sharing/whatsapp_share_service.dart';

class JobStatusDialog extends StatefulWidget {
  const JobStatusDialog({
    super.key,
    required this.currentStatus,
    required this.onUpdateStatus,
    this.customerName = 'Valued Customer',
    this.vehicleDisplay = 'Vehicle',
    this.jobNumber = '',
    this.garageName = 'Apex Precision Automotive',
    this.customerPhone = '+919846077112',
    this.customerWhatsApp = '',
  });

  final String currentStatus;
  final String customerName;
  final String vehicleDisplay;
  final String jobNumber;
  final String garageName;
  final String customerPhone;
  final String customerWhatsApp;
  final Future<bool> Function(String newStatus, String notes) onUpdateStatus;

  @override
  State<JobStatusDialog> createState() => _JobStatusDialogState();
}

class _JobStatusDialogState extends State<JobStatusDialog> {
  late String _selectedStatus;
  late final TextEditingController _notesCtrl;
  late final TextEditingController _partsCtrl;
  late final TextEditingController _phoneCtrl;
  String _selectedLanguage = 'bilingual';
  bool _isLoading = false;

  static const Map<String, String> _statusMalayalamMap = {
    'received': 'വാഹനം സ്വീകരിച്ചു (Received)',
    'inspectionPending': 'പരിശോധന ബാക്കി (Inspection Pending)',
    'estimatePending':
        'എസ്റ്റിമേറ്റ് അനുമതിക്കായി കാത്തിരിക്കുന്നു (Estimate Pending)',
    'inProgress': 'പണി നടക്കുന്നു (In Progress)',
    'waitingForParts': 'പാർട്സുകൾ ആവശ്യമുണ്ട് (Waiting for Parts)',
    'readyForCollection': 'വാഹനം കൈപ്പറ്റാൻ തയ്യാറാണ് (Ready for Pickup)',
    'completed': 'പൂർത്തിയായി കൈമാറി (Completed & Delivered)',
    'custom': 'പ്രത്യേക അറിയിപ്പ് (Custom Update)',
  };

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.currentStatus;
    _notesCtrl = TextEditingController();
    _partsCtrl = TextEditingController();
    final initialNumber = widget.customerWhatsApp.isNotEmpty
        ? widget.customerWhatsApp
        : widget.customerPhone;
    _phoneCtrl = TextEditingController(text: initialNumber);
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    _partsCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  String _buildWhatsAppMessage() {
    final statusMl = _statusMalayalamMap[_selectedStatus] ?? _selectedStatus;
    return WhatsAppShareService.composeJobStatusMessageWithDetails(
      customerName: widget.customerName,
      garageName: widget.garageName,
      vehicleDisplay: widget.vehicleDisplay,
      jobNumber: widget.jobNumber,
      status: _selectedStatus,
      statusMalayalam: statusMl,
      notes: _notesCtrl.text.trim(),
      partsNeeded: _partsCtrl.text.trim(),
      language: _selectedLanguage,
    );
  }

  Future<void> _sendWhatsAppOnly() async {
    final msg = _buildWhatsAppMessage();
    final phone = _phoneCtrl.text.trim();
    await WhatsAppShareService.sendWhatsAppMessage(
      phoneNumber: phone,
      message: msg,
    );
  }

  void _submit({bool alsoOpenWhatsApp = false}) async {
    setState(() => _isLoading = true);
    final combinedNotes = [
      if (_partsCtrl.text.trim().isNotEmpty)
        'Parts Needed: ${_partsCtrl.text.trim()}',
      if (_notesCtrl.text.trim().isNotEmpty) _notesCtrl.text.trim(),
    ].join('\n');

    final success = await widget.onUpdateStatus(_selectedStatus, combinedNotes);

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        if (alsoOpenWhatsApp) {
          await _sendWhatsAppOnly();
        }
        if (mounted) {
          Navigator.pop(context);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;

    return AlertDialog(
      title: Text(
        'Inform Customer & Update Status',
        style: AppFonts.titleLarge(color: primaryTextColor),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppDropdown<String>(
              label: 'Work Status / നിലവിലെ അവസ്ഥ',
              value: _selectedStatus,
              onChanged: (val) {
                if (val != null) {
                  setState(() => _selectedStatus = val);
                }
              },
              items: const [
                AppDropdownItem(
                  value: 'received',
                  title: 'Received / സ്വീകരിച്ചു',
                  subtitle: 'Vehicle arrived at workshop',
                ),
                AppDropdownItem(
                  value: 'inspectionPending',
                  title: 'Inspection Pending / പരിശോധന ബാക്കി',
                  subtitle: 'Awaiting mechanic checkup',
                ),
                AppDropdownItem(
                  value: 'estimatePending',
                  title: 'Estimate Pending / എസ്റ്റിമേറ്റ് തയ്യാറാക്കുന്നു',
                  subtitle: 'Cost estimate in progress',
                ),
                AppDropdownItem(
                  value: 'inProgress',
                  title: 'In Progress / പണി നടക്കുന്നു',
                  subtitle: 'Mechanics working on repair',
                ),
                AppDropdownItem(
                  value: 'waitingForParts',
                  title: 'Parts Needed / പാർട്സുകൾ ആവശ്യമുണ്ട്',
                  subtitle: 'Awaiting required replacement parts',
                ),
                AppDropdownItem(
                  value: 'readyForCollection',
                  title: 'Ready for Collection / വാഹനം റെഡി',
                  subtitle: 'Service finished, ready for customer',
                ),
                AppDropdownItem(
                  value: 'completed',
                  title: 'Completed & Delivered / കൈമാറി',
                  subtitle: 'Delivered to customer',
                ),
                AppDropdownItem(
                  value: 'custom',
                  title: 'Custom Update / പ്രത്യേക സന്ദേശം',
                  subtitle: 'Custom message update',
                ),
              ],
            ),
            const SizedBox(height: 14),
            AppTextField(
              controller: _partsCtrl,
              label: 'Parts Needed / ആവശ്യമായ പാർട്സുകൾ',
              hint: 'e.g. Brake rotors, Synthetic oil, Air filter',
            ),
            const SizedBox(height: 14),
            AppTextField(
              controller: _notesCtrl,
              label: 'Message / വിവരണം',
              hint: 'e.g. Brake pads installed, wheel balancing done. Road test in progress.',
              maxLines: 3,
            ),
            const SizedBox(height: 14),
            AppTextField(
              controller: _phoneCtrl,
              label: 'Customer WhatsApp Number / വാട്സ്ആപ്പ് നമ്പർ',
              hint: '+91 98460 77112',
              helperText:
                  'Repair status updates will be sent to this WhatsApp number',
              keyboardType: TextInputType.phone,
              prefixIcon: const Icon(
                Icons.chat_bubble_outline_rounded,
                color: AppColors.success,
                size: 20,
              ),
            ),
            const SizedBox(height: 14),
            AppDropdown<String>(
              label: 'WhatsApp Language / ഭാഷ',
              value: _selectedLanguage,
              onChanged: (val) {
                if (val != null) {
                  setState(() => _selectedLanguage = val);
                }
              },
              items: const [
                AppDropdownItem(
                  value: 'bilingual',
                  title: 'Bilingual (English + മലയാളം)',
                ),
                AppDropdownItem(
                  value: 'malayalam',
                  title: 'മലയാളം (Malayalam)',
                ),
                AppDropdownItem(value: 'english', title: 'English'),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        OutlinedButton.icon(
          icon: const Icon(
            Icons.chat_rounded,
            color: AppColors.success,
            size: 18,
          ),
          label: const Text('WhatsApp Only'),
          onPressed: _isLoading ? null : _sendWhatsAppOnly,
        ),
        AppButton(
          label: 'Save & WhatsApp',
          icon: const Icon(Icons.send_rounded, size: 16),
          onPressed: () => _submit(alsoOpenWhatsApp: true),
          isLoading: _isLoading,
        ),
      ],
    );
  }
}
