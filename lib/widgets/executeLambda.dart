import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ContractInteractionWidget extends StatefulWidget {
  @override
  _ContractInteractionWidgetState createState() => _ContractInteractionWidgetState();
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
      _paramControllers.clear(); // Clear parameter controllers for the new function selection
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
        _functionParameters[_selectedFunction!]!
            .asMap()
            .entries
            .every((entry) {
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

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 600,
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
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
              children: [
                if (_isFirstStep)
                 Spacer(),
                    
                _isFirstStep
                    ? ElevatedButton(
                        onPressed: _isFormValid ? _goToNextStep : null,
                        child: Text('Next'),
                      )
                    : ElevatedButton(
                        onPressed: _goBack,
                        child: Text('Back'),
                      ),
                if (!_isFirstStep)
                  ElevatedButton(
                    onPressed: _isFormValid
                        ? () {
                            // Trigger contract interaction logic here
                          }
                        : null,
                    child: Text('Submit'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
