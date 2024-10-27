import 'package:flutter/material.dart';
import '../screens/creator.dart'; // Import for DurationInput widget

class DaoConfigurationWidget extends StatefulWidget {
  @override
  _DaoConfigurationWidgetState createState() => _DaoConfigurationWidgetState();
}

class _DaoConfigurationWidgetState extends State<DaoConfigurationWidget> {
  String? _selectedConfigType;
  bool _isFormValid = false;

  // Controllers for different configuration inputs
  final TextEditingController _treasuryAddressController = TextEditingController(text: '0x0881F2000c386A6DD6c73bfFD9196B1e99f108fF');
  final TextEditingController _votingDelayDaysController = TextEditingController(text: '0');
  final TextEditingController _votingDelayHoursController = TextEditingController(text: '0');
  final TextEditingController _votingDelayMinutesController = TextEditingController(text: '2');
  final TextEditingController _votingPeriodDaysController = TextEditingController(text: '0');
  final TextEditingController _votingPeriodHoursController = TextEditingController(text: '0');
  final TextEditingController _votingPeriodMinutesController = TextEditingController(text: '5');

  double _quorumValue = 4.0;

  void _selectConfigType(String configType) {
    setState(() {
      _selectedConfigType = configType;
      _isFormValid = configType == "Voting Delay" || configType == "Voting Period";
    });
  }

  void _validateForm() {
    bool isValid = false;
    if (_selectedConfigType == "Quorum") {
      isValid = _quorumValue != 4.0;
    } else if (_selectedConfigType == "Voting Delay") {
      isValid = true;  // Always enabled as requested
    } else if (_selectedConfigType == "Voting Period") {
      isValid = true;  // Always enabled as requested
    } else if (_selectedConfigType == "Switch Treasury") {
      isValid = _treasuryAddressController.text != '0x0881F2000c386A6DD6c73bfFD9196B1e99f108fF';
    }
    setState(() {
      _isFormValid = isValid;
    });
  }

  Widget _buildConfigSelection() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: 20),
        _buildConfigOptionButton("Quorum", Icons.group),
        SizedBox(height: 45),
        _buildConfigOptionButton("Voting Delay", Icons.hourglass_empty),
        SizedBox(height: 45),
        _buildConfigOptionButton("Voting Period", Icons.timer),
        SizedBox(height: 45),
        _buildConfigOptionButton("Switch Treasury", Icons.account_balance_wallet),
      ],
    );
  }

  Widget _buildConfigOptionButton(String title, IconData icon) {
    return SizedBox(
      width: 250,
      height: 130,
      child: ElevatedButton(
        onPressed: () => _selectConfigType(title),
        style: ElevatedButton.styleFrom(
          backgroundColor: Color.fromARGB(255, 78, 78, 78),
          foregroundColor: Colors.white,
          padding: EdgeInsets.all(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 30),
            SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 19),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuorumConfig() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Text(
          "Quorum",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(
          width: 400,
          child: Text(
            textAlign: TextAlign.center,
            "Change the minimum required participation for a proposal to pass",
            style: TextStyle(fontSize: 16),
          ),
        ),
        Slider(
          value: _quorumValue,
          min: 1,
          max: 100,
          divisions: 99,
          label: _quorumValue.round().toString(),
          onChanged: (value) {
            setState(() {
              _quorumValue = value;
            });
            _validateForm();
          },
        ),
      ],
    );
  }

  Widget _buildVotingDelayConfig() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Text(
          "Voting Delay",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(
          width: 400,
          child: Text(
            textAlign: TextAlign.center,
            "Change the wait time between posting a proposal and the start of voting",
            style: TextStyle(fontSize: 16),
          ),
        ),
        SizedBox(
          width: 400,
          child: DurationInput(
            title: "Voting Delay Duration",
            description: "",
            daysController: _votingDelayDaysController,
            hoursController: _votingDelayHoursController,
            minutesController: _votingDelayMinutesController,
          ),
        ),
      ],
    );
  }

  Widget _buildVotingPeriodConfig() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Text(
          "Voting Period",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(
          "Change how long voting lasts",
          style: TextStyle(fontSize: 16),
        ),
        SizedBox(
          width: 400,
          child: DurationInput(
            title: "Voting Period Duration",
            description: "",
            daysController: _votingPeriodDaysController,
            hoursController: _votingPeriodHoursController,
            minutesController: _votingPeriodMinutesController,
          ),
        ),
      ],
    );
  }

  Widget _buildTreasuryConfig() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Text(
          "Treasury Contract",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(
          "Switch the DAO to another Treasury",
          style: TextStyle(fontSize: 16),
        ),
        TextField(
          controller: _treasuryAddressController,
          decoration: InputDecoration(
            labelText: 'Treasury Contract Address',
            border: OutlineInputBorder(),
          ),
          onChanged: (_) => _validateForm(),
        ),
      ],
    );
  }

  Widget _buildConfigView() {
    switch (_selectedConfigType) {
      case "Quorum":
        return _buildQuorumConfig();
      case "Voting Delay":
        return _buildVotingDelayConfig();
      case "Voting Period":
        return _buildVotingPeriodConfig();
      case "Switch Treasury":
        return _buildTreasuryConfig();
      default:
        return _buildConfigSelection();
    }
  }

  void _resetToInitialView() {
    setState(() {
      _selectedConfigType = null;
      _isFormValid = false;
      _quorumValue = 4.0;
      _votingDelayDaysController.text = '0';
      _votingDelayHoursController.text = '0';
      _votingDelayMinutesController.text = '2';
      _votingPeriodDaysController.text = '0';
      _votingPeriodHoursController.text = '0';
      _votingPeriodMinutesController.text = '5';
      _treasuryAddressController.text = '0x0881F2000c386A6DD6c73bfFD9196B1e99f108fF';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(border: Border.all(color: Colors.grey, width: 0.3)),
      width: 600,
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _buildConfigView(),
              ),
            ),
          ),
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            margin: const EdgeInsets.only(bottom: 50),
            child: _selectedConfigType != null
                ? Center(
                    child: ElevatedButton(
                      onPressed: _isFormValid ? _resetToInitialView : null,
                      child: Text('Submit'),
                    ),
                  )
                : null,
          ),
        ],
      ),
    );
  }
}
