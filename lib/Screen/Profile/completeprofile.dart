import 'package:college/Screen/Profile/edit_club_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../Provider/profile_provider_student.dart';

class CompactProfileCompletion extends StatefulWidget {
  const CompactProfileCompletion({super.key});

  @override
  State<CompactProfileCompletion> createState() =>
      _CompactProfileCompletionState();
}

class _CompactProfileCompletionState
    extends State<CompactProfileCompletion> {
  bool isExpanded = false;
  @override
  Widget build(BuildContext context) {
    final missingFields = <String>[];
    final profile = context.watch<ProfileProvider>();

    if (profile.clubName.isEmpty) missingFields.add("Club Name");
    if (profile.username.isEmpty) missingFields.add("Username");
    if (profile.category == null) missingFields.add("Category");
    if (profile.bio.isEmpty) missingFields.add("Bio");
    if (profile.website.isEmpty) missingFields.add("Website");
    if (profile.email.isEmpty) missingFields.add("Email");
    if (profile.phoneNumber.isEmpty) missingFields.add("Phone Number");
    if (profile.avatarUrl.isEmpty) missingFields.add("Club Logo");
    if (profile.clubDescription.isEmpty) missingFields.add("Description");
    if (profile.facultyName.isEmpty) missingFields.add("Faculty Name");
    if (profile.facultyEmail.isEmpty) missingFields.add("Faculty Email");

    if (missingFields.isEmpty) {
      return const SizedBox.shrink();
    }

    final totalFields = 11;
    final completed = totalFields - missingFields.length;
    final progress = completed / totalFields;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white10),
        ),
        child: ExpansionTile(
          initiallyExpanded: false,
          iconColor: Colors.white,
          collapsedIconColor: Colors.white70,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.workspace_premium_rounded,
                    color: Color(0xFF4ADE80),
                  ),
                  SizedBox(width: 8),
                  Text(
                    "Complete Your Profile",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: progress,
                minHeight: 7,
                borderRadius: BorderRadius.circular(50),
                backgroundColor: Colors.white12,
                valueColor: const AlwaysStoppedAnimation(Color(0xFF4ADE80)),
              ),
              const SizedBox(height: 6),
              Text(
                "$completed / $totalFields fields completed",
                style: const TextStyle(
                  color: Color(0xFF4ADE80),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          childrenPadding: const EdgeInsets.all(16),
          children: [
            const Text(
              "Complete the remaining details to unlock all organiser features and improve your club's visibility.",
              style: TextStyle(
                color: Colors.white70,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 18),

            ...missingFields.map(
                  (field) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    const Icon(
                      Icons.radio_button_unchecked,
                      color: Colors.orange,
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        field,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4ADE80),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.edit),
                label: const Text(
                  "Complete Profile",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const EditClubProfileScreen(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(
      IconData icon,
      String title,
      bool completed,
      ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: completed
                ? const Color(0xFF4ADE80).withOpacity(.15)
                : Colors.white10,
            child: Icon(
              completed ? Icons.check : icon,
              color: completed
                  ? const Color(0xFF4ADE80)
                  : Colors.white70,
              size: 18,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
          if (completed)
            const Icon(
              Icons.check_circle,
              color: Color(0xFF4ADE80),
            )
          else
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white38,
              size: 14,
            ),
        ],
      ),
    );
  }
}