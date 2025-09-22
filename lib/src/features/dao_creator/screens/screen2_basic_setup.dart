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
  late TextEditingController _numberOfDecimalsController;
  late bool _nonTransferrable;

  late TextEditingController _underlyingTokenAddressController;
  late TextEditingController _wrappedTokenSymbolController;

  late DaoTokenDeploymentMechanism _selectedMechanism;
  bool _memeNotShown = true;

  @override
  void initState() {
    super.initState();
    _daoNameController = TextEditingController(text: widget.provider.daoName);
    _daoDescriptionController =
        TextEditingController(text: widget.provider.daoDescription);

    _selectedMechanism = widget.provider.tokenDeploymentMechanism;

    _tokenSymbolController =
        TextEditingController(text: widget.provider.tokenSymbol);
    _numberOfDecimalsController = TextEditingController(
        text: widget.provider.numberOfDecimals?.toString());
    _nonTransferrable = widget.provider.nonTransferrable;

    _underlyingTokenAddressController =
        TextEditingController(text: widget.provider.underlyingTokenAddress);
    _wrappedTokenSymbolController =
        TextEditingController(text: widget.provider.wrappedTokenSymbol);
  }

  @override
  void dispose() {
    _daoNameController.dispose();
    _daoDescriptionController.dispose();
    _tokenSymbolController.dispose();
    _numberOfDecimalsController.dispose();
    _underlyingTokenAddressController.dispose();
    _wrappedTokenSymbolController.dispose();
    super.dispose();
  }

  void _saveAndNext() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      widget.provider.updateBasicInfo(
        name: _daoNameController.text,
        description: _daoDescriptionController.text,
        mechanism: _selectedMechanism,
        symbol: _tokenSymbolController.text.toUpperCase(),
        decimals: int.tryParse(_numberOfDecimalsController.text),
        isNonTransferrable: _nonTransferrable,
        underlyingAddress: _underlyingTokenAddressController.text,
        wrappedSymbol: _wrappedTokenSymbolController.text.toUpperCase(),
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
                  const SizedBox(height: 10),
                  SizedBox(
                    width: 380,
                    child: Column(
                      children: [
                        RadioListTile<DaoTokenDeploymentMechanism>(
                          title: const Text('Deploy new standard token'),
                          value:
                              DaoTokenDeploymentMechanism.deployNewStandardToken,
                          groupValue: _selectedMechanism,
                          onChanged: (DaoTokenDeploymentMechanism? value) {
                            if (value != null) {
                              setState(() {
                                _selectedMechanism = value;
                              });
                            }
                          },
                        ),
                        RadioListTile<DaoTokenDeploymentMechanism>(
                          title: const Text('Wrap existing ERC20 token'),
                          value: DaoTokenDeploymentMechanism.wrapExistingToken,
                          groupValue: _selectedMechanism,
                          onChanged: (DaoTokenDeploymentMechanism? value) {
                            if (value != null) {
                              setState(() {
                                _selectedMechanism = value;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (_selectedMechanism ==
                      DaoTokenDeploymentMechanism.deployNewStandardToken) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
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
                                counterText: "", labelText: 'Ticker Symbol'),
                            validator: (value) {
                              if (_selectedMechanism ==
                                      DaoTokenDeploymentMechanism
                                          .deployNewStandardToken &&
                                  (value == null || value.isEmpty)) {
                                return 'Ticker required';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 20),
                        SizedBox(
                          width: 150,
                          child: TextFormField(
                            onChanged: (value) {
                              int? decimals = int.tryParse(value);
                              if (decimals != null &&
                                  decimals > 6 &&
                                  _memeNotShown) {
                                _memeNotShown = false;
                                showDialog(
                                    context: context,
                                    builder: ((context) =>
                                        const AnimatedMemeWidget()));
                              }
                            },
                            controller: _numberOfDecimalsController,
                            keyboardType: TextInputType.number,
                            decoration:
                                const InputDecoration(labelText: 'Decimals'),
                            validator: (value) {
                              if (_selectedMechanism ==
                                  DaoTokenDeploymentMechanism
                                      .deployNewStandardToken) {
                                if (value == null || value.isEmpty) {
                                  return 'Required';
                                }
                                int? decimals = int.tryParse(value);
                                if (decimals == null ||
                                    decimals < 0 ||
                                    decimals > 18) return '0-18';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 40,
                      width: 300,
                      child: CheckboxListTile(
                        title: const Text('Non-transferable Token'),
                        value: _nonTransferrable,
                        activeColor: Theme.of(context).indicatorColor,
                        checkColor: Colors.black,
                        onChanged: (value) {
                          if (_nonTransferrable == true && value == false) {
                            showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                      title: const Text('Be advised:'),
                                      content: Padding(
                                        padding: const EdgeInsets.all(28.0),
                                        child: SizedBox(
                                            width: 450,
                                            height: 270,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                    'Using a transferable governance token is not compatible with the reputation-based logical architecture of the On-Chain Jurisdiction.\n\nThis action is non-reversible.',
                                                    style: TextStyle(
                                                        height: 1.5)),
                                                const SizedBox(height: 64),
                                                RichText(
                                                    text: TextSpan(
                                                  style: const TextStyle(
                                                      fontSize: 13,
                                                      color: Color.fromARGB(
                                                          255, 255, 255, 255)),
                                                  children: [
                                                    const TextSpan(
                                                        text:
                                                            "Learn more about the implications ",
                                                        style: TextStyle(
                                                            fontSize: 16)),
                                                    TextSpan(
                                                      text: "here",
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          color: Theme.of(
                                                                  context)
                                                              .indicatorColor,
                                                          decoration:
                                                              TextDecoration
                                                                  .underline),
                                                      recognizer:
                                                          TapGestureRecognizer()
                                                            ..onTap = () =>
                                                                launchUrl(Uri.parse(
                                                                    "https://docs.openzeppelin.com/contracts/5.x/api/governance")),
                                                    ),
                                                  ],
                                                )),
                                              ],
                                            )),
                                      ),
                                      actionsAlignment:
                                          MainAxisAlignment.center,
                                      actionsPadding:
                                          const EdgeInsets.all(40),
                                      actions: [
                                        TextButton(
                                            onPressed: () =>
                                                Navigator.of(context).pop(),
                                            child: const Text("< Back")),
                                        const SizedBox(width: 180),
                                        ElevatedButton(
                                            onPressed: () {
                                              setState(() {
                                                _nonTransferrable = value!;
                                              });
                                              Navigator.of(context).pop();
                                            },
                                            child:
                                                const Text('I understand')),
                                      ],
                                    ));
                          } else {
                            setState(() {
                              _nonTransferrable = value!;
                            });
                          }
                        },
                      ),
                    ),
                  ] else if (_selectedMechanism ==
                      DaoTokenDeploymentMechanism.wrapExistingToken) ...[
                    SizedBox(
                      height: 115,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 380,
                            child: TextFormField(
                              controller: _underlyingTokenAddressController,
                              maxLength: 42,
                              decoration: const InputDecoration(
                                  labelText: 'Underlying Token Address',
                                  counterText: ""),
                              validator: (value) {
                                if (_selectedMechanism ==
                                    DaoTokenDeploymentMechanism
                                        .wrapExistingToken) {
                                  if (value == null || value.isEmpty) {
                                    return 'Address required';
                                  }
                                  if (!RegExp(r'^0x[a-fA-F0-9]{40}$')
                                      .hasMatch(value)) {
                                    return 'Invalid Ethereum address';
                                  }
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 20),
                          SizedBox(
                            width: 100,
                            child: TextFormField(
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'[a-zA-Z0-9]')),
                                UpperCaseTextFormatter(),
                              ],
                              maxLength: 7,
                              controller: _wrappedTokenSymbolController,
                              decoration: const InputDecoration(
                                  counterText: "", labelText: 'Symbol'),
                              validator: (value) {
                                if (_selectedMechanism ==
                                        DaoTokenDeploymentMechanism
                                            .wrapExistingToken &&
                                    (value == null || value.isEmpty)) {
                                  return 'Symbol required';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
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