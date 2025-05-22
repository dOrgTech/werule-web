import 'dart:async';
import 'dart:convert'; // For json.decode AND utf8

// import 'dart:math'; // No longer needed for pow

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Corrected Imports
import 'package:Homebase/entities/human.dart';
import 'package:flutter_web3_provider/ethers.dart'; // Provides Contract, Signer, TxReceipt etc.
import 'package:Homebase/widgets/menu.dart';
// This is crucial if `stringify` comes from here.
// If `stringify` is a global JS function accessible via js_util, this might not be needed for stringify.
// However, your `delegate` example implies it's available.
import 'package:flutter_web3_provider/ethereum.dart'; // Assuming `stringify` might be here or globally available via JS.


// Using js_util for promiseToFuture and callMethod
import 'package:js/js_util.dart' show promiseToFuture, callMethod, getProperty; // Removed jsify as we removed overrides


// --- ABIs (Human-Readable - Confirmed by your delegate example's tokenAbiString) ---
const List<String> erc20ApproveAbiHumanReadable = [
  "function approve(address spender, uint256 value) returns (bool)"
  // Add "event Approval(address indexed owner, address indexed spender, uint256 value)"
  // if your contract logic or UI needs to react to this event.
];

const List<String> wrapperContractAbiHumanReadable = [
  "function depositFor(address account, uint256 value)",
  "function withdraw(uint256 amount)"
  // Add relevant events like "event Deposit(address indexed account, uint256 value)"
  // or "event Withdrawal(address indexed account, uint256 amount)" if needed.
];


enum WrapperAction { wrap, unwrap }
enum TransactionProgress {
  idle,
  awaitingUserAddress,
  fetchingUserAddressFailed,
  ready,
  awaitingApprovalSignature,
  sendingApproval,
  approvalComplete,
  awaitingWrapSignature,
  sendingWrap,
  wrapComplete,
  awaitingUnwrapSignature,
  sendingUnwrap,
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
  }

  String _getProgressDisplayMessageFull() {
    if (_currentProgress == TransactionProgress.error) return "Error: $_errorMessage";
    switch (_currentProgress) {
      case TransactionProgress.idle: return "Initializing...";
      case TransactionProgress.awaitingUserAddress: return "Fetching user address...";
      case TransactionProgress.fetchingUserAddressFailed: return _errorMessage.isNotEmpty ? "Error: $_errorMessage" : "Failed to get address. Ensure wallet is connected & refresh.";
      case TransactionProgress.ready: return _loggedInUserAddress != null ? "Ready." : "Initializing wallet...";
      case TransactionProgress.awaitingApprovalSignature: return "1/2: Approve in wallet...";
      case TransactionProgress.sendingApproval: return _progressMessage;
      case TransactionProgress.approvalComplete: return "1/2: Approval successful!";
      case TransactionProgress.awaitingWrapSignature: return "2/2: Confirm wrap in wallet...";
      case TransactionProgress.sendingWrap: return _progressMessage;
      case TransactionProgress.wrapComplete: return "Wrap successful!";
      case TransactionProgress.awaitingUnwrapSignature: return "Confirm unwrap in wallet...";
      case TransactionProgress.sendingUnwrap: return _progressMessage;
      case TransactionProgress.unwrapComplete: return "Unwrap successful!";
      default: return "Processing...";
    }
  }

  // MODIFIED _executeTransaction to align with `delegate` pattern
  Future<bool> _executeTransaction(
      String stepName,
      String contractAddress,
      List<String> contractAbiHumanReadable, // Correctly using List<String> of human-readable
      String methodName,
      List<dynamic> methodArgs, 
      Function(String) progressUpdateForTxHashCallback
      ) async {

    if (Human().web3user == null) {
      _errorMessage = "Wallet provider not available.";
      return false;
    }
    // Your `delegate` uses Human().web3user for contract, and Human().web3user!.getSigner() for connect.
    // This implies Human().web3user is the provider.
    final Web3Provider provider = Human().web3user!; 
    final Signer signer = provider.getSigner();

    try {
      Contract contract = Contract(contractAddress, contractAbiHumanReadable, provider);
      contract = contract.connect(signer);

      print("$stepName: Calling $methodName on $contractAddress with params: $methodArgs. ABI: ${contractAbiHumanReadable.join('; ')}");
      
      // `transactionResponseJs` is the JS TransactionResponse object
      final transactionResponseJs = await promiseToFuture(callMethod(contract, methodName, methodArgs));

      // Extract hash using stringify and json.decode, as per your `delegate` example
      // Ensure `stringify` is available in your scope (e.g., from flutter_web3_provider/ethereum.dart or global JS)
      final String txHash = json.decode(stringify(transactionResponseJs))["hash"];

      print("$stepName tx hash: $txHash");
      progressUpdateForTxHashCallback("$stepName tx submitted ($txHash). Waiting...");

      // Wait for transaction using the provider's waitForTransaction, as per `delegate`
      // The `waitForTransaction` is on the `Provider` class in your `ethers.dart`
      final txReceiptJs = await promiseToFuture(provider.waitForTransaction(txHash)); 
      // If waitForTransaction is not directly on Web3Provider but on a base Provider, ensure provider is of that type or has it.
      // Your ethers.dart shows: Provider has waitForTransaction, Web3Provider extends Provider. So, this should be fine.

      // Extract status using stringify and json.decode
      final receiptStatus = json.decode(stringify(txReceiptJs))["status"];
      
      final int status = (receiptStatus is int) ? receiptStatus : int.tryParse(receiptStatus.toString()) ?? 0;

      if (status == 1) {
        // Your `delegate` example uses `txReceiptJs.transactionHash` implicitly via stringify.
        // TxReceipt from your ethers.dart has `external String get transactionHash;`
        // So, we can try to access it directly if `txReceiptJs` is correctly typed by `promiseToFuture<TxReceipt>`
        // However, to stick to `delegate` pattern:
        final String receiptTxHash = json.decode(stringify(txReceiptJs))["transactionHash"];
        print("$stepName successful. Tx Hash: $receiptTxHash");
        return true;
      } else {
        _errorMessage = "$stepName transaction failed (status $status).";
        // Try to get revert reason like in delegate, if applicable
        final String? revertReason = _tryDecodeRevertReason(txReceiptJs);
        if (revertReason != null) {
          _errorMessage += " Reason: $revertReason";
        }
        print(_errorMessage);
        return false;
      }
    } catch (e, s) { // Added stack trace to catch
      _errorMessage = "Exception during $stepName: ${e.toString()}";
      print("$_errorMessage");
      print("Stack trace for $stepName exception: $s");
      // Detailed JS error property fetching (optional, can be noisy)
      // try {
      //   String jsErrorDetails = "JS Error Details: ";
      //   jsErrorDetails += "message: ${getProperty(e, 'message') ?? 'N/A'}, ";
      //   jsErrorDetails += "code: ${getProperty(e, 'code') ?? 'N/A'}";
      //   print(jsErrorDetails);
      // } catch (detailError) { /* ignore */ }
      return false;
    }
  }

  String? _tryDecodeRevertReason(dynamic txReceiptJs) {
    try {
      final receiptMap = json.decode(stringify(txReceiptJs));
      // This depends on how your `stringify` and the receipt structure work.
      // The previous error log showed data within data.
      // "data": { "code": -32005, "message": "execution reverted", "data": "0x08c379a0..." }
      // So, we might need to look deeper if the main receipt doesn't have the revert data directly.
      // For now, let's assume `receiptMap['data']` might exist and be the revert data string.
      final dynamic receiptErrorData = receiptMap['data']; // This 'data' might be the revert data string or another nested object.

      String? revertDataString;
      if (receiptErrorData is String) {
        revertDataString = receiptErrorData;
      } else if (receiptErrorData is Map && receiptErrorData.containsKey('data') && receiptErrorData['data'] is String) {
        // Handling the nested structure seen in MetaMask errors:
        // "data": { "code": ..., "message": ..., "data": "0x08c379a0..." }
        revertDataString = receiptErrorData['data'];
      }


      if (revertDataString != null && revertDataString.startsWith('0x08c379a0')) { // Error(string) selector
        String reasonHex = revertDataString.substring(10); // Skip selector
        if (reasonHex.length >= 128) { 
            reasonHex = reasonHex.substring(64); 
            int len = int.tryParse(reasonHex.substring(0, 64), radix: 16) ?? 0;
            if (len > 0 && reasonHex.length >= 64 + (len * 2)) {
                String strHex = reasonHex.substring(64, 64 + (len * 2));
                List<int> bytes = [];
                for (int i = 0; i < strHex.length; i += 2) {
                    bytes.add(int.parse(strHex.substring(i, i + 2), radix: 16));
                }
                return utf8.decode(bytes, allowMalformed: true).replaceAll(RegExp(r'\u0000+$'), '');
            }
        }
      }
    } catch (e) {
      print("Could not decode revert reason from receipt: $e");
    }
    return null;
  }


  void _handleSubmittedAction() async {
    if (_loggedInUserAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User address not available. Please connect wallet and try again.')),
      );
      _fetchUserAddress();
      return;
    }
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final amountInputByUser = _amountController.text;
    final String amountStringForTx = _getAmountStringForTx(amountInputByUser); 
    
    try {
      if (BigInt.parse(amountStringForTx) <= BigInt.zero) {
        ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(content: Text('Amount for transaction must be greater than zero.')));
        return;
      }
    } catch (e) {
       ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(content: Text('Invalid amount entered for transaction.')));
        return;
    }

    final wrapperContractAddr = _wrapperContractAddressController.text.trim();
    
    setState(() { _errorMessage = ""; });

    if (_currentAction == WrapperAction.wrap) {
      final baseTokenAddr = _baseTokenAddressController.text.trim();

      setState(() {
        _currentProgress = TransactionProgress.awaitingApprovalSignature;
        _progressMessage = _getProgressDisplayMessageFull();
      });

      bool approvalSuccess = await _executeTransaction(
        "Approval",
        baseTokenAddr,
        erc20ApproveAbiHumanReadable,
        "approve",
        [wrapperContractAddr, amountStringForTx],
        (message) {
          if(mounted) setState(() {
            _currentProgress = TransactionProgress.sendingApproval;
            _progressMessage = message;
          });
        }
      );

      if (!mounted) return;
      if (!approvalSuccess) {
        setState(() {
           _currentProgress = TransactionProgress.error;
           _progressMessage = _getProgressDisplayMessageFull();
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_errorMessage.isNotEmpty ? _errorMessage : 'Approval transaction failed.')));
        _setIdleAfterDelay();
        return;
      }
      
      setState(() {
        _currentProgress = TransactionProgress.approvalComplete;
        _progressMessage = _getProgressDisplayMessageFull();
      });
      
      if (!mounted) return;

      setState(() {
        _currentProgress = TransactionProgress.awaitingWrapSignature;
        _progressMessage = _getProgressDisplayMessageFull();
      });

      bool depositSuccess = await _executeTransaction(
        "Wrap/Deposit",
        wrapperContractAddr,
        wrapperContractAbiHumanReadable,
        "depositFor",
        [_loggedInUserAddress!, amountStringForTx],
        (message) {
          if(mounted) setState(() {
            _currentProgress = TransactionProgress.sendingWrap;
             _progressMessage = message;
          });
        }
      );
      
      if (!mounted) return;
      if (depositSuccess) {
        setState(() {
          _currentProgress = TransactionProgress.wrapComplete;
          _progressMessage = _getProgressDisplayMessageFull();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Wrap successful!')),
        );
        _resetStateAfterTransaction();
      } else {
         setState(() {
           _currentProgress = TransactionProgress.error;
           _progressMessage = _getProgressDisplayMessageFull();
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_errorMessage.isNotEmpty ? _errorMessage : 'Wrap/Deposit transaction failed.')));
      }

    } else { // Unwrap
      setState(() {
        _currentProgress = TransactionProgress.awaitingUnwrapSignature;
        _progressMessage = _getProgressDisplayMessageFull();
      });
      
      bool unwrapSuccess = await _executeTransaction(
        "Unwrap",
        wrapperContractAddr, 
        wrapperContractAbiHumanReadable,
        "withdraw", 
        [amountStringForTx],
        (message) {
          if(mounted) setState(() {
            _currentProgress = TransactionProgress.sendingUnwrap;
            _progressMessage = message;
          });
        }
      );

      if (!mounted) return;
      if (unwrapSuccess) {
        setState(() {
          _currentProgress = TransactionProgress.unwrapComplete;
          _progressMessage = _getProgressDisplayMessageFull();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unwrap successful!')),
        );
        _resetStateAfterTransaction();
      } else {
        setState(() {
           _currentProgress = TransactionProgress.error;
           _progressMessage = _getProgressDisplayMessageFull();
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_errorMessage.isNotEmpty ? _errorMessage : 'Unwrap transaction failed.')));
      }
    }
    _setIdleAfterDelay();
  }

  void _setIdleAfterDelay() {
    if (_currentProgress == TransactionProgress.error ||
        _currentProgress == TransactionProgress.wrapComplete ||
        _currentProgress == TransactionProgress.unwrapComplete) {
      Future.delayed(const Duration(seconds: 5), () {
        if (mounted && !_isProcessingTransaction()) {
           if (_loggedInUserAddress != null) {
             setState(() {
               _currentProgress = TransactionProgress.ready;
               _progressMessage = _getProgressDisplayMessageFull();
             });
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
    final String amountInputLabel = "Amount in smallest unit (e.g., wei)";

    bool UIdisabled = _isProcessingTransaction() || 
                     _currentProgress == TransactionProgress.awaitingUserAddress ||
                     (_loggedInUserAddress == null && _currentProgress != TransactionProgress.fetchingUserAddressFailed) ;

    return Scaffold(
      appBar: const TopMenu(),
      body: Form(
        key: _formKey,
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
                                _currentProgress != TransactionProgress.ready &&
                                _currentProgress != TransactionProgress.fetchingUserAddressFailed &&
                                _currentProgress != TransactionProgress.error &&
                                _currentProgress != TransactionProgress.approvalComplete &&
                                _currentProgress != TransactionProgress.wrapComplete &&
                                _currentProgress != TransactionProgress.unwrapComplete 
                                )
                              const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 3)),
                            const SizedBox(height: 8),
                            Text(
                              _progressMessage,
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: _currentProgress == TransactionProgress.error || _currentProgress == TransactionProgress.fetchingUserAddressFailed
                                    ? colorScheme.error
                                    : (_currentProgress == TransactionProgress.wrapComplete || _currentProgress == TransactionProgress.unwrapComplete ? colorScheme.primary : theme.textTheme.bodyMedium?.color)
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
                        isSelected: [
                          _currentAction == WrapperAction.wrap,
                          _currentAction == WrapperAction.unwrap,
                        ],
                        onPressed: UIdisabled ? null : (index) {
                          setState(() {
                            _currentAction = WrapperAction.values[index];
                            if (_loggedInUserAddress != null) {
                               _currentProgress = TransactionProgress.ready;
                            } else if (_currentProgress != TransactionProgress.awaitingUserAddress && _currentProgress != TransactionProgress.fetchingUserAddressFailed) {
                               _currentProgress = TransactionProgress.awaitingUserAddress;
                               _fetchUserAddress();
                            } else if (_currentProgress == TransactionProgress.fetchingUserAddressFailed) {
                               _progressMessage = _getProgressDisplayMessageFull();
                            }
                            _errorMessage = "";
                            _amountController.clear();
                            _formKey.currentState?.reset();
                          });
                        },
                        borderRadius: BorderRadius.circular(8.0),
                        selectedBorderColor: colorScheme.primary,
                        selectedColor: colorScheme.onPrimary,
                        fillColor: colorScheme.primary,
                        constraints: const BoxConstraints(minHeight: 40.0, minWidth: 120.0),
                        children: const [
                          Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text("Wrap")),
                          Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text("Unwrap")),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    if (isWrappingMode) ...[
                      TextFormField(
                        controller: _baseTokenAddressController,
                        enabled: !UIdisabled,
                        decoration: InputDecoration(
                          labelText: "Base Token Address to Wrap",
                          hintText: "0x...",
                          border: const OutlineInputBorder(),
                          prefixIcon: Icon(Icons.token, color: colorScheme.secondary),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Enter base token address';
                          if (!_isValidEthereumAddress(value)) return 'Invalid address format';
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                    ],

                    if (!isWrappingMode) ...[
                      TextFormField(
                        controller: _wrappedTokenForUnwrapAddressController,
                        enabled: !UIdisabled,
                        decoration: InputDecoration(
                          labelText: "Wrapped Token Address to Unwrap",
                          hintText: "0x...",
                          border: const OutlineInputBorder(),
                          prefixIcon: Icon(Icons.layers, color: colorScheme.secondary),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Enter wrapped token address';
                          if (!_isValidEthereumAddress(value)) return 'Invalid address format';
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                    ],

                    TextFormField(
                      controller: _wrapperContractAddressController,
                      enabled: !UIdisabled,
                      decoration: InputDecoration(
                        labelText: "Wrapper Contract Address",
                        hintText: "0x...",
                        border: const OutlineInputBorder(),
                        prefixIcon: Icon(Icons.gavel_rounded, color: colorScheme.secondary),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Enter wrapper contract address';
                        if (!_isValidEthereumAddress(value)) return 'Invalid address format';
                        return null;
                        },
                    ),
                    const SizedBox(height: 20),

                    TextFormField(
                      controller: _amountController,
                      enabled: !UIdisabled,
                      decoration: InputDecoration(
                        labelText: amountInputLabel,
                        hintText: "e.g., 1000000000000000000", 
                        border: const OutlineInputBorder(),
                        prefixIcon: Icon(isWrappingMode ? Icons.arrow_downward : Icons.arrow_upward, color: colorScheme.primary),
                      ),
                      keyboardType: TextInputType.number, 
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly], 
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Please enter an amount';
                        try {
                          final BigInt amount = BigInt.parse(value);
                          if (amount <= BigInt.zero) return 'Amount must be > 0';
                        } catch (e) {
                          return 'Please enter a valid integer amount';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
                      ).copyWith(
                        backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                          (Set<MaterialState> states) {
                            if (states.contains(MaterialState.disabled)) return Colors.grey.shade400;
                            return colorScheme.primary;
                          },
                        ),
                      ),
                      onPressed: UIdisabled ? null : _handleSubmittedAction,
                      child: Text(actionButtonText),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Text(
                        isWrappingMode
                          ? "1. Approve. 2. Wrap."
                          : "Unwrap Token.",
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
      ),
    );
  }
}
// token_wrapper_ui.dart