import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../providers/contact_provider.dart';
import '../../models/contact_model.dart';
import '../../utils/app_utils.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/glass_card.dart'; // Import GlassCard

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch contacts when the screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ContactProvider>(context, listen: false).fetchContacts();
    });
  }

  void _showContactForm({ContactModel? contact}) {
    final isEditing = contact != null;
    final nameController = TextEditingController(text: contact?.name);
    final phoneController = TextEditingController(text: contact?.phoneNumber);
    final emailController = TextEditingController(text: contact?.email);
    final relationshipController = TextEditingController(text: contact?.relationship);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => Consumer<ContactProvider>(
        builder: (context, contactProvider, child) {
          return AlertDialog(
            backgroundColor: Theme.of(context).cardColor,
            title: Text(isEditing ? 'Edit Contact' : 'Add Emergency Contact', style: TextStyle(color: Theme.of(context).textTheme.titleLarge?.color)),
            content: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomTextField(
                      controller: nameController,
                      hintText: 'Name',
                      icon: Icons.person,
                      validator: (value) => value == null || value.isEmpty ? 'Name is required' : null,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: phoneController,
                      hintText: 'Phone Number',
                      icon: Icons.phone,
                      keyboardType: TextInputType.phone,
                      validator: (value) => value == null || value.isEmpty ? 'Phone number is required' : null,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: emailController,
                      hintText: 'Email (Optional)',
                      icon: Icons.email,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value != null && value.isNotEmpty && !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                          return 'Enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: relationshipController,
                      hintText: 'Relationship (Optional)',
                      icon: Icons.family_restroom,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel', style: TextStyle(color: Theme.of(context).primaryColor)),
              ),
              CustomButton(
                text: isEditing ? 'UPDATE' : 'ADD',
                isLoading: contactProvider.isLoading,
                onPressed: () async {
                  if (formKey.currentState?.validate() ?? false) {
                    try {
                      if (isEditing) {
                        await contactProvider.updateContact(
                          contact!.id,
                          nameController.text,
                          phoneController.text,
                          email: emailController.text.isEmpty ? null : emailController.text,
                          relationship: relationshipController.text.isEmpty ? null : relationshipController.text,
                        );
                        if (mounted) AppUtils.showSnackBar(context, 'Contact updated successfully!');
                      } else {
                        await contactProvider.addContact(
                          nameController.text,
                          phoneController.text,
                          email: emailController.text.isEmpty ? null : emailController.text,
                          relationship: relationshipController.text.isEmpty ? null : relationshipController.text,
                        );
                        if (mounted) AppUtils.showSnackBar(context, 'Contact added successfully!');
                      }
                      if (mounted) Navigator.pop(context);
                    } catch (e) {
                      if (mounted) AppUtils.showSnackBar(context, contactProvider.errorMessage ?? 'Failed to save contact.', isError: true);
                    }
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Contacts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showContactForm(),
          )
        ],
      ),
      body: Consumer<ContactProvider>(
        builder: (context, contactProvider, child) {
          if (contactProvider.isLoading && contactProvider.contacts.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          } else if (contactProvider.contacts.isEmpty) {
            return const Center(child: Text('No emergency contacts added yet.'));
          } else {
            return ListView.builder(
              itemCount: contactProvider.contacts.length,
              itemBuilder: (context, index) {
                final contact = contactProvider.contacts[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.7),
                      child: Text(
                        contact.name.isNotEmpty ? contact.name[0].toUpperCase() : '?',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(contact.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(contact.phoneNumber),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) async {
                        if (value == 'edit') {
                          _showContactForm(contact: contact);
                        } else if (value == 'delete') {
                          bool? confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Delete Contact'),
                              content: Text('Are you sure you want to delete ${contact.name}?'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                                ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            try {
                              await contactProvider.deleteContact(contact.id);
                              if (mounted) AppUtils.showSnackBar(context, 'Contact deleted successfully!');
                            } catch (e) {
                              if (mounted) AppUtils.showSnackBar(context, contactProvider.errorMessage ?? 'Failed to delete contact.', isError: true);
                            }
                          }
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'edit', child: Text('Edit')),
                        const PopupMenuItem(value: 'delete', child: Text('Delete')),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}