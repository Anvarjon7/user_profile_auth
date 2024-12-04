import 'package:flutter/material.dart';

class MyTextBox extends StatelessWidget {
  final String text;
  final String sectionName;
  final void Function()? onPressed;

  const MyTextBox(
      {super.key,
      required this.text,
      required this.sectionName,
      required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5), //subtle blending
        // gradient: LinearGradient(
        //   colors: [
        //     Colors.blue.shade300.withOpacity(0.7),
        //     Colors.white.withOpacity(0.5),
        //   ],
        //   begin: Alignment.bottomRight,
        //   end: Alignment.topLeft,
        // ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              //section name
              Text(
                sectionName,
                style: const TextStyle(
                  color: Colors.black45,
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),

              //edit button
              IconButton(
                onPressed: onPressed,
                icon: Icon(
                  Icons.edit,
                  color: Colors.black45,
                  size: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),

          //text
          Text(
            text,
            style: TextStyle(
              color: Colors.black87,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
