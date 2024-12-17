import 'package:Homebase/screens/creator.dart';
import 'package:Homebase/widgets/newProposal.dart';
import 'package:Homebase/widgets/registryPropo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../entities/contractFunctions.dart';
import '../entities/org.dart';
import '../entities/proposal.dart';
import '../screens/dao.dart';

class ACI extends StatefulWidget {
  Proposal p;
  Org? org;
  int stage = 0;
  State proposalsState;
  bool isSetInfo = true;
  ACI({
    Key? key,
    required this.proposalsState,
    required this.p,
    required this.org,
  }) : super(key: key) {
    p.type = "contract call";
  }

  @override
  State<ACI> createState() => _ACIState();
}

class _ACIState extends State<ACI> {
  final _formKey = GlobalKey<FormState>();
  final _keyController = TextEditingController();
  final _callDataController = TextEditingController();
  final _targetController = TextEditingController();
  final _amountController = TextEditingController();
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  // Example JSON placeholder
  final String _jsonExample = '''
        {
          "function": "transfer",
          "parameters": {
            "uint": 12345,
            "address": "0x1234567890abcdef"
          }
        }''';
  @override
  void dispose() {
    _keyController.dispose();
    _callDataController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {}
  }

  finishSettingInfo() {
    setState(() {
      widget.isSetInfo = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    if (!_focusNode.hasFocus && _controller.text.isEmpty) {
      setState(() {
        _controller.text = _jsonExample;
      });
    } else if (_focusNode.hasFocus && _controller.text == _jsonExample) {
      setState(() {
        _controller.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.isSetInfo
        ? NewProposal(p: widget.p, next: finishSettingInfo)
        : widget.stage == -1
            ? const AwaitingConfirmation()
            : Form(
                key: _formKey,
                child: Container(
                  width: 650,
                  padding: const EdgeInsets.all(26.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 52.0),
                        child: TextFormField(
                          onChanged: (value) {
                            widget.p.values = [value.toString()];
                          },
                          controller: _targetController,
                          decoration: const InputDecoration(
                              labelText: 'Target Contract'),
                          validator: (value) => value == null || value.isEmpty
                              ? '0xa47Fe903cE6d....'
                              : null,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 152.0),
                        child: TextFormField(
                          onChanged: (value) {},
                          controller: _amountController,
                          decoration: const InputDecoration(
                              labelText: 'Value in XTZ to attach'),
                          validator: (value) => value == null || value.isEmpty
                              ? '0xa47Fe903cE6d....'
                              : "0",
                        ),
                      ),
                      TextFormField(
                        maxLines: 8,
                        controller: _controller,
                        focusNode: _focusNode,
                        decoration: const InputDecoration(
                          labelText: 'Function JSON Definition',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please enter a value'
                            : null,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 52.0),
                        child: TextFormField(
                          onChanged: (value) {},
                          controller: _callDataController,
                          decoration:
                              const InputDecoration(labelText: 'callData'),
                          validator: (value) => value == null || value.isEmpty
                              ? '0xa47Fe903cE6d....'
                              : null,
                        ),
                      ),
                      SubmitButton(
                          submit: () async {
                            widget.p.callDatas = [];
                            widget.p.callData = _controller.text;
                            String calldata0 = _callDataController.text;
                            widget.p.callDatas.add(calldata0);
                            widget.p.targets = [_targetController.text];
                            widget.p.values = [_amountController.text];
                            widget.p.createdAt = DateTime.now();
                            widget.p.statusHistory
                                .addAll({"pending": DateTime.now()});
                            setState(() {
                              widget.stage = -1;
                            });
                            try {
                              String cevine = "";
                              await propose(widget.p);
                              if (cevine.contains("not ok")) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(
                                        duration: Duration(seconds: 1),
                                        content: Center(
                                            child: SizedBox(
                                                height: 70,
                                                child: Center(
                                                  child: Text(
                                                    "Error submitting proposal",
                                                    style: TextStyle(
                                                        fontSize: 24,
                                                        color: Colors.red),
                                                  ),
                                                )))));
                                Navigator.of(context).pop();
                                return;
                              }
                              // widget.p.status = "pending";
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
                                      duration: Duration(seconds: 1),
                                      content: Center(
                                          child: SizedBox(
                                              height: 70,
                                              child: Center(
                                                child: Text(
                                                  "Proposal submitted",
                                                  style:
                                                      TextStyle(fontSize: 24),
                                                ),
                                              )))));
                            } catch (e) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
                                      duration: Duration(seconds: 1),
                                      content: Center(
                                          child: SizedBox(
                                              height: 70,
                                              child: Center(
                                                child: Text(
                                                  "Error submitting proposal",
                                                  style: TextStyle(
                                                      fontSize: 24,
                                                      color: Colors.red),
                                                ),
                                              )))));
                            }

                            // Navigator.of(context).push(MaterialPageRoute(
                            //     builder: (context) => Scaffold(
                            //         body:
                            //             //  DaoSetupWizard())
                            //             // Center(child: TransferWidget(org: orgs[0],)))
                            //             DAO(
                            //                 InitialTabIndex: 1,
                            //                 org: widget.org))));
                          },
                          isSubmitEnabled: true)
                    ],
                  ),
                ),
              );
  }
}

class ContractInteractionWidget extends StatefulWidget {
  Proposal p;
  ContractInteractionWidget({required this.p});
  @override
  _ContractInteractionWidgetState createState() =>
      _ContractInteractionWidgetState();
}

class _ContractInteractionWidgetState extends State<ContractInteractionWidget> {
  final TextEditingController _contractController = TextEditingController();
  final TextEditingController _valueController = TextEditingController();
  final Map<String, List<Map<String, String>>> _functionParameters = {
    'functionA': [
      {'name': '_member', 'type': 'address'},
      {'name': 'amount', 'type': 'number'},
    ],
    'functionB': [
      {'name': 'param', 'type': 'string'},
    ],
    'functionC': [
      {'name': '_target', 'type': 'address'},
      {'name': 'value', 'type': 'number'},
    ],
  };
  String? _selectedFunction;
  List<TextEditingController> _paramControllers = [];
  bool isSetInfo = true;
  bool _isFirstStep = true;
  bool _isLoading = false;
  bool _isFormValid = false;

  @override
  void dispose() {
    _contractController.dispose();
    _valueController.dispose();
    for (var controller in _paramControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  bool _isValidEvmAddress(String address) {
    return RegExp(r"^0x[a-fA-F0-9]{40}$").hasMatch(address);
  }

  bool _isValueValid(String value) {
    return double.tryParse(value) != null;
  }

  void _validateForm() {
    setState(() {
      _isFormValid = _isValidEvmAddress(_contractController.text) &&
          _isValueValid(_valueController.text);
    });
  }

  void _goToNextStep() async {
    setState(() {
      _isLoading = true;
    });
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      _isLoading = false;
      _isFirstStep = false;
      _selectedFunction = null;
      _paramControllers
          .clear(); // Clear parameter controllers for the new function selection
      _isFormValid = false; // Reset form validity for second step
    });
  }

  void _goBack() {
    setState(() {
      _isFirstStep = true;
      _validateForm(); // Revalidate first step fields
    });
  }

  void _initializeParameterControllers() {
    _paramControllers = _functionParameters[_selectedFunction]!
        .map((_) => TextEditingController())
        .toList();
  }

  void _validateSubmitButton() {
    bool allParamsFilled = _paramControllers.isNotEmpty &&
        _paramControllers.every((controller) => controller.text.isNotEmpty);
    bool allParamsValid = _selectedFunction != null &&
        _functionParameters[_selectedFunction!]!.asMap().entries.every((entry) {
          final paramType = entry.value['type'];
          final controller = _paramControllers[entry.key];
          if (paramType == 'address') {
            return _isValidEvmAddress(controller.text);
          } else if (paramType == 'number') {
            return double.tryParse(controller.text) != null;
          } else {
            return controller.text.isNotEmpty;
          }
        });

    setState(() {
      _isFormValid = allParamsFilled && allParamsValid;
    });
  }

  Widget _buildParameterInput(String name, String type, int index) {
    return Container(
      padding: const EdgeInsets.only(top: 12.0),
      child: TextFormField(
        controller: _paramControllers[index],
        decoration: InputDecoration(
          labelText: '$name ($type)',
          border: OutlineInputBorder(),
        ),
        keyboardType: type == 'number'
            ? TextInputType.numberWithOptions(decimal: true)
            : TextInputType.text,
        inputFormatters: type == 'number'
            ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))]
            : type == 'address'
                ? [FilteringTextInputFormatter.allow(RegExp(r'[a-fA-F0-9x]'))]
                : [],
        onChanged: (_) => _validateSubmitButton(),
      ),
    );
  }

  Widget _buildFirstStep() {
    return Column(
      children: [
        TextFormField(
          controller: _contractController,
          decoration: InputDecoration(
            labelText: 'Destination Contract Address',
            border: OutlineInputBorder(),
          ),
          onChanged: (_) => _validateForm(),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[a-fA-F0-9x]')),
          ],
        ),
        SizedBox(height: 16),
        TextFormField(
          controller: _valueController,
          decoration: InputDecoration(
            labelText: 'Attached Value',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
          ],
          onChanged: (_) => _validateForm(),
        ),
        SizedBox(height: 16),
      ],
    );
  }

  Widget _buildSecondStep() {
    return Column(
      children: [
        TextFormField(
          controller: _contractController,
          enabled: false,
          decoration: InputDecoration(
            labelText: 'Destination Contract Address (Locked)',
            border: OutlineInputBorder(),
          ),
        ),
        SizedBox(height: 16),
        TextFormField(
          controller: _valueController,
          enabled: false,
          decoration: InputDecoration(
            labelText: 'Attached Value (Locked)',
            border: OutlineInputBorder(),
          ),
        ),
        SizedBox(height: 16),
        _isLoading
            ? Center(child: CircularProgressIndicator())
            : DropdownButtonFormField<String>(
                hint: Text('Select Function'),
                value: _selectedFunction,
                items: _functionParameters.keys
                    .map((function) => DropdownMenuItem(
                          value: function,
                          child: Text(function),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedFunction = value;
                    _initializeParameterControllers();
                    _validateSubmitButton();
                  });
                },
              ),
        if (_selectedFunction != null && !_isLoading)
          ..._functionParameters[_selectedFunction!]!
              .asMap()
              .entries
              .map((entry) => _buildParameterInput(
                  entry.value['name']!, entry.value['type']!, entry.key))
              .toList(),
      ],
    );
  }

  completeSetInfo() {
    setState(() {
      isSetInfo = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isSetInfo
        ? NewProposal(p: widget.p, next: completeSetInfo)
        : Container(
            width: 600,
            constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.7),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: _isLoading
                          ? Center(child: CircularProgressIndicator())
                          : _isFirstStep
                              ? _buildFirstStep()
                              : _buildSecondStep(),
                    ),
                  ),
                ),
                Container(
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  margin: const EdgeInsets.only(bottom: 50),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: isSetInfo
                        ? []
                        : [
                            if (_isFirstStep) Spacer(),
                            _isFirstStep
                                ? ElevatedButton(
                                    onPressed:
                                        _isFormValid ? _goToNextStep : null,
                                    child: Text('Next'),
                                  )
                                : TextButton(
                                    onPressed: _goBack,
                                    child: Text('< Back'),
                                  ),
                            if (!_isFirstStep)
                              SubmitButton(
                                  submit: () {}, isSubmitEnabled: _isFormValid)
                          ],
                  ),
                ),
              ],
            ),
          );
  }
}
