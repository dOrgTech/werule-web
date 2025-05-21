import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For TextInputFormatters
// Assuming these are your actual project imports.
// If Org or TopMenu are in different locations, adjust the paths.
import 'package:Homebase/entities/org.dart'; // Your actual Org class
import 'package:Homebase/widgets/menu.dart';   // Your actual TopMenu class

// Enum to manage the current action mode
enum WrapperAction { wrap, unwrap }

class TokenWrapperUI extends StatefulWidget {
   // Assuming this might still be relevant for context, e.g. default contract or DAO info

  const TokenWrapperUI({super.key, });

  @override
  State<TokenWrapperUI> createState() => _TokenWrapperUIState();
}

class _TokenWrapperUIState extends State<TokenWrapperUI> {
  // --- State for the Wrapper UI ---
  final String _loggedInUserAddress = "0xUserAddress123abcDEF456ghi789jKL"; // Mock data
  double _availableBaseTokenBalance = 1500.75;  // e.g., ETH/DAI balance
  double _availableWrappedTokenBalance = 250.50; // e.g., WETH/wDAI balance

  // These would ideally come from the selected tokens or contract interaction
  final String _baseTokenSymbol = "BASE";    // e.g., ETH, MATIC
  final String _wrappedTokenSymbol = "wBASE"; // e.g., WETH, WMATIC

  WrapperAction _currentAction = WrapperAction.wrap; // Default to wrap mode

  final _amountController = TextEditingController();
  final _contractAddressController = TextEditingController(); // For wrapper contract address
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Example: Pre-fill with a default or last used address if available
    // _contractAddressController.text = "0xDefaultWrapperContractAddress...";
    // Or, if your Org object contains a relevant address:
    // _contractAddressController.text = widget.org.wrapperContractAddress ?? "";
  }

  @override
  void dispose() {
    _amountController.dispose();
    _contractAddressController.dispose(); // Don't forget to dispose new controllers
    super.dispose();
  }

  void _handleSubmittedAction() {
    // Validate the form
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final amount = double.tryParse(_amountController.text);
    final contractAddress = _contractAddressController.text.trim();

    // Amount validation (already handled by form validator, but good for explicit check)
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid positive amount.')),
      );
      return;
    }

    // Determine context based on _currentAction
    bool isWrapping = _currentAction == WrapperAction.wrap;
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

 
    setState(() => _isLoading = true);

    // Simulate network call or contract interaction
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return; // Check if the widget is still in the tree

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Simulated: $actionVerb $amount $fromSymbol to $toSymbol via $contractAddress! (Frontend Only)')),
      );
      setState(() {
        _isLoading = false;
        _amountController.clear(); // Optionally clear amount after action
        // Decide if you want to clear the contract address or persist it for next use
        // _contractAddressController.clear(); 
      });
    });
  }

  // Helper to build styled info rows
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
    final bool isWrappingMode = _currentAction == WrapperAction.wrap;
    final String currentInputTokenSymbol = isWrappingMode ? _baseTokenSymbol : _wrappedTokenSymbol;
    final double currentRelevantBalance = isWrappingMode ? _availableBaseTokenBalance : _availableWrappedTokenBalance;
    final String actionButtonText = isWrappingMode ? "Wrap $currentInputTokenSymbol" : "Unwrap $currentInputTokenSymbol";
    final String amountInputLabel = "Amount of $currentInputTokenSymbol to ${isWrappingMode ? 'Wrap' : 'Unwrap'}";


    return Scaffold(
      appBar: const TopMenu(), // Your existing TopMenu
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          children: [
            const SizedBox(height: 15), // Top spacing

            // --- Token Wrapper UI Section (Centered and Constrained Width) ---
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420), // Slightly wider for contract address field
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch, // Makes children like ElevatedButton fill the constrained width
                  children: [
                    // Toggle Buttons for Wrap/Unwrap
                    Center(
                      child: ToggleButtons(
                        isSelected: [
                          _currentAction == WrapperAction.wrap,
                          _currentAction == WrapperAction.unwrap,
                        ],
                        onPressed: (index) {
                          setState(() {
                            _currentAction = WrapperAction.values[index];
                            _amountController.clear();
                            _formKey.currentState?.reset(); // Reset validation state
                            // Optionally, clear contract address or load a default based on mode
                          });
                        },
                        borderRadius: BorderRadius.circular(8.0),
                        selectedBorderColor: colorScheme.primary,
                        selectedColor: colorScheme.onPrimary,
                        fillColor: colorScheme.primary,
                        color: colorScheme.onSurface.withOpacity(0.7),
                        constraints: const BoxConstraints(minHeight: 40.0, minWidth: 100.0), // Adjusted for potentially longer text
                        children: [
                          Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Text("Wrap $_baseTokenSymbol")),
                          Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Text("Unwrap $_wrappedTokenSymbol")),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    _buildInfoRow(context, "Your Logged-in Address:", _loggedInUserAddress, isMonospace: true),
                    _buildInfoRow(
                      context,
                      "Available $currentInputTokenSymbol Balance:",
                      "${currentRelevantBalance.toStringAsFixed(4)} $currentInputTokenSymbol",
                      isSelectable: false
                    ),
                    const SizedBox(height: 24),

                    // Contract Address Input Field
                    TextFormField(
                      controller: _contractAddressController,
                      decoration: InputDecoration(
                        labelText: "Wrapper Contract Address",
                        hintText: "0x...",
                        border: const OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: colorScheme.primary, width: 2.0),
                        ),
                        prefixIcon: Icon(Icons.gavel_rounded, color: colorScheme.secondary), // Or Icons.receipt_long, Icons.account_balance
                      ),
                      keyboardType: TextInputType.text, // Or TextInputType.visiblePassword to prevent suggestions if needed
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9a-zA-Z_]')), // Basic alphanum + underscore for addresses
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the contract address';
                        }
                        // Add more specific address validation if needed (e.g., length, prefix '0x')
                        if (!value.startsWith('0x') || value.length < 42) { // Basic Ethereum address check
                            return 'Please enter a valid contract address (e.g., 0x...)';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),


                    // Amount Input Field
                    TextFormField(
                      controller: _amountController,
                      decoration: InputDecoration(
                        labelText: amountInputLabel,
                        hintText: "0.0",
                        border: const OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: colorScheme.primary, width: 2.0),
                        ),
                        prefixIcon: Icon(isWrappingMode ? Icons.arrow_downward : Icons.arrow_upward, color: colorScheme.primary),
                        suffixText: currentInputTokenSymbol,
                      ),
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
                    const SizedBox(height: 20),

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
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(actionButtonText),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Text(
                        isWrappingMode
                          ? "This will wrap your $_baseTokenSymbol into $_wrappedTokenSymbol using the specified contract."
                          : "This will unwrap your $_wrappedTokenSymbol into $_baseTokenSymbol using the specified contract.",
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