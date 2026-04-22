import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:guardian_angel_flutter/core/theme.dart' hide GlassCard; // Corrected import
import 'package:guardian_angel_flutter/utils/app_utils.dart'; // Corrected import
import 'package:guardian_angel_flutter/widgets/custom_button.dart'; // Corrected import
import 'package:guardian_angel_flutter/widgets/custom_text_field.dart'; // Corrected import
import 'package:guardian_angel_flutter/widgets/glass_card.dart'; // Corrected import
import 'package:guardian_angel_flutter/providers/journey_provider.dart'; // Corrected import
import 'package:guardian_angel_flutter/providers/contact_provider.dart'; // Corrected import
import 'package:guardian_angel_flutter/providers/settings_provider.dart'; // Corrected import
import 'package:guardian_angel_flutter/providers/sos_provider.dart'; // Corrected import
import 'package:guardian_angel_flutter/models/contact_model.dart'; // Corrected import

class SafeJourneyScreen extends StatefulWidget {
  const SafeJourneyScreen({super.key});

  @override
  State<SafeJourneyScreen> createState() => _SafeJourneyScreenState();
}

class _SafeJourneyScreenState extends State<SafeJourneyScreen> {
  final _destinationController = TextEditingController();
  LatLng? _selectedDestination;
  int _checkInInterval = 15; // Default minutes
  List<ContactModel> _selectedWatchers = [];

  @override
  void initState() {
    super.initState();
    _checkInInterval = context.read<SettingsProvider>().defaultCheckInIntervalMinutes; // Replaced Provider.of with context.read
  }

  @override
  void dispose() {
    _destinationController.dispose();
    super.dispose();
  }

  void _startJourney() async {
    if (_selectedWatchers.isEmpty) {
      if (mounted) AppUtils.showSnackBar(context, 'Please select at least one watcher.', isError: true);
      return;
    }

    final journeyProvider = Provider.of<JourneyProvider>(context, listen: false);
    try {
      await journeyProvider.startJourney(
        watchers: _selectedWatchers,
        endLocation: _selectedDestination,
        checkInIntervalMinutes: _checkInInterval,
      );
      if (mounted) AppUtils.showSnackBar(context, 'Safe Journey started!');
    } catch (e) {
      if (mounted) AppUtils.showSnackBar(context, journeyProvider.errorMessage ?? 'Failed to start journey.', isError: true);
    }
  }

  void _arrivedSafely() async {
    final journeyProvider = Provider.of<JourneyProvider>(context, listen: false);
    try {
      await journeyProvider.arrivedSafely();
      if (mounted) AppUtils.showSnackBar(context, 'Arrived safely! Journey ended.');
    } catch (e) {
      if (mounted) AppUtils.showSnackBar(context, journeyProvider.errorMessage ?? 'Failed to end journey.', isError: true);
    }
  }

  void _showWatcherSelection() {
    final contactProvider = context.read<ContactProvider>(); // Replaced Provider.of with context.read
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.6,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text('Select Watchers', style: Theme.of(context).textTheme.titleLarge),
              Expanded(
                child: ListView.builder(
                  itemCount: contactProvider.contacts.length,
                  itemBuilder: (context, index) {
                    final contact = contactProvider.contacts[index];
                    final isSelected = _selectedWatchers.contains(contact);
                    return CheckboxListTile(
                      title: Text(contact.name),
                      subtitle: Text(contact.phoneNumber),
                      value: isSelected,
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            _selectedWatchers.add(contact);
                          } else {
                            _selectedWatchers.remove(contact);
                          }
                        });
                        // This setState is local to the bottom sheet, so it won't rebuild the main screen
                        (context as Element).markNeedsBuild();
                      },
                    );
                  },
                ),
              ),
              CustomButton(text: 'Done', onPressed: () => Navigator.pop(context)),
            ],
          ),
        );
      },
    );
  }
 
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final journeyProvider = context.watch<JourneyProvider>(); // Replaced Provider.watch with context.watch

    return Scaffold(
      appBar: AppBar(
        title: const Text('Safe Journey'),
        backgroundColor: isDark ? GuardianTheme.darkGradientStart : GuardianTheme.primaryGradientStart,
        foregroundColor: Colors.white,
      ),
      body: Container( // Corrected Provider.watch usage
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [GuardianTheme.darkGradientStart, GuardianTheme.darkGradientEnd]
                : [GuardianTheme.primaryGradientStart, GuardianTheme.primaryGradientEnd],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: GlassCard(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Journey Protection',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  if (journeyProvider.isJourneyActive) ...[
                    _buildActiveJourneyView(journeyProvider),
                  ] else ...[
                    _buildStartJourneyView(),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStartJourneyView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Plan your safe journey by setting a destination and selecting trusted contacts to watch over you.', style: TextStyle(color: Colors.white70)),
        const SizedBox(height: 24),
        CustomTextField(
          controller: _destinationController,
          hintText: 'Destination (Optional)',
          icon: Icons.location_on,
          // TODO: Integrate Google Places Autocomplete for destination
        ),
        const SizedBox(height: 16),
        ListTile(
          title: const Text('Check-in Interval', style: TextStyle(color: Colors.white)),
          subtitle: Text('Every $_checkInInterval minutes', style: const TextStyle(color: Colors.white70)),
          trailing: DropdownButton<int>(
            value: _checkInInterval,
            dropdownColor: Theme.of(context).cardColor,
            onChanged: (int? newValue) {
              if (newValue != null) {
                setState(() => _checkInInterval = newValue);
              }
            },
            items: <int>[5, 10, 15, 20, 30, 60].map<DropdownMenuItem<int>>((int value) {
              return DropdownMenuItem<int>(value: value, child: Text('$value min', style: const TextStyle(color: Colors.white)));
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
        CustomButton(
          text: 'Select Watchers (${_selectedWatchers.length})',
          onPressed: _showWatcherSelection,
          backgroundColor: Colors.blueGrey,
        ),
        const SizedBox(height: 24),
        CustomButton(
          text: 'START JOURNEY',
          onPressed: _startJourney,
          isLoading: context.watch<JourneyProvider>().isLoading, // Replaced Provider.of with context.watch
        ),
      ],
    );
  }

  Widget _buildActiveJourneyView(JourneyProvider journeyProvider) {
    final journey = journeyProvider.currentJourney!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Journey Active since ${journey.formattedStartTime}', style: const TextStyle(color: Colors.white70)),
        const SizedBox(height: 8),
        Text('Next Check-in: ${journey.formattedNextCheckInTime}', style: const TextStyle(color: Colors.yellowAccent, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Text('Watchers: ${_selectedWatchers.map((c) => c.name).join(', ')}', style: const TextStyle(color: Colors.white)),
        const SizedBox(height: 24),
        CustomButton(
          text: 'I AM SAFE - CHECK IN',
          onPressed: () async {
            await journeyProvider.checkIn();
            if (mounted) AppUtils.showSnackBar(context, 'Checked in successfully!');
          },
          isLoading: journeyProvider.isLoading,
          backgroundColor: Colors.green,
        ),
        const SizedBox(height: 16),
        CustomButton(
          text: 'ARRIVED SAFELY',
          onPressed: _arrivedSafely,
          isLoading: journeyProvider.isLoading,
          backgroundColor: Colors.blue,
        ),
        const SizedBox(height: 16),
        CustomButton(
          text: 'TRIGGER SOS (Emergency)',
          onPressed: () {
            // Directly trigger SOS from here if needed
            context.read<SosProvider>().sendSos(type: 'JOURNEY_SOS'); // Replaced Provider.of with context.read
            if (mounted) AppUtils.showSnackBar(context, 'SOS triggered from Safe Journey!');
          },
          backgroundColor: Colors.red,
        ),
      ],
    );
  }
}
