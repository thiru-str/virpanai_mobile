import 'package:flutter/material.dart';
import 'package:waioz/utility/app_config.dart';

class LocationComingSoon extends StatelessWidget {
  final VoidCallback onChangeLocation;
  const LocationComingSoon({super.key, required this.onChangeLocation});

  @override
  Widget build(BuildContext context) {
    const purple = Color(0xFF7C3AED);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [Color(0xFFF3EDFF), Color(0xFFFAF8FF), Colors.white],
        ),
      ),
      child: Column(children: [
        Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: const Color(0xFFEDE4FF),
            borderRadius: BorderRadius.circular(32),
          ),
          child: const Icon(Icons.shopping_bag_outlined, size: 72, color: purple),
        ),
        const SizedBox(height: 28),
        const Text('EXPANDING TO MORE NEIGHBOURHOODS',
          textAlign: TextAlign.center,
          style: TextStyle(color: purple, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1)),
        const SizedBox(height: 20),
        const Text('Good things are', textAlign: TextAlign.center,
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700)),
        const Text('coming soon.', textAlign: TextAlign.center,
          style: TextStyle(fontSize: 36, fontWeight: FontWeight.w700, color: purple)),
        const SizedBox(height: 18),
        const Text('Your neighbourhood is outside our delivery area for now. We look forward to bringing everyday essentials closer to you.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFF64748B), fontSize: 16, height: 1.6)),
        const SizedBox(height: 28),
        SizedBox(width: double.infinity, child: FilledButton.icon(
          onPressed: onChangeLocation,
          icon: const Icon(Icons.location_on_outlined),
          label: const Text('Change location'),
          style: FilledButton.styleFrom(
            backgroundColor: purple, foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        )),
        const SizedBox(height: 30),
        const Divider(color: Color(0xFFE4D9F9)),
        const SizedBox(height: 18),
        const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.eco_outlined, color: Color(0xFF059669), size: 22),
          SizedBox(width: 8),
          Flexible(child: Text('Fresh picks. Close to home.',
            style: TextStyle(fontWeight: FontWeight.w600))),
        ]),
        const SizedBox(height: 10),
        const Text('${AppConfig.appName} · Your everyday essentials',
          textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
      ]),
    );
  }
}
