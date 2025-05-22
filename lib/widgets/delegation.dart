import 'package:flutter/material.dart';
import 'package:Homebase/utils/theme.dart';

class DelegationWidget extends StatefulWidget {
  const DelegationWidget({super.key});

  @override
  _DelegationWidgetState createState() => _DelegationWidgetState();
}

class _DelegationWidgetState extends State<DelegationWidget> {
  String _delegationStatus = 'Set delegate'; // Default selection
  String _initialDelegationStatus = 'Set delegate';
  String _initialAddress = '0x548f66A1063A79E4F291Ebeb721C718DCc7965c5';

  final TextEditingController _controller = TextEditingController(
      text: '0x548f66A1063A79E4F291Ebeb721C718DCc7965c5');
  final _formKey = GlobalKey<FormState>();

  bool get _isDelegateSelected => _delegationStatus == 'Set delegate';

  // Regular expression to validate Ethereum addresses
  final RegExp _ethereumAddressRegExp = RegExp(r'^0x[a-fA-F0-9]{40}$');

  // Determines if any changes have been made
  bool get _hasChanged {
    return _delegationStatus != _initialDelegationStatus ||
        _controller.text != _initialAddress;
  }

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    setState(() {
      // Rebuild to update the submit button and text color state
    });
  }

  void _onRadioChanged(String? value) {
    setState(() {
      _delegationStatus = value!;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Determine the text field color based on whether the field is enabled
    Color textColor = _isDelegateSelected ? Colors.white : Colors.grey;

    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(38.0),
        child: Column(
          children: [
            const Text('Delegation Status', style: TextStyle(fontSize: 21)),
            const SizedBox(height: 50),
            ListTile(
              title: const Text('Not delegating'),
              leading: Radio<String>(
                value: 'Not delegating',
                groupValue: _delegationStatus,
                onChanged: _onRadioChanged,
              ),
            ),
            ListTile(
              title: const Text('Set delegate'),
              leading: Radio<String>(
                value: 'Set delegate',
                groupValue: _delegationStatus,
                onChanged: _onRadioChanged,
              ),
            ),
            TextFormField(
              controller: _controller,
              enabled: _isDelegateSelected,
              decoration: const InputDecoration(
                labelText: 'Delegate Address',
              ),
              style: TextStyle(
                color: textColor,
              ),
              validator: (value) {
                if (!_isDelegateSelected) return null;
                if (value == null || value.isEmpty) {
                  return 'Please enter a delegate address';
                }
                if (!_ethereumAddressRegExp.hasMatch(value)) {
                  return 'Invalid Ethereum address';
                }
                return null;
              },
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.resolveWith<Color>(
                  (Set<WidgetState> states) {
                    if (states.contains(WidgetState.disabled)) {
                      return Colors.grey; // Disabled color
                    }
                    return createMaterialColor(Theme.of(context).indicatorColor);
                  },
                ),
              ),
              onPressed: _hasChanged
                  ? () {
                      if (_formKey.currentState!.validate()) {
                        if (_isDelegateSelected) {
                          String delegateAddress = _controller.text;
                          // Handle delegation logic here
                          print('Delegating to $delegateAddress');
                        } else {
                          // Handle not delegating logic here
                          print('Not delegating');
                        }
                        // Update initial values after submission
                        setState(() {
                          _initialDelegationStatus = _delegationStatus;
                          _initialAddress = _controller.text;
                        });
                      }
                    }
                  : null, // Disable button if no changes
              child: const SizedBox(
                height: 40,
                width: 100,
                child: Center(
                  child: Text('Submit', style: TextStyle(color: Colors.black)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
