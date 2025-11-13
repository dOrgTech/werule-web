// lib/src/features/dao_detail/widgets/token_bridge_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:werule/src/models/org.dart';
import 'package:werule/src/services/token_bridge_service.dart';
import 'package:werule/src/utils/reusable.dart';

enum BridgeAction { wrap, unwrap }

class TokenBridgeWidget extends StatefulWidget {
  final Org dao;
  final String userAddress;

  const TokenBridgeWidget({
    super.key,
    required this.dao,
    required this.userAddress,
  });

  @override
  State<TokenBridgeWidget> createState() => _TokenBridgeWidgetState();
}

class _TokenBridgeWidgetState extends State<TokenBridgeWidget> {
  final _bridgeService = TokenBridgeService();
  final _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  BridgeAction _currentAction = BridgeAction.wrap;
  bool _isLoading = false;
  bool _isFetchingBalances = true;

  BigInt _underlyingBalance = BigInt.zero;
  BigInt _wrappedBalance = BigInt.zero;
  String _underlyingSymbol = 'TOKEN';
  int _decimals = 18;

  @override
  void initState() {
    super.initState();
    _fetchBalancesAndMetadata();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _fetchBalancesAndMetadata() async {
    setState(() => _isFetchingBalances = true);

    try {
      // Fetch balances and metadata in parallel
      final results = await Future.wait([
        _bridgeService.getTokenBalance(widget.dao.underlyingToken!, widget.userAddress),
        _bridgeService.getTokenBalance(widget.dao.govTokenAddress, widget.userAddress),
        _bridgeService.getTokenSymbol(widget.dao.underlyingToken!),
        _bridgeService.getTokenDecimals(widget.dao.underlyingToken!),
      ]);

      setState(() {
        _underlyingBalance = results[0] as BigInt;
        _wrappedBalance = results[1] as BigInt;
        _underlyingSymbol = results[2] as String;
        _decimals = results[3] as int;
        _isFetchingBalances = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isFetchingBalances = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching balances: $e')),
        );
      }
    }
  }

  String _formatBalance(BigInt balance, int decimals) {
    return formatTotalSupply(balance.toString(), decimals);
  }

  void _handleSubmittedAction() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final amountStr = _amountController.text.trim();
    if (amountStr.isEmpty) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Parse the amount to BigInt (convert from decimal to wei)
      final amountDouble = double.parse(amountStr);
      final amountWei = (amountDouble * BigInt.from(10).pow(_decimals).toDouble()).toInt();
      final amountBigInt = BigInt.from(amountWei);

      if (_currentAction == BridgeAction.wrap) {
        await _bridgeService.wrapTokens(
          widget.dao.govTokenAddress,
          widget.dao.underlyingToken!,
          amountBigInt.toString(),
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Successfully wrapped $amountStr $_underlyingSymbol!')),
          );
        }
      } else {
        await _bridgeService.unwrapTokens(
          widget.dao.govTokenAddress,
          amountBigInt.toString(),
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Successfully unwrapped $amountStr ${widget.dao.symbol}!')),
          );
        }
      }

      // Refresh balances after successful transaction
      await _fetchBalancesAndMetadata();
      _amountController.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Transaction failed: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[400],
                ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final bool isWrappingMode = _currentAction == BridgeAction.wrap;
    final String currentInputTokenSymbol = isWrappingMode ? _underlyingSymbol : widget.dao.symbol;
    final BigInt currentRelevantBalance = isWrappingMode ? _underlyingBalance : _wrappedBalance;
    final String actionButtonText = isWrappingMode
        ? "Wrap $currentInputTokenSymbol"
        : "Unwrap ${widget.dao.symbol}";
    final String amountInputLabel = "Amount of $currentInputTokenSymbol to ${isWrappingMode ? 'Wrap' : 'Unwrap'}";

    if (_isFetchingBalances) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(48.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Form(
      key: _formKey,
      child: ListView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  // Toggle Buttons for Wrap/Unwrap
                  Center(
                    child: ToggleButtons(
                      isSelected: [
                        _currentAction == BridgeAction.wrap,
                        _currentAction == BridgeAction.unwrap,
                      ],
                      onPressed: (index) {
                        setState(() {
                          _currentAction = BridgeAction.values[index];
                          _amountController.clear();
                          _formKey.currentState?.reset();
                        });
                      },
                      borderRadius: BorderRadius.circular(8.0),
                      selectedBorderColor: colorScheme.primary,
                      selectedColor: colorScheme.onPrimary,
                      fillColor: colorScheme.primary,
                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                      constraints: const BoxConstraints(minHeight: 40.0, minWidth: 90.0),
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text("Wrap $_underlyingSymbol"),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text("Unwrap ${widget.dao.symbol}"),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildInfoRow(
                    context,
                    "Available $currentInputTokenSymbol:",
                    "${_formatBalance(currentRelevantBalance, _decimals)} $currentInputTokenSymbol",
                  ),
                  const SizedBox(height: 24),
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
                      prefixIcon: Icon(
                        isWrappingMode ? Icons.arrow_downward : Icons.arrow_upward,
                        color: colorScheme.primary,
                      ),
                      suffixText: currentInputTokenSymbol,
                    ),
                    textAlign: TextAlign.start,
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
                      // Convert to BigInt for comparison
                      final amountWei = (amount * BigInt.from(10).pow(_decimals).toDouble()).toInt();
                      final amountBigInt = BigInt.from(amountWei);
                      if (amountBigInt > currentRelevantBalance) {
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
                        final maxBalance = currentRelevantBalance.toDouble() / BigInt.from(10).pow(_decimals).toDouble();
                        String maxBalanceStr = maxBalance.toStringAsFixed(_decimals);
                        maxBalanceStr = maxBalanceStr.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
                        _amountController.text = maxBalanceStr;
                        _amountController.selection = TextSelection.fromPosition(
                          TextPosition(offset: _amountController.text.length),
                        );
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
                      textStyle: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
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
                          ? "You will receive ${widget.dao.symbol}."
                          : "You will receive $_underlyingSymbol.",
                      style: theme.textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
