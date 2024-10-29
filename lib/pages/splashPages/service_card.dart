import 'package:flutter/material.dart';

class ServiceCard extends StatefulWidget {
  const ServiceCard({super.key});

  @override
  State<ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends State<ServiceCard> {
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Container(
            decoration: BoxDecoration(
                color: Colors.green[800],
                borderRadius: const BorderRadius.only(topRight: Radius.circular(20),
                    topLeft: Radius.circular(20))
            ),
            height: double.infinity,
            width: double.infinity,
            child: const Column(
              children: [
                Expanded(child: Icon(Icons.bolt, color: Colors.green)),
                Expanded(child: Icon(Icons.play_arrow, color: Colors.green)),
                Expanded(child: Icon(Icons.discount, color: Colors.green)),
                Expanded(child: Icon(Icons.security, color: Colors.green)),
              ],

            )
        )
    );
  }
}
