import 'package:Homebase/widgets/newProposal.dart';
import 'package:Homebase/widgets/registryPropo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../entities/org.dart';
import '../entities/proposal.dart';

class GovernanceTokenOperationsWidget extends StatefulWidget {
  Org org;
  State proposalsState;
  Proposal p;
  bool isSetinfo = true;

  GovernanceTokenOperationsWidget(
      {required this.org, required this.p, required this.proposalsState});

  @override
  _GovernanceTokenOperationsWidgetState createState() =>
      _GovernanceTokenOperationsWidgetState();
}

class _GovernanceTokenOperationsWidgetState
    extends State<GovernanceTokenOperationsWidget> {
  String? _selectedOperation;
  bool _isFormValid = false;

  // Controllers for input fields
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  void _selectOperation(String operation) {
    setState(() {
      _selectedOperation = operation;
      _isFormValid = false;
      _addressController.clear();
      _amountController.clear();
    });
  }

  void doneSettingInfo() {
    setState(() {
      widget.isSetinfo = false;
    });
  }

  bool _isValidAddress(String address) {
    return address.startsWith("0x") && address.length == 42;
  }

  void _validateForm() {
    setState(() {
      _isFormValid = _isValidAddress(_addressController.text) &&
          _amountController.text.isNotEmpty &&
          double.tryParse(_amountController.text) != null;
    });
  }

  Widget _buildOperationSelection() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildOperationButton("Mint", Icons.add_circle),
        SizedBox(height: 30),
        _buildOperationButton("Burn", Icons.remove_circle),
      ],
    );
  }

  Widget _buildOperationButton(String title, IconData icon) {
    return SizedBox(
      width: 250,
      height: 130,
      child: ElevatedButton(
        onPressed: () => _selectOperation(title),
        style: ElevatedButton.styleFrom(
          backgroundColor: Color.fromARGB(255, 91, 91, 91),
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 30),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 30),
            SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 19),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMintView() {
    return _buildOperationView("Mint", "Mint tokens to a specified address.");
  }

  Widget _buildBurnView() {
    return _buildOperationView("Burn", "Burn tokens from a specified address.");
  }

  Widget _buildOperationView(String title, String description) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(
          width: 400,
          child: Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
        ),
        TextField(
          controller: _addressController,
          decoration: InputDecoration(
            labelText: 'Address',
            border: OutlineInputBorder(),
            hintText: "e.g., 0x1234567890abcdef...",
          ),
          onChanged: (_) => _validateForm(),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[a-fA-F0-9x]')),
          ],
        ),
        TextField(
          controller: _amountController,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: 'Amount',
            border: OutlineInputBorder(),
          ),
          onChanged: (_) => _validateForm(),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
          ],
        ),
      ],
    );
  }

  Widget _buildOperationViewContent() {
    switch (_selectedOperation) {
      case "Mint":
        return _buildMintView();
      case "Burn":
        return _buildBurnView();
      default:
        return _buildOperationSelection();
    }
  }

  void _resetToInitialView() {
    setState(() {
      _selectedOperation = null;
      _isFormValid = false;
      _addressController.clear();
      _amountController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.isSetinfo
        ? NewProposal(p: widget.p, next: doneSettingInfo)
        : Container(
            decoration: BoxDecoration(
                border: Border.all(color: Colors.grey, width: 0.3)),
            width: 600,
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: _buildOperationViewContent(),
                    ),
                  ),
                ),
                Container(
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  margin: const EdgeInsets.only(bottom: 50),
                  child: _selectedOperation != null
                      ? Center(
                          child: SubmitButton(
                              submit: _isFormValid ? _resetToInitialView : null,
                              isSubmitEnabled: _isFormValid))
                      : null,
                ),
              ],
            ),
          );
  }
}
