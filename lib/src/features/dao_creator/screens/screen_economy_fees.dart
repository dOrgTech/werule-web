// lib/src/features/dao_creator/screens/screen_economy_fees.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:werule/src/features/dao_creator/providers/dao_creator_provider.dart';

class ScreenEconomyFees extends StatefulWidget {
  final DaoCreatorProvider provider;
  const ScreenEconomyFees({super.key, required this.provider});

  @override
  State<ScreenEconomyFees> createState() => _ScreenEconomyFeesState();
}

class _ScreenEconomyFeesState extends State<ScreenEconomyFees> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _platformFeeController;
  late final TextEditingController _authorFeeController;
  late final TextEditingController _arbitrationFeeController;

  @override
  void initState() {
    super.initState();
    _platformFeeController =
        TextEditingController(text: widget.provider.platformFee.toString());
    _authorFeeController =
        TextEditingController(text: widget.provider.authorFee.toString());
    _arbitrationFeeController =
        TextEditingController(text: widget.provider.arbitrationFee.toString());
  }

  @override
  void dispose() {
    _platformFeeController.dispose();
    _authorFeeController.dispose();
    _arbitrationFeeController.dispose();
    super.dispose();
  }

  void _saveAndNext() {
    if (_formKey.currentState!.validate()) {
      widget.provider.updateEconomyFees(
        platFee: double.tryParse(_platformFeeController.text) ?? 0.0,
        authFee: double.tryParse(_authorFeeController.text) ?? 0.0,
        arbFee: double.tryParse(_arbitrationFeeController.text) ?? 0.0,
      );
      widget.provider.nextStep();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(38.0),
      child: Center(
        child: Form(
          key: _formKey,
          child: SizedBox(
            width: 500,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('Economy Fees',
                    style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 50),
                _buildFeeTextField(
                  controller: _platformFeeController,
                  label: 'Platform Fee (%)',
                  description:
                      "The percentage of each project's payment that goes to the DAO treasury.",
                ),
                const SizedBox(height: 40),
                _buildFeeTextField(
                  controller: _authorFeeController,
                  label: 'Author Fee (%)',
                  description:
                      "The 'finder's fee' percentage paid to the project creator from the contractor's share.",
                ),
                const SizedBox(height: 40),
                _buildFeeTextField(
                  controller: _arbitrationFeeController,
                  label: 'Arbitration Fee (%)',
                  description:
                      "The percentage of a project's total value required to secure an arbiter. This fee is staked and paid to the arbiter.",
                ),
                const SizedBox(height: 86),
                SizedBox(
                  width: 700,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                          onPressed: widget.provider.previousStep,
                          child: const Text('< Back')),
                      ElevatedButton(
                          onPressed: _saveAndNext,
                          child: const Text('Save and Continue >')),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeeTextField({
    required TextEditingController controller,
    required String label,
    required String description,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
          ],
          decoration: InputDecoration(
            labelText: label,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a value';
            }
            final n = num.tryParse(value);
            if (n == null) {
              return 'Please enter a valid number';
            }
            if (n < 0 || n > 100) {
              return 'Value must be between 0 and 100';
            }
            return null;
          },
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
        ),
      ],
    );
  }
}
// lib/src/features/dao_creator/screens/screen_economy_fees.dart