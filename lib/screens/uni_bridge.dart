import 'dart:async';
import 'dart:convert'; 
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:Homebase/entities/human.dart';
import 'package:flutter_web3_provider/ethers.dart';
import 'package:Homebase/widgets/menu.dart';
import 'package:flutter_web3_provider/ethereum.dart'; 
import 'package:js/js_util.dart' show promiseToFuture, callMethod, getProperty; // Ensured getProperty is here
 enum WrapperAction { wrap, unwrap } // Corrected: No underscore prefix for enum type

// --- ABIs (Human-Readable) ---
const List<String> erc20ApproveAbiHumanReadable = [
  "function approve(address spender, uint256 value) returns (bool)"
];

const List<String> wrapperContractAbiHumanReadable = [
  "function depositFor(address account, uint256 value)",
  "function withdrawTo(address account, uint256 value)" // For unwrap
];

enum TransactionProgress { 
  idle,
  awaitingUserAddress,
  fetchingUserAddressFailed,
  ready,
  awaitingApprovalSignature,
  sendingApproval,
  approvalTxSubmitted,
  approvalComplete,
  awaitingWrapSignature,
  sendingWrap,
  wrapTxSubmitted,
  wrapComplete,
  awaitingUnwrapSignature,
  sendingUnwrap,
  unwrapTxSubmitted,
  unwrapComplete,
  error,
}

class TokenWrapperUI extends StatefulWidget {
  const TokenWrapperUI({super.key});

  @override
  State<TokenWrapperUI> createState() => _TokenWrapperUIState();
}

class _TokenWrapperUIState extends State<TokenWrapperUI> {
  String? _loggedInUserAddress;

  WrapperAction _currentAction = WrapperAction.wrap;
  TransactionProgress _currentProgress = TransactionProgress.awaitingUserAddress;
  String _progressMessage = "Initializing...";
  String _errorMessage = "";

  final _amountController = TextEditingController();
  final _baseTokenAddressController = TextEditingController(); 
  final _wrapperContractAddressController = TextEditingController(); 
  final _wrappedTokenForUnwrapAddressController = TextEditingController(); 
  
  // Reinstated _formKey
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Human().web3user != null) {
        _fetchUserAddress();
      } else {
        setState(() {
          _currentProgress = TransactionProgress.fetchingUserAddressFailed;
          _errorMessage = "Wallet provider not initialized. Please connect your wallet first.";
          _progressMessage = _getProgressDisplayMessageFull();
        });
      }
    });
  }

  Future<void> _fetchUserAddress() async {
    if (Human().web3user == null) {
      setState(() {
        _currentProgress = TransactionProgress.fetchingUserAddressFailed;
        _errorMessage = "Wallet provider not available.";
        _progressMessage = _getProgressDisplayMessageFull();
      });
      return;
    }
    setState(() {
      _currentProgress = TransactionProgress.awaitingUserAddress;
      _progressMessage = _getProgressDisplayMessageFull();
    });
    try {
      final Signer signer = Human().web3user!.getSigner();
      final String address = await promiseToFuture<String>(signer.getAddress());
      if (!mounted) return;
      if (address.isNotEmpty) {
        _loggedInUserAddress = address;
        setState(() {
          _currentProgress = TransactionProgress.ready;
          _progressMessage = _getProgressDisplayMessageFull();
        });
      } else {
        throw Exception("Fetched address was null or empty.");
      }
    } catch (e) {
      print("Error fetching user address: $e");
      if (!mounted) return;
      _loggedInUserAddress = null;
      setState(() {
        _currentProgress = TransactionProgress.fetchingUserAddressFailed;
        _errorMessage = "Could not get user address: ${e.toString()}";
        _progressMessage = _getProgressDisplayMessageFull();
      });
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _baseTokenAddressController.dispose();
    _wrapperContractAddressController.dispose();
    _wrappedTokenForUnwrapAddressController.dispose();
    super.dispose();
  }

  String _getAmountStringForTx(String amountInputByUser) {
    final cleanAmountStr = amountInputByUser.replaceAll(RegExp(r'[^0-9]'), '');
     if (cleanAmountStr.isEmpty) return "0";
    try {
      BigInt.parse(cleanAmountStr);
      return cleanAmountStr;
    } catch (e) {
      print("Error validating user input amount string '$cleanAmountStr' for transaction: $e");
      return "0";
    }
  }

  bool _isValidEthereumAddress(String address) {
    return address.startsWith('0x') && address.length == 42;
  }

  bool _isProcessingTransaction() {
     return !(_currentProgress == TransactionProgress.ready ||
             _currentProgress == TransactionProgress.wrapComplete ||
             _currentProgress == TransactionProgress.unwrapComplete ||
             _currentProgress == TransactionProgress.error ||
             _currentProgress == TransactionProgress.fetchingUserAddressFailed ||
             _currentProgress == TransactionProgress.idle);
  }

  void _resetStateAfterTransaction() {
    _amountController.clear();
    // Optionally clear other fields
    // _baseTokenAddressController.clear();
    // _wrappedTokenForUnwrapAddressController.clear();
  }

  String _getProgressDisplayMessageFull() {
    if (_currentProgress == TransactionProgress.error) return "Error: $_errorMessage";
    
    // Use a temporary variable for hash display to avoid 'Error: Tx Hash: ...'
    String displayMessage = "";
    bool hashAvailable = _errorMessage.startsWith("Tx Hash:");
    String txHashForDisplay = hashAvailable ? _errorMessage.split(':').last.trim() : "";

    switch (_currentProgress) {
      case TransactionProgress.idle: displayMessage = "Initializing..."; break;
      case TransactionProgress.awaitingUserAddress: displayMessage = "Fetching user address..."; break;
      case TransactionProgress.fetchingUserAddressFailed: displayMessage = _errorMessage.isNotEmpty && !hashAvailable ? "Error: $_errorMessage" : "Failed to get address. Connect wallet & refresh."; break;
      case TransactionProgress.ready: displayMessage = _loggedInUserAddress != null ? "Ready." : "Initializing wallet..."; break;
      
      case TransactionProgress.awaitingApprovalSignature: displayMessage = "1/2: Approve in wallet..."; break;
      case TransactionProgress.sendingApproval: displayMessage = "1/2: Submitting approval..."; break;
      case TransactionProgress.approvalTxSubmitted: displayMessage = "1/2: Approval submitted (Tx: $txHashForDisplay). Waiting..."; break;
      case TransactionProgress.approvalComplete: displayMessage = "1/2: Approval successful!"; break;
      
      case TransactionProgress.awaitingWrapSignature: displayMessage = "2/2: Confirm wrap in wallet..."; break;
      case TransactionProgress.sendingWrap: displayMessage = "2/2: Submitting wrap..."; break;
      case TransactionProgress.wrapTxSubmitted: displayMessage = "2/2: Wrap submitted (Tx: $txHashForDisplay). Waiting..."; break;
      case TransactionProgress.wrapComplete: displayMessage = "Wrap successful!"; break;

      case TransactionProgress.awaitingUnwrapSignature: displayMessage = "Confirm unwrap in wallet..."; break;
      case TransactionProgress.sendingUnwrap: displayMessage = "Submitting unwrap..."; break;
      case TransactionProgress.unwrapTxSubmitted: displayMessage = "Unwrap submitted (Tx: $txHashForDisplay). Waiting..."; break;
      case TransactionProgress.unwrapComplete: displayMessage = "Unwrap successful!"; break;
      default: displayMessage = "Processing...";
    }
    return displayMessage;
  }

  Future<bool> _executeTransaction(
      String stepName,
      String contractAddress,
      List<String> contractAbiHumanReadable,
      String methodName,
      List<dynamic> methodArgs, 
      TransactionProgress submittedState
      ) async {

    if (Human().web3user == null) {
      _errorMessage = "Wallet provider not available.";
      return false;
    }
    final Web3Provider provider = Human().web3user!; 
    final Signer signer = provider.getSigner();

    try {
      Contract contract = Contract(contractAddress, contractAbiHumanReadable, provider);
      contract = contract.connect(signer);

      print("$stepName: Calling $methodName on $contractAddress with params: $methodArgs.");
      
      final transactionResponseJs = await promiseToFuture(callMethod(contract, methodName, methodArgs));

      final String txHash = json.decode(stringify(transactionResponseJs))["hash"];
      print("$stepName tx hash: $txHash");

      // Store hash temporarily in _errorMessage for display purposes ONLY
      _errorMessage = "Tx Hash: $txHash"; 
      if (mounted) {
        setState(() {
          _currentProgress = submittedState; 
          // _progressMessage will be updated by build method calling _getProgressDisplayMessageFull
        });
      }
      
      final txReceiptJs = await promiseToFuture(provider.waitForTransaction(txHash, 1)); 

      final receiptStatus = json.decode(stringify(txReceiptJs))["status"];
      final int status = (receiptStatus is int) ? receiptStatus : int.tryParse(receiptStatus.toString()) ?? 0;

      _errorMessage = ""; // Clear temporary hash storage

      if (status == 1) {
        final String receiptTxHash = json.decode(stringify(txReceiptJs))["transactionHash"];
        print("$stepName successful. Receipt Tx Hash: $receiptTxHash");
        return true;
      } else {
        _errorMessage = "$stepName transaction failed (status $status).";
        final String? revertReason = _tryDecodeRevertReason(txReceiptJs);
        if (revertReason != null && revertReason.isNotEmpty) {
          _errorMessage += " Reason: $revertReason";
        } else if (revertReason == "") {
           _errorMessage += " (Reverted without explicit reason)";
        }
        print(_errorMessage);
        return false;
      }
    } catch (e, s) {
      _errorMessage = "Exception during $stepName: ${e.toString()}";
      // Check for user rejection specifically
      if (e.toString().toLowerCase().contains('user rejected') || 
          (getProperty(e, 'code') == 4001) || // Standard MetaMask user denial code
          (getProperty(e, 'code') == 'ACTION_REJECTED') // Ethers.js user denial code for operations
         ) {
        _errorMessage = "$stepName rejected by user.";
      }
      print(_errorMessage);
      print("Stack trace for $stepName exception: $s");
      return false;
    }
  }

  String? _tryDecodeRevertReason(dynamic txReceiptJs) {
    try {
      final receiptMap = json.decode(stringify(txReceiptJs));
      final dynamic errorDataField = receiptMap['data']; 
      String? revertDataHex;

      if (errorDataField is String) {
        revertDataHex = errorDataField;
      } else if (errorDataField is Map && errorDataField.containsKey('data') && errorDataField['data'] is String) {
        revertDataHex = errorDataField['data'];
      } else if (errorDataField is Map && errorDataField.containsKey('message')) {
         String nestedMessage = errorDataField['message'].toString().toLowerCase();
         String prefix = "execution reverted";
         if (nestedMessage.contains(prefix)) {
            String potentialReason = nestedMessage.substring(nestedMessage.indexOf(prefix) + prefix.length).trim();
            if (potentialReason.startsWith(':')) potentialReason = potentialReason.substring(1).trim();
            if (potentialReason.isNotEmpty) return potentialReason;
         }
      }

      if (revertDataHex == "0x") return ""; 

      if (revertDataHex != null && revertDataHex.startsWith('0x08c379a0')) {
        String reasonPayload = revertDataHex.substring(10); 
        if (reasonPayload.length >= 128) { 
            String lengthHex = reasonPayload.substring(64, 128);
            int length = int.tryParse(lengthHex, radix: 16) ?? 0;
            if (length > 0 && reasonPayload.length >= 128 + (length * 2)) {
                String strHex = reasonPayload.substring(128, 128 + (length * 2));
                List<int> bytes = [];
                for (int i = 0; i < strHex.length; i += 2) {
                    bytes.add(int.parse(strHex.substring(i, i + 2), radix: 16));
                }
                return utf8.decode(bytes, allowMalformed: true).replaceAll(RegExp(r'\u0000+$'), '');
            } else if (length == 0) {
                return ""; 
            }
        }
      }
    } catch (e) {
      print("Could not decode revert reason from receipt: $e");
    }
    return null;
  }


  void _handleSubmittedAction() async {
    if (!(_formKey.currentState?.validate() ?? false)) return; // Use reinstated _formKey

    if (_loggedInUserAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User address not available...')));
      _fetchUserAddress(); return;
    }

    final amountInputByUser = _amountController.text;
    final String amountStringForTx = _getAmountStringForTx(amountInputByUser); 
    
    try {
      if (BigInt.parse(amountStringForTx) <= BigInt.zero) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Amount must be > 0.'))); return;
      }
    } catch (e) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid amount.'))); return;
    }

    final wrapperContractAddr = _wrapperContractAddressController.text.trim();
    // _errorMessage is cleared before each new operation sequence
    setState(() { _errorMessage = ""; });

    if (_currentAction == WrapperAction.wrap) {
      final baseTokenAddr = _baseTokenAddressController.text.trim();

      setState(() {
        _currentProgress = TransactionProgress.awaitingApprovalSignature;
      });

      bool approvalSuccess = await _executeTransaction(
        "Approval", baseTokenAddr, erc20ApproveAbiHumanReadable, "approve",
        [wrapperContractAddr, amountStringForTx],
        TransactionProgress.approvalTxSubmitted
      );

      if (!mounted) return;
      if (!approvalSuccess) {
        setState(() { _currentProgress = TransactionProgress.error; });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_errorMessage.isNotEmpty ? _errorMessage : 'Approval failed.')));
        _setIdleAfterDelay(); return;
      }
      
      setState(() { _currentProgress = TransactionProgress.approvalComplete; });
      if (!mounted) return;

      setState(() { _currentProgress = TransactionProgress.awaitingWrapSignature; });

      bool depositSuccess = await _executeTransaction(
        "Wrap/Deposit", wrapperContractAddr, wrapperContractAbiHumanReadable, "depositFor",
        [_loggedInUserAddress!, amountStringForTx],
        TransactionProgress.wrapTxSubmitted
      );
      
      if (!mounted) return;
      if (depositSuccess) {
        setState(() { _currentProgress = TransactionProgress.wrapComplete; });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Wrap successful!')));
        _resetStateAfterTransaction();
      } else {
         setState(() { _currentProgress = TransactionProgress.error; });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_errorMessage.isNotEmpty ? _errorMessage : 'Wrap/Deposit failed.')));
      }
    } else { // Unwrap
      setState(() { _currentProgress = TransactionProgress.awaitingUnwrapSignature; });
      
      // String wrappedTokenAddressForUnwrap = _wrappedTokenForUnwrapAddressController.text.trim();
      // This address is for user's info. The transaction is sent to wrapperContractAddr.
      
      // **CRITICAL for UNWRAP:**
      // The `withdrawTo` function on the wrapper contract needs two parameters:
      // 1. `account`: The address to send the unwrapped base tokens to (this is `_loggedInUserAddress`).
      // 2. `value`: The amount of *wrapped tokens* to unwrap. The user inputs this amount.
      //    It's crucial that the wrapper contract either:
      //    a) Burns this `value` of wrapped tokens from `msg.sender`'s balance (if `msg.sender` is the one holding wrapped tokens).
      //    b) Or, if the wrapper holds wrapped tokens on behalf of users, it deducts from an internal ledger for `msg.sender`.
      //    The current code assumes the user (`_loggedInUserAddress`) holds the wrapped tokens, and `withdrawTo` will facilitate their removal.
      //    **NO APPROVAL FOR WRAPPED TOKEN is currently implemented.** If the wrapper needs to `transferFrom` the wrapped tokens
      //    from the user, an `approve` call on the wrapped token contract, approving the wrapper, is needed first.

      bool unwrapSuccess = await _executeTransaction(
        "Unwrap", 
        wrapperContractAddr, 
        wrapperContractAbiHumanReadable, // This ABI should contain `withdrawTo`
        "withdrawTo", // Calling the correct function
        [_loggedInUserAddress!, amountStringForTx], // Parameters: (address account, uint256 value)
        TransactionProgress.unwrapTxSubmitted
      );

      if (!mounted) return;
      if (unwrapSuccess) {
        setState(() { _currentProgress = TransactionProgress.unwrapComplete; });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Unwrap successful!')));
        _resetStateAfterTransaction();
      } else {
        setState(() { _currentProgress = TransactionProgress.error; });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_errorMessage.isNotEmpty ? _errorMessage : 'Unwrap failed.')));
      }
    }
    _setIdleAfterDelay();
  }

  void _setIdleAfterDelay() {
    if ([TransactionProgress.error, TransactionProgress.wrapComplete, TransactionProgress.unwrapComplete].contains(_currentProgress)) {
      Future.delayed(const Duration(seconds: 5), () {
        if (mounted && !_isProcessingTransaction()) {
           if (_loggedInUserAddress != null) {
             setState(() { _currentProgress = TransactionProgress.ready; _progressMessage = _getProgressDisplayMessageFull(); }); // Ensure _progressMessage is updated too
           } else {
             _fetchUserAddress(); 
           }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final bool isWrappingMode = _currentAction == WrapperAction.wrap;
    final String actionButtonText = isWrappingMode ? "Wrap Token" : "Unwrap Token";
    final String amountInputLabel = isWrappingMode 
        ? "Amount of Base Token (smallest unit)" 
        : "Amount of Wrapped Token (smallest unit)";

    bool UIdisabled = _isProcessingTransaction() || 
                     _currentProgress == TransactionProgress.awaitingUserAddress ||
                     (_loggedInUserAddress == null && _currentProgress != TransactionProgress.fetchingUserAddressFailed) ;
    
    // Update _progressMessage directly here to ensure it reflects the current state, especially for TxHash display
    _progressMessage = _getProgressDisplayMessageFull();


    return Scaffold(
      appBar: const TopMenu(),
      body: Form(
        key: _formKey, // Using reinstated _formKey
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          children: [
            const SizedBox(height: 15),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 450),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_loggedInUserAddress != null && _loggedInUserAddress!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: SelectableText("Your Address: $_loggedInUserAddress", style: theme.textTheme.bodySmall, textAlign: TextAlign.center),
                      ),
                    
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (UIdisabled && 
                                ![TransactionProgress.ready, TransactionProgress.fetchingUserAddressFailed, TransactionProgress.error, TransactionProgress.approvalComplete, TransactionProgress.wrapComplete, TransactionProgress.unwrapComplete, TransactionProgress.approvalTxSubmitted, TransactionProgress.wrapTxSubmitted, TransactionProgress.unwrapTxSubmitted].contains(_currentProgress) // Added TxSubmitted states
                                )
                              const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 3)),
                            const SizedBox(height: 8),
                            Text(
                              _progressMessage, // Directly use the state variable
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: [TransactionProgress.error, TransactionProgress.fetchingUserAddressFailed].contains(_currentProgress) // Corrected: _TransactionProgress to TransactionProgress
                                    ? colorScheme.error
                                    : ([TransactionProgress.wrapComplete, TransactionProgress.unwrapComplete, TransactionProgress.approvalComplete].contains(_currentProgress) ? colorScheme.primary : theme.textTheme.bodyMedium?.color)
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    Center(
                      child: ToggleButtons(
                        isSelected: [ _currentAction == WrapperAction.wrap, _currentAction == WrapperAction.unwrap ],
                        onPressed: UIdisabled ? null : (index) {
                          setState(() {
                            _currentAction = WrapperAction.values[index];
                            if (_loggedInUserAddress != null) {
                              _currentProgress = TransactionProgress.ready;
                            } else if (![TransactionProgress.awaitingUserAddress, TransactionProgress.fetchingUserAddressFailed].contains(_currentProgress)) { // Corrected
                               _currentProgress = TransactionProgress.awaitingUserAddress; _fetchUserAddress();
                            }
                            // _errorMessage cleared at start of _handleSubmittedAction now
                            // _progressMessage = _getProgressDisplayMessageFull(); // build method handles this
                            _amountController.clear(); _formKey.currentState?.reset();
                          });
                        },
                        borderRadius: BorderRadius.circular(8.0),
                        selectedBorderColor: colorScheme.primary, selectedColor: colorScheme.onPrimary, fillColor: colorScheme.primary,
                        constraints: const BoxConstraints(minHeight: 40.0, minWidth: 120.0),
                        children: const [ Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text("Wrap")), Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text("Unwrap")) ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    if (isWrappingMode) ...[
                      TextFormField(
                        controller: _baseTokenAddressController, enabled: !UIdisabled,
                        decoration: InputDecoration(labelText: "Base Token Address to Wrap", hintText: "0x...", border: const OutlineInputBorder(), prefixIcon: Icon(Icons.token, color: colorScheme.secondary)),
                        validator: (v) => (v == null || v.isEmpty) ? 'Enter base token address' : (!_isValidEthereumAddress(v) ? 'Invalid address format' : null),
                      ),
                      const SizedBox(height: 20),
                    ],

                    if (!isWrappingMode) ...[
                      TextFormField(
                        controller: _wrappedTokenForUnwrapAddressController, enabled: !UIdisabled,
                        decoration: InputDecoration(labelText: "Wrapped Token Address (for your reference)", hintText: "0x... (e.g., your wTOKEN)", border: const OutlineInputBorder(), prefixIcon: Icon(Icons.layers, color: colorScheme.secondary)),
                        validator: (v) => (v == null || v.isEmpty) ? 'Enter wrapped token address' : (!_isValidEthereumAddress(v) ? 'Invalid address format' : null),
                      ),
                      const SizedBox(height: 20),
                    ],

                    TextFormField(
                      controller: _wrapperContractAddressController, enabled: !UIdisabled,
                      decoration: InputDecoration(labelText: "Wrapper Contract Address", hintText: "0x...", border: const OutlineInputBorder(), prefixIcon: Icon(Icons.gavel_rounded, color: colorScheme.secondary)),
                      validator: (v) => (v == null || v.isEmpty) ? 'Enter wrapper contract address' : (!_isValidEthereumAddress(v) ? 'Invalid address format' : null),
                    ),
                    const SizedBox(height: 20),

                    TextFormField(
                      controller: _amountController, enabled: !UIdisabled,
                      decoration: InputDecoration(labelText: amountInputLabel, hintText: "e.g., 1000000000000000000", border: const OutlineInputBorder(), prefixIcon: Icon(isWrappingMode ? Icons.arrow_downward : Icons.arrow_upward, color: colorScheme.primary)),
                      keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly], 
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Please enter an amount';
                        try { if (BigInt.parse(v) <= BigInt.zero) return 'Amount must be > 0'; } catch (e) { return 'Invalid integer amount'; }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: colorScheme.primary, foregroundColor: colorScheme.onPrimary, padding: const EdgeInsets.symmetric(vertical: 16), textStyle: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold))
                          .copyWith(backgroundColor: WidgetStateProperty.resolveWith<Color?>((states) => states.contains(WidgetState.disabled) ? Colors.grey.shade400 : colorScheme.primary)),
                      onPressed: UIdisabled ? null : _handleSubmittedAction,
                      child: Text(actionButtonText),
                    ),
                    const SizedBox(height: 16),
                    Center(child: Text(
                        isWrappingMode 
                            ? "This will approve the Wrapper Contract to spend your Base Tokens, then instruct the Wrapper to deposit them for you." 
                            : "This will instruct the Wrapper Contract to withdraw your specified amount of Wrapped Tokens and send the underlying Base Tokens to your address.", 
                        style: theme.textTheme.bodySmall, textAlign: TextAlign.center)
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
// token_wrapper_ui.dart