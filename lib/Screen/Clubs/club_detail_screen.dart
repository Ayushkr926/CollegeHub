import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../Model/club.dart';
import '../../Provider/club_provider.dart';

class ClubDetailScreen extends StatelessWidget {
  const ClubDetailScreen({super.key, required this.club});

  final Club club;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ClubProvider>();
    final matchingClubs = provider.clubs.where((item) => item.id == club.id);
    final current = matchingClubs.isEmpty ? club : matchingClubs.first;
    final pending = current.joinRequestStatus == 'pending';
    return Scaffold(
      backgroundColor: const Color(0xFF101010),
      appBar: AppBar(
        title: const Text('Club Profile'),
        backgroundColor: const Color(0xFF101010),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          Center(
            child: CircleAvatar(
              radius: 48,
              backgroundColor: const Color(0xFF292929),
              backgroundImage: current.profilePicture.isNotEmpty
                  ? NetworkImage(current.profilePicture)
                  : null,
              child: current.profilePicture.isEmpty
                  ? const Icon(Icons.groups, color: Colors.white70, size: 42)
                  : null,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            current.name,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            current.category,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFFB0B0B0), fontSize: 14),
          ),
          const SizedBox(height: 20),
          _InfoRow(label: 'About', value: current.clubDescription.isEmpty ? 'No description available' : current.clubDescription),
          if (current.facultyName.isNotEmpty)
            _InfoRow(label: 'Faculty coordinator', value: current.facultyName),
          if (current.email.isNotEmpty) _InfoRow(label: 'Contact email', value: current.email),
          if (current.phoneNumber.isNotEmpty) _InfoRow(label: 'Contact phone', value: current.phoneNumber),
          _InfoRow(label: 'Members', value: current.members.toString()),
          const SizedBox(height: 22),
          SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: current.isJoined || pending || provider.isLoading
                  ? null
                  : () async {
                      final success = await context.read<ClubProvider>().joinClub(current.id);
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(success ? 'Join request sent for approval' : context.read<ClubProvider>().errorMessage ?? 'Could not send join request'),
                        ),
                      );
                    },
              icon: Icon(current.isJoined ? Icons.check : pending ? Icons.hourglass_top : Icons.send_outlined),
              label: Text(current.isJoined ? 'Member' : pending ? 'Request pending' : 'Request to join'),
              style: ElevatedButton.styleFrom(
                backgroundColor: current.isJoined || pending ? const Color(0xFF353535) : Colors.white,
                foregroundColor: current.isJoined || pending ? Colors.white : Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 9),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Color(0xFF9A9A9A), fontSize: 12)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 15)),
            const Divider(color: Color(0xFF303030), height: 18),
          ],
        ),
      );
}
