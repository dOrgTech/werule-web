// lib/src/features/dao_creator/screens/screen2_basic_setup.dart
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:werule/src/features/dao_creator/providers/dao_creator_provider.dart';
import 'package:werule/src/features/dao_creator/utils/creator_utils.dart';
import 'package:werule/src/features/dao_creator/widgets/pleading_for_less_decimals.dart';

class Screen2BasicSetup extends StatefulWidget {
  final DaoCreatorProvider provider;

  const Screen2BasicSetup({
    super.key,
    required this.provider,
  });

  @override
  _Screen2BasicSetupState createState() => _Screen2BasicSetupState();
}

class _Screen2BasicSetupState extends State<Screen2BasicSetup> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _daoNameController;
  late TextEditingController _daoDescriptionController;
  late TextEditingController _tokenSymbolController;
  late TextEditingController _underlyingTokenAddressController;
  late bool _isTransferrable;
  late bool _useWrappedToken;

  @override
  void initState() {
    super.initState();
    _daoNameController = TextEditingController(text: widget.provider.daoName);
    _daoDescriptionController =
        TextEditingController(text: widget.provider.daoDescription);
    _tokenSymbolController =
        TextEditingController(text: widget.provider.tokenSymbol);
    _underlyingTokenAddressController =
        TextEditingController(text: widget.provider.underlyingTokenAddress);
    _isTransferrable = widget.provider.isTransferrable;
    _useWrappedToken = widget.provider.useWrappedToken;
  }

  @override
  void dispose() {
    _daoNameController.dispose();
    _daoDescriptionController.dispose();
    _tokenSymbolController.dispose();
    _underlyingTokenAddressController.dispose();
    super.dispose();
  }

  void _saveAndNext() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      widget.provider.updateBasicInfo(
        name: _daoNameController.text,
        description: _daoDescriptionController.text,
        symbol: _tokenSymbolController.text.toUpperCase(),
        transferrable: _isTransferrable,
        wrappedToken: _useWrappedToken,
        underlyingToken: _useWrappedToken ? _underlyingTokenAddressController.text : null,
      );
      widget.provider.nextStep();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 70),
        child: Form(
          key: _formKey,
          child: Center(
            child: SizedBox(
              width: 500,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("Organization identity",
                      style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 30),
                  TextFormField(
                    controller: _daoNameController,
                    maxLength: 38,
                    decoration: const InputDecoration(labelText: 'DAO Name'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a name for your organization';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _daoDescriptionController,
                    maxLength: 400,
                    maxLines: 4,
                    decoration: const InputDecoration(
                        labelText: 'Description or Tagline (Optional)'),
                  ),
                  const SizedBox(height: 30),
                  Text("Governance Token",
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 20),
                  // Radio buttons for token type selection
                  RadioListTile<bool>(
                    title: const Text('Deploy new standard token'),
                    value: false,
                    groupValue: _useWrappedToken,
                    activeColor: Theme.of(context).indicatorColor,
                    onChanged: (bool? value) {
                      setState(() {
                        _useWrappedToken = value ?? false;
                      });
                    },
                  ),
                  RadioListTile<bool>(
                    title: const Text('Wrap existing ERC20 token'),
                    value: true,
                    groupValue: _useWrappedToken,
                    activeColor: Theme.of(context).indicatorColor,
                    onChanged: (bool? value) {
                      setState(() {
                        _useWrappedToken = value ?? true;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  // Conditional fields based on token type - with fixed height to prevent jumping
                  SizedBox(
                    height: 135, // Fixed height to accommodate the taller option (standard token with checkbox)
                    child: _useWrappedToken
                        ? // Wrapped token fields
                        Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 3,
                                child: TextFormField(
                                  controller: _underlyingTokenAddressController,
                                  decoration: const InputDecoration(
                                    labelText: 'Underlying Token Address',
                                    hintText: '0x...',
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter the underlying token address';
                                    }
                                    // Basic Ethereum address validation
                                    if (!RegExp(r'^0x[a-fA-F0-9]{40}$')
                                        .hasMatch(value)) {
                                      return 'Invalid Ethereum address';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                flex: 1,
                                child: TextFormField(
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                        RegExp(r'[a-zA-Z0-9]')),
                                    UpperCaseTextFormatter(),
                                  ],
                                  maxLength: 5,
                                  controller: _tokenSymbolController,
                                  decoration: const InputDecoration(
                                    counterText: "",
                                    labelText: 'Symbol',
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Required';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          )
                        : // Standard token field
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 150,
                                child: TextFormField(
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                        RegExp(r'[a-zA-Z0-9]')),
                                    UpperCaseTextFormatter(),
                                  ],
                                  maxLength: 5,
                                  controller: _tokenSymbolController,
                                  decoration: const InputDecoration(
                                      counterText: "",
                                      labelText: 'Ticker Symbol'),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Ticker required';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(height: 24),
                              SizedBox(
                                height: 40,
                                width: 300,
                                child: CheckboxListTile(
                                  title: const Text('Transferable'),
                                  subtitle: Text(
                                    _isTransferrable
                                        ? 'Members can transfer tokens freely'
                                        : 'Tokens are soulbound (non-transferable)',
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.grey[600]),
                                  ),
                                  value: _isTransferrable,
                                  activeColor: Theme.of(context).indicatorColor,
                                  checkColor: Colors.black,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      _isTransferrable = value ?? false;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                  ),
                  const SizedBox(height: 56),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: widget.provider.previousStep,
                        child: const Text('< Back'),
                      ),
                      ElevatedButton(
                        onPressed: _saveAndNext,
                        child: const Text('Save and Continue >'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
// lib/src/features/dao_creator/screens/screen2_basic_setup.dart