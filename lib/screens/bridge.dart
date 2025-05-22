import 'package:Homebase/entities/org.dart'; // Your actual Org import
import 'package:Homebase/widgets/menu.dart';
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
  final String _loggedInUserAddress = "0xAbc123Def456Ghi789Jkl012Mno345Pqr678"; // Mock
  final double _availableBaseTokenBalance = 250.875;  // e.g., TKN balance
  final double _availableWrappedTokenBalance = 75.5; // e.g., wTKN balance - Mock data

  final String _baseTokenSymbol = "TKN";
  final String _wrappedTokenSymbol = "wTKN";

  BridgeAction _currentAction = BridgeAction.wrap; // Default to wrap mode

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
    // This check should be covered by the validator, but it's good for belt-and-suspenders
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid positive amount.')),
      );
      return;
    }

    // Determine context based on _currentAction
    bool isWrapping = _currentAction == BridgeAction.wrap;
    String actionVerb = isWrapping ? "wrap" : "unwrap";
    String fromSymbol = isWrapping ? _baseTokenSymbol : _wrappedTokenSymbol;
    String toSymbol = isWrapping ? _wrappedTokenSymbol : _baseTokenSymbol;
    double currentBalance = isWrapping ? _availableBaseTokenBalance : _availableWrappedTokenBalance;

    if (amount > currentBalance) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Insufficient $fromSymbol balance.')),
      );
      return;
    }

    print(
        'User wants to $actionVerb $amount $fromSymbol for DAO: ${widget.org.address}. User Address: $_loggedInUserAddress');
    
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
        _amountController.clear(); // Optionally clear after action

        // --- MOCK BALANCE UPDATE (for demonstration) ---
        // In a real app, you'd fetch new balances from the blockchain
        if (isWrapping) {
          // _availableBaseTokenBalance -= amount; // Be careful with floating point arithmetic
          // _availableWrappedTokenBalance += amount;
        } else {
          // _availableWrappedTokenBalance -= amount;
          // _availableBaseTokenBalance += amount;
        }
        // --- END MOCK BALANCE UPDATE ---
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
    final String pageTitle = isWrappingMode
        ? "Wrap $_baseTokenSymbol to $_wrappedTokenSymbol"
        : "Unwrap $_wrappedTokenSymbol to $_baseTokenSymbol";
    final String currentInputTokenSymbol = isWrappingMode ? _baseTokenSymbol : _wrappedTokenSymbol;
    // final String currentOutputTokenSymbol = isWrappingMode ? _wrappedTokenSymbol : _baseTokenSymbol; // If needed for descriptive text
    final double currentRelevantBalance = isWrappingMode ? _availableBaseTokenBalance : _availableWrappedTokenBalance;
    final String actionButtonText = isWrappingMode ? "Wrap $currentInputTokenSymbol" : "Unwrap $currentInputTokenSymbol";
    final String amountInputLabel = "Amount of $currentInputTokenSymbol to ${isWrappingMode ? 'Wrap' : 'Unwrap'}";


    return Scaffold(
      appBar: const TopMenu(),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0), // Adjusted overall padding
          children: [
         
            const SizedBox(height: 15),

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
                          Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Text("Wrap $_baseTokenSymbol")),
                          Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Text("Unwrap $_wrappedTokenSymbol")),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    _buildInfoRow(context, "Your Address:", _loggedInUserAddress, isMonospace: true),
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
                          ? "You will receive $_wrappedTokenSymbol."
                          : "You will receive $_baseTokenSymbol.",
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
        ),
      ),
    );
  }
}