import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../entities/project.dart';

class Arbitrate extends StatefulWidget {
  final Project project;
  Arbitrate({required this.project});

  @override
  _ArbitrateState createState() => _ArbitrateState();
}

class _ArbitrateState extends State<Arbitrate> {
  double sliderValue = 0;
  TextEditingController amountController = TextEditingController();
  bool showSlider = true;  // State variable to toggle between Slider and TextField

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text("Project: ${widget.project.name}"),
        Text("Amount in Escrow: ${widget.project.amountInEscrow}"),
        if (showSlider)
          Slider(
            value: sliderValue,
            min: 0,
            max: widget.project.amountInEscrow!.toDouble(),
            divisions: widget.project.amountInEscrow,
            label: sliderValue.round().toString(),
            onChanged: (double value) {
              setState(() {
                sliderValue = value;
              });
            },
          ),
        if (!showSlider)
          TextField(
            controller: amountController,
            decoration: InputDecoration(
              labelText: 'Enter amount',
            ),
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
            ],
          ),
        TextButton(
          onPressed: () {
            setState(() {
              showSlider = !showSlider;  // Toggle between Slider and TextField
            });
          },
          child: Text(showSlider ? "Switch to Text Input" : "Switch to Slider"),
        ),
        Text("Selected Amount: ${showSlider ? sliderValue.round() : amountController.text}"),
        // ... other elements that depend on sliderValue or text input
      ],
    );
  }
}
