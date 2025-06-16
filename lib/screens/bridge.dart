import 'package:Homebase/entities/human.dart'; // Added for Human().address
import 'package:Homebase/entities/org.dart'; // Your actual Org import
// import 'package:Homebase/widgets/menu.dart'; // Removed as TopMenu is removed from Bridge
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For TextInputFormatters



class Bridge extends StatefulWidget {
  final Org org;
  const Bridge({super.key, required this.org});

  @override
  State<Bridge> createState() => _BridgeState();
}

// Enum to manage the current action mode
enum BridgeAction { wrap, unwrap }

class _BridgeState extends State<Bridge> {
  final double _availableBaseTokenBalance = 250.875; 
  final double _availableWrappedTokenBalance = 75.5; 
  BridgeAction _currentAction = BridgeAction.wrap; 
  final _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _handleSubmittedAction() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid positive amount.')),
      );
      return;
    }

    // Determine context based on _currentAction
    bool isWrapping = _currentAction == BridgeAction.wrap;
    String actionVerb = isWrapping ? "wrap" : "unwrap";
    String baseTokenSymbol = widget.org.wrapped?.substring(0, 6) ?? "BASE"; // Example for base symbol
    String wrappedTokenSymbol = widget.org.symbol ?? "WRAPPED";
    String fromSymbol = isWrapping ? baseTokenSymbol : wrappedTokenSymbol;
    String toSymbol = isWrapping ? wrappedTokenSymbol : baseTokenSymbol;
    double currentBalance = isWrapping ? _availableBaseTokenBalance : _availableWrappedTokenBalance;

    if (amount > currentBalance) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Insufficient $fromSymbol balance.')),
      );
      return;
    }

    print(
        'User wants to $actionVerb $amount $fromSymbol for DAO: ${widget.org.address}. User Address: ${Human().address}');
    
    setState(() => _isLoading = true);

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Simulated: $actionVerb $amount $fromSymbol to $toSymbol! (Frontend Only)')),
      );
      setState(() {
        _isLoading = false;
        _amountController.clear(); 
        if (isWrapping) {
        } else {
        }
      });
    });
  }

  Widget _buildInfoRow(BuildContext context, String label, String value, {bool isSelectable = true, bool isMonospace = false}) {
    final textTheme = Theme.of(context).textTheme;
    Widget valueWidget = Text(
      value,
      style: textTheme.bodyLarge?.copyWith(
        fontFamily: isMonospace ? 'monospace' : null,
      ),
    );

    if (isSelectable) {
      valueWidget = SelectableText(
        value,
        style: textTheme.bodyLarge?.copyWith(
          fontFamily: isMonospace ? 'monospace' : null,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          valueWidget,
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    // Determine current symbols and balance based on the toggle state
    final bool isWrappingMode = _currentAction == BridgeAction.wrap;

    // Use actual symbols from widget.org
    final String actualBaseTokenSymbol = widget.org.wrapped != null && widget.org.wrapped!.length >= 6
                                       ? "${widget.org.wrapped!.substring(0, 6)}.." // Placeholder, ideally fetch symbol
                                       : "BASE";
    final String actualWrappedTokenSymbol = widget.org.symbol ?? "WRAPPED";

    // final String pageTitle = isWrappingMode // Page title is part of Account screen now
    //     ? "Wrap $actualBaseTokenSymbol to $actualWrappedTokenSymbol"
    //     : "Unwrap $actualWrappedTokenSymbol to $actualBaseTokenSymbol";
    final String currentInputTokenSymbol = isWrappingMode ? actualBaseTokenSymbol : actualWrappedTokenSymbol;
    final double currentRelevantBalance = isWrappingMode ? _availableBaseTokenBalance : _availableWrappedTokenBalance; // Still mock
    final String actionButtonText = isWrappingMode ? "Wrap $currentInputTokenSymbol" : "Unwrap $currentInputTokenSymbol";
    final String amountInputLabel = "Amount of $currentInputTokenSymbol to ${isWrappingMode ? 'Wrap' : 'Unwrap'}";


    return Form( // Removed Scaffold and AppBar
      key: _formKey,
      child: ListView(
        shrinkWrap: true, // Added shrinkWrap
        physics: const NeverScrollableScrollPhysics(), // Added physics
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        children: [
          // Removed SizedBox(height: 15) as padding is handled by the Card in Account screen

            // --- Token Wrapper UI Section (Centered and Constrained Width) ---
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400), // Max width for the interactive section
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch, // Makes children like ElevatedButton fill the constrained width
                  children: [
                    const SizedBox(height: 20),
                    // Toggle Buttons for Wrap/Unwrap
                    Center( // Center the ToggleButtons themselves
                      child: ToggleButtons(
                        isSelected: [
                          _currentAction == BridgeAction.wrap,
                          _currentAction == BridgeAction.unwrap,
                        ],
                        onPressed: (index) {
                          setState(() {
                            _currentAction = BridgeAction.values[index];
                            _amountController.clear(); // Clear amount on mode switch
                            _formKey.currentState?.reset(); // Reset validation errors
                          });
                        },
                        borderRadius: BorderRadius.circular(8.0),
                        selectedBorderColor: colorScheme.primary,
                        selectedColor: colorScheme.onPrimary, // Text color when selected
                        fillColor: colorScheme.primary,       // Background when selected
                        color: colorScheme.onSurface.withOpacity(0.7), // Text color when not selected
                        constraints: const BoxConstraints(minHeight: 40.0, minWidth: 90.0), // Adjust for text
                        children: [
                          Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Text("Wrap $actualBaseTokenSymbol")),
                          Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Text("Unwrap $actualWrappedTokenSymbol")),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // _buildInfoRow(context, "Your Address:", _loggedInUserAddress, isMonospace: true), // Removed user address display
                    _buildInfoRow(
                      context,
                      "Available $currentInputTokenSymbol:", // Dynamic balance label
                      "${currentRelevantBalance.toStringAsFixed(4)} $currentInputTokenSymbol",
                      isSelectable: false
                    ),
                    
                    const SizedBox(height: 24),

                    // Amount Input Field
                    TextFormField(
                      controller: _amountController,
                      decoration: InputDecoration(
                        labelText: amountInputLabel, // Dynamic label
                        hintText: "0.0",
                        border: const OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: colorScheme.primary, width: 2.0),
                        ),
                        prefixIcon: Icon(isWrappingMode ? Icons.arrow_downward : Icons.arrow_upward, color: colorScheme.primary), // Indicative icons
                        suffixText: currentInputTokenSymbol, // Dynamic suffix
                      ),
                      textAlign: TextAlign.start, // Default, but good to be explicit
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,18}$')),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an amount';
                        }
                        final amount = double.tryParse(value);
                        if (amount == null) {
                          return 'Please enter a valid number';
                        }
                        if (amount <= 0) {
                          return 'Amount must be greater than zero';
                        }
                        if (amount > currentRelevantBalance) {
                          return 'Exceeds available $currentInputTokenSymbol';
                        }
                        return null;
                      },
                    ),
                    // "Max" button
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          String maxBalanceStr = currentRelevantBalance.toStringAsFixed(18);
                          maxBalanceStr = maxBalanceStr.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
                          _amountController.text = maxBalanceStr;
                          _amountController.selection = TextSelection.fromPosition(TextPosition(offset: _amountController.text.length));
                        },
                        child: Text(
                          "Max",
                          style: TextStyle(color: colorScheme.primary),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20), // Adjusted spacing

                    // Action Button (Wrap/Unwrap)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      onPressed: _isLoading ? null : _handleSubmittedAction,
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white), // Or use colorScheme.onPrimary
                              ),
                            )
                          : Text(actionButtonText), // Dynamic button text
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Text(
                        isWrappingMode
                          ? "You will receive $actualWrappedTokenSymbol."
                          : "You will receive $actualBaseTokenSymbol.",
                        style: textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
           
             const SizedBox(height: 30), // Some padding at the bottom
          ],
        ), // This closes the ListView
    ); // This closes the Form
  }
}