import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:Homebase/entities/org.dart';
import 'package:Homebase/entities/human.dart';
import 'package:flutter_web3_provider/ethers.dart';
import 'dart:js_util'; // Direct import
import 'package:Homebase/entities/contractFunctions.dart' show getERC20Balance;
import 'package:Homebase/utils/functions.dart' show parseNumber;

// Define ABIs and Enums locally to avoid import issues if analyzer is glitching
const List<String> erc20ApproveAbiHumanReadable = [
  "function approve(address spender, uint256 value) returns (bool)"
];

const List<String> wrapperContractAbiHumanReadable = [
  "function depositFor(address account, uint256 value)",
  "function withdrawTo(address account, uint256 value)"
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
// End local definitions

class GovernanceTokenBridgeWidget extends StatefulWidget {
  final Org org;
  const GovernanceTokenBridgeWidget({super.key, required this.org});

  @override
  _GovernanceTokenBridgeWidgetState createState() => _GovernanceTokenBridgeWidgetState();
}

class _GovernanceTokenBridgeWidgetState extends State<GovernanceTokenBridgeWidget> {
  final TextEditingController _amountController = TextEditingController();
  bool _isWrapping = true;

  String? _loggedInUserAddress;
  TransactionProgress _currentProgress = TransactionProgress.idle;
  String _progressMessage = "Initializing...";
  String _errorMessage = "";

  String _underlyingTokenBalance = "0";
  String _wrappedTokenBalance = "0";
  final String _underlyingTokenSymbol = "UNDERLYING"; 
  final int _underlyingDecimals = 18; 

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Human().address != null && Human().address!.isNotEmpty) {
         _loggedInUserAddress = Human().address!;
         setState(() {
           _currentProgress = TransactionProgress.ready;
           _progressMessage = _getProgressDisplayMessageFull();
         });
      } else if (Human().web3user != null) {
        _fetchUserAddress();
      } else {
        setState(() {
          _currentProgress = TransactionProgress.fetchingUserAddressFailed;
          _errorMessage = "Wallet provider not initialized. Please connect your wallet first.";
          _progressMessage = _getProgressDisplayMessageFull();
        });
      }
      _fetchTokenBalances();
    });
  }

  Future<void> _fetchTokenBalances() async {
    if (_loggedInUserAddress == null || Human().web3user == null) {
      print("Cannot fetch balances: User address or web3 provider is null.");
      return;
    }
    if (widget.org.wrapped != null && widget.org.wrapped!.isNotEmpty) {
      try {
        final underlyingBalanceRaw = await getERC20Balance(widget.org.wrapped!, _loggedInUserAddress!);
        if (mounted) {
          setState(() {
            _underlyingTokenBalance = parseNumber(underlyingBalanceRaw, _underlyingDecimals);
          });
        }
      } catch (e) {
        print("Error fetching underlying token balance: $e");
        if (mounted) setState(() => _underlyingTokenBalance = "Error");
      }
    } else {
      if (mounted) setState(() => _underlyingTokenBalance = "N/A");
    }

    if (widget.org.govTokenAddress != null && widget.org.govTokenAddress!.isNotEmpty) {
      try {
        final wrappedBalanceRaw = await getERC20Balance(widget.org.govTokenAddress!, _loggedInUserAddress!);
        if (mounted) {
          setState(() {
            _wrappedTokenBalance = parseNumber(wrappedBalanceRaw, widget.org.decimals ?? 18);
          });
        }
      } catch (e) {
        print("Error fetching wrapped token balance: $e");
        if (mounted) setState(() => _wrappedTokenBalance = "Error");
      }
    } else {
       if (mounted) setState(() => _wrappedTokenBalance = "N/A");
    }
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
        Human().address = address; 
        setState(() {
          _currentProgress = TransactionProgress.ready;
          _progressMessage = _getProgressDisplayMessageFull();
        });
        _fetchTokenBalances(); 
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
    _fetchTokenBalances(); 
  }
  
  String _getProgressDisplayMessageFull() {
    if (_currentProgress == TransactionProgress.error) return "Error: $_errorMessage";
    
    String displayMessage = "";
    bool hashAvailable = _errorMessage.startsWith("Tx Hash:");
    String txHashForDisplay = hashAvailable ? _errorMessage.split(':').last.trim() : "";

    switch (_currentProgress) {
      case TransactionProgress.idle: displayMessage = "Initializing..."; break;
      case TransactionProgress.awaitingUserAddress: displayMessage = "Fetching user address..."; break;
      case TransactionProgress.fetchingUserAddressFailed: displayMessage = _errorMessage.isNotEmpty && !hashAvailable ? "Error: $_errorMessage" : "Failed to get address. Connect wallet & refresh."; break;
      case TransactionProgress.ready: displayMessage = _loggedInUserAddress != null ? "" : "Initializing wallet..."; break;
      
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
      TransactionProgress submittedState,
      TransactionProgress awaitingSignatureState,
      TransactionProgress sendingState
      ) async {

    final Web3Provider? web3User = Human().web3user;

    if (web3User == null) {
      _errorMessage = "Wallet provider (Human().web3user) is null.";
      if (mounted) setState(() { _currentProgress = TransactionProgress.error; _progressMessage = _getProgressDisplayMessageFull(); });
      return false;
    }

    try {
      if (mounted) setState(() { _currentProgress = awaitingSignatureState; _progressMessage = _getProgressDisplayMessageFull(); });

      Contract contract = Contract(contractAddress, contractAbiHumanReadable, web3User);
      contract = contract.connect(web3User.getSigner());

      print("$stepName: Calling $methodName on $contractAddress with params: $methodArgs.");
      
      if (mounted) setState(() { _currentProgress = sendingState; _progressMessage = _getProgressDisplayMessageFull(); });
      
      final transactionResponseJs = await promiseToFuture(callMethod(contract, methodName, jsify(methodArgs)));
      
      final String txHash = json.decode(json.encode(transactionResponseJs))["hash"];
      print("$stepName tx hash: $txHash");

      _errorMessage = "Tx Hash: $txHash"; 
      if (mounted) {
        setState(() {
          _currentProgress = submittedState;
          _progressMessage = _getProgressDisplayMessageFull(); 
        });
      }
      
      final txReceiptJs = await promiseToFuture(web3User.waitForTransaction(txHash, 1));
      final receiptStatus = json.decode(json.encode(txReceiptJs))["status"];
      final int status = (receiptStatus is int) ? receiptStatus : int.tryParse(receiptStatus.toString()) ?? 0;

      _errorMessage = "";

      if (status == 1) {
        final String receiptTxHash = json.decode(json.encode(txReceiptJs))["transactionHash"];
        print("$stepName successful. Receipt Tx Hash: $receiptTxHash");
        return true;
      } else {
        _errorMessage = "$stepName transaction failed (status $status).";
        print(_errorMessage);
        if (mounted) setState(() { _currentProgress = TransactionProgress.error; _progressMessage = _getProgressDisplayMessageFull(); });
        return false;
      }
    } catch (e, s) {
      _errorMessage = "Exception during $stepName: ${e.toString()}";
      if (e.toString().toLowerCase().contains('user rejected') ||
          (getProperty(e, 'code') == 4001) ||
          (getProperty(e, 'code') == 'ACTION_REJECTED')
         ) {
        _errorMessage = "$stepName rejected by user.";
      }
      print(_errorMessage);
      print("Stack trace for $stepName exception: $s");
      if (mounted) setState(() { _currentProgress = TransactionProgress.error; _progressMessage = _getProgressDisplayMessageFull(); });
      return false;
    }
  }

  void _setIdleAfterDelay() {
    if ([TransactionProgress.error, TransactionProgress.wrapComplete, TransactionProgress.unwrapComplete].contains(_currentProgress)) {
      Future.delayed(const Duration(seconds: 5), () {
        if (mounted && !_isProcessingTransaction()) {
           if (_loggedInUserAddress != null) {
             setState(() { _currentProgress = TransactionProgress.ready; _progressMessage = _getProgressDisplayMessageFull(); });
           } else {
             _fetchUserAddress();
           }
        }
      });
    }
  }

  void _handleTransaction() {
    if (_loggedInUserAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User address not available. Please connect wallet.')));
      _fetchUserAddress();
      return;
    }
    if (widget.org.wrapped == null || widget.org.wrapped!.isEmpty) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Underlying token address is not configured for this DAO.')));
       return;
    }
     if (widget.org.govTokenAddress == null || widget.org.govTokenAddress!.isEmpty) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Governance token (wrapper) address is not configured for this DAO.')));
       return;
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
    
    setState(() { _errorMessage = ""; });

    if (_isWrapping) {
      _performWrap(amountStringForTx);
    } else {
      _performUnwrap(amountStringForTx);
    }
  }

  void _performWrap(String amountStringForTx) async {
    final underlyingTokenAddr = widget.org.wrapped!;
    final wrapperContractAddr = widget.org.govTokenAddress!;
    final accountForDeposit = _loggedInUserAddress!;

    bool approvalSuccess = await _executeTransaction(
      "Approval", underlyingTokenAddr, erc20ApproveAbiHumanReadable, "approve",
      [wrapperContractAddr, amountStringForTx], 
      TransactionProgress.approvalTxSubmitted,
      TransactionProgress.awaitingApprovalSignature,
      TransactionProgress.sendingApproval
    );

    if (!mounted) return;
    if (!approvalSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_errorMessage.isNotEmpty ? _errorMessage : 'Approval failed.')));
      _setIdleAfterDelay(); return;
    }
    
    setState(() { _currentProgress = TransactionProgress.approvalComplete; _progressMessage = _getProgressDisplayMessageFull(); });
    if (!mounted) return;

    bool depositSuccess = await _executeTransaction(
      "Wrap/Deposit", wrapperContractAddr, wrapperContractAbiHumanReadable, "depositFor",
      [accountForDeposit, amountStringForTx], 
      TransactionProgress.wrapTxSubmitted,
      TransactionProgress.awaitingWrapSignature,
      TransactionProgress.sendingWrap
    );
    
    if (!mounted) return;
    if (depositSuccess) {
      setState(() { _currentProgress = TransactionProgress.wrapComplete; _progressMessage = _getProgressDisplayMessageFull(); });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Wrap successful!')));
      _resetStateAfterTransaction();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_errorMessage.isNotEmpty ? _errorMessage : 'Wrap/Deposit failed.')));
    }
    _setIdleAfterDelay();
  }

  void _performUnwrap(String amountStringForTx) async {
    final wrapperContractAddr = widget.org.govTokenAddress!;
    final accountForWithdraw = _loggedInUserAddress!;
    
    bool unwrapSuccess = await _executeTransaction(
      "Unwrap", wrapperContractAddr, wrapperContractAbiHumanReadable, "withdrawTo",
      [accountForWithdraw, amountStringForTx], 
      TransactionProgress.unwrapTxSubmitted,
      TransactionProgress.awaitingUnwrapSignature,
      TransactionProgress.sendingUnwrap
    );

    if (!mounted) return;
    if (unwrapSuccess) {
      setState(() { _currentProgress = TransactionProgress.unwrapComplete; _progressMessage = _getProgressDisplayMessageFull(); });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Unwrap successful!')));
      _resetStateAfterTransaction();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_errorMessage.isNotEmpty ? _errorMessage : 'Unwrap failed.')));
    }
    _setIdleAfterDelay();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    _progressMessage = _getProgressDisplayMessageFull(); 

    bool uiDisabled = _isProcessingTransaction() ||
                     _currentProgress == TransactionProgress.awaitingUserAddress ||
                     (_loggedInUserAddress == null && _currentProgress != TransactionProgress.fetchingUserAddressFailed) ;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
          

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (uiDisabled &&
                        ![TransactionProgress.ready, TransactionProgress.fetchingUserAddressFailed, TransactionProgress.error, TransactionProgress.approvalComplete, TransactionProgress.wrapComplete, TransactionProgress.unwrapComplete, TransactionProgress.approvalTxSubmitted, TransactionProgress.wrapTxSubmitted, TransactionProgress.unwrapTxSubmitted].contains(_currentProgress)
                        )
                      const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 3)),
                    const SizedBox(height: 8),
                    Text(
                      _progressMessage,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: [TransactionProgress.error, TransactionProgress.fetchingUserAddressFailed].contains(_currentProgress)
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
              child: ToggleSwitch(
                minWidth: 120.0,
                initialLabelIndex: _isWrapping ? 0 : 1,
                cornerRadius: 8.0,
                activeFgColor: Theme.of(context).indicatorColor,
                inactiveFgColor: const Color.fromARGB(255, 189, 189, 189),
                activeBgColor: const [Color.fromARGB(255, 77, 77, 77)],
                inactiveBgColor: Theme.of(context).cardColor,
                borderColor: [Theme.of(context).cardColor],
                borderWidth: 1.5,
                totalSwitches: 2,
                labels: const ['Wrap', 'Unwrap'],
                customTextStyles: const [TextStyle(fontSize: 14)],
                onToggle: uiDisabled ? null : (index) {
                  setState(() {
                    _isWrapping = index == 0;
                    _errorMessage = '';
                    if (_loggedInUserAddress != null) {
                       _currentProgress = TransactionProgress.ready;
                    } else if (![TransactionProgress.awaitingUserAddress, TransactionProgress.fetchingUserAddressFailed].contains(_currentProgress)) {
                       _currentProgress = TransactionProgress.awaitingUserAddress; _fetchUserAddress();
                    }
                    _progressMessage = _getProgressDisplayMessageFull();
                    _amountController.clear();
                  });
                },
              ),
            ),
            const SizedBox(height: 29),

            Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 300),
                child: TextFormField(
                  controller: _amountController,
                  enabled: !uiDisabled,
                  keyboardType: const TextInputType.numberWithOptions(decimal: false),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    labelText: _isWrapping ? 'Amount to Wrap (smallest unit)' : 'Amount to Unwrap (smallest unit)',
                    hintText: 'Enter amount',
                    border: const OutlineInputBorder(),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Please enter an amount';
                    try { if (BigInt.parse(v) <= BigInt.zero) return 'Amount must be > 0'; } catch (e) { return 'Invalid integer amount'; }
                    return null;
                  },
                ),
              ),
            ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: uiDisabled ? null : _handleTransaction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).indicatorColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  textStyle: const TextStyle(fontSize: 16),
                ).copyWith(backgroundColor: WidgetStateProperty.resolveWith<Color?>((states) => states.contains(WidgetState.disabled) ? Colors.grey.shade400 : Theme.of(context).indicatorColor)),
                child: Text(_isWrapping ? 'Wrap Tokens' : 'Unwrap Tokens'),
              ),
            ),
            const SizedBox(height: 10), 
             Center(child: Text(
                _isWrapping
                    ? "Approves wrapper to spend underlying, then wraps."
                    : "Instructs wrapper to send underlying to you.",
                style: theme.textTheme.bodySmall, textAlign: TextAlign.center)
            ),
            const SizedBox(height: 10), 
          ],
        ),
      ),
    );
  }
}