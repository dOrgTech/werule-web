// import 'package:flutter/material.dart';
// import 'dart:html' as html;
// import '../entities/org.dart';
// import '../screens/creator.dart';

// class Screen5Members extends StatefulWidget {
//   final DaoConfig daoConfig;
//   final VoidCallback onBack;
//   final VoidCallback onNext;

//   Screen5Members({
//     required this.daoConfig,
//     required this.onBack,
//     required this.onNext,
//   });

//   @override
//   _Screen5MembersState createState() => _Screen5MembersState();
// }

// class _Screen5MembersState extends State<Screen5Members> {
//   List<MemberEntry> _memberEntries = [];
//   bool isManualEntry = false;
//   bool isCsvUploaded = false;
//   int _totalTokens = 0;

//   @override
//   void initState() {
//     super.initState();
//     if (widget.daoConfig.members.isNotEmpty) {
//       _memberEntries = widget.daoConfig.members
//           .map((member) => MemberEntry(
//                 addressController: TextEditingController(text: member.address),
//                 amountController:
//                     TextEditingController(text: member.amount.toString()),
//               ))
//           .toList();
//     } else {
//       _addMemberEntry();
//     }
//     _calculateTotalTokens();
//   }
  

//   void _addMemberEntry() {
//     setState(() {
//       _memberEntries.add(MemberEntry(
//         addressController: TextEditingController(),
//         amountController: TextEditingController(),
//       ));
//     });
//   }

//   void _loadCsvFile() async {
//     html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
//     uploadInput.accept = '.csv';
//     uploadInput.click();

//     uploadInput.onChange.listen((e) {
//       final files = uploadInput.files;
//       if (files != null && files.length == 1) {
//         final file = files[0];
//         final reader = html.FileReader();

//         reader.onLoadEnd.listen((e) {
//           final contents = reader.result as String;
//           _processCsvData(contents);
//         });

//         reader.readAsText(file);
//       }
//     });
//   }

//   void _processCsvData(String fileContent) {
//     List<String> lines = fileContent.split(RegExp(r'\r?\n')).where((line) => line.trim().isNotEmpty).toList();

//     if (lines.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('The CSV file is empty.')),
//       );
//       return;
//     }

//     List<String> headers = lines[0].split(',');
//     if (headers.length < 2 || headers[0].trim().toLowerCase() != 'address' || headers[1].trim().toLowerCase() != 'amount') {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Invalid CSV headers. Expected "address" and "amount".')),
//       );
//       return;
//     }
//     lines.removeAt(0);

//     List<MemberEntry> entries = [];
//     for (var line in lines) {
//       List<String> values = line.split(',');
//       if (values.length >= 2) {
//         String address = values[0].trim();
//         String amount = values[1].trim();

//         if (address.isNotEmpty && amount.isNotEmpty) {
//           entries.add(MemberEntry(
//             addressController: TextEditingController(text: address),
//             amountController: TextEditingController(text: amount),
//           ));
//         }
//       }
//     }

//     setState(() {
//       _memberEntries = entries;
//       isCsvUploaded = true;
//       _calculateTotalTokens();
//     });
//   }

//   Widget _buildInitialButtons() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 20.0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           TextButton(
//             onPressed: () {
//                     _loadCsvFile();
//                   },
//             child: Container(
//               height: 130,
//               width: 170,
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
                
//                    Icon(Icons.upload_file, size: 35,),
                  
//                   SizedBox(height: 25),
//                    Text("Upload CSV"),
                  
//                 ],
//               ),
//             ),
//           ),
//           SizedBox(width: 20),
//           TextButton(
//             onPressed: () {
//                       setState(() {
//                         isManualEntry = true;
//                         _addMemberEntry();
//                       });
//                     },
                  
//             child: Container(
//               height: 130,
//               width: 170,
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(Icons.group_add, size: 35),
//                   SizedBox(height: 25),  
//               Text("Add members\nmanually", textAlign: TextAlign.center,),
                  
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildManualEntry() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 20.0),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           ListView.builder(
//             shrinkWrap: true,
//             physics: NeverScrollableScrollPhysics(),
//             itemCount: _memberEntries.length,
//             itemBuilder: (context, index) {
//               return MemberEntryWidget(
//                 entry: _memberEntries[index],
//                 onRemove: () {
//                   setState(() {
//                     _memberEntries.removeAt(index);
//                     _calculateTotalTokens();
//                   });
//                 },
//                 onChanged: _calculateTotalTokens,
//               );
//             },
//           ),
//           SizedBox(height: 10),
//           Center(
//             child: SizedBox(
//               width: 240,
//               child: TextButton(
//                 onPressed: _addMemberEntry,
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(Icons.add),
//                     Text(' Add Member'),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildCsvTable() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 20.0),
//       child: Center(
//         child: Container(
//           decoration: BoxDecoration(
//             border: Border.all(color: Color.fromARGB(255, 74, 74, 74)),
//           color:Color.fromARGB(255, 32, 32, 32),
//           ),
//           width: 600,
//           height: 500,
//           child: SingleChildScrollView(
//             scrollDirection: Axis.vertical,
//             child: DataTable(
//               columns: [
//                 DataColumn(label: Text('Address')),
//                 DataColumn(label: Text('Amount')),
//               ],
//               rows: _memberEntries.map((entry) {
//                 return DataRow(cells: [
//                   DataCell(Text(entry.addressController.text)),
//                   DataCell(Text(entry.amountController.text)),
//                 ]);
//               }).toList(),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   void _calculateTotalTokens() {
//     int total = 0;
//     for (var entry in _memberEntries) {
//       int amount = int.tryParse(entry.amountController.text) ?? 0;
//       total += amount;
//     }
//     widget.daoConfig.totalSupply = total.toString();
//     setState(() {
//       _totalTokens = total;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             Center(child: Text('Initial members', style: Theme.of(context).textTheme.headline5)),
//             SizedBox(height: 100),
//             const Center(
//               child: Text(
//                 'Specify the address and the voting power of your associates.\nVoting power is represented by their amount of tokens.',
//                 style: TextStyle(fontSize: 14, color: Color.fromARGB(255, 194, 194, 194)),
//                 textAlign: TextAlign.center,
//               ),
//             ),
//             SizedBox(height: 30),
//             if (isManualEntry || isCsvUploaded)
//               Padding(
//                 padding: const EdgeInsets.only(bottom: 20.0),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text('Total Tokens: ', style: TextStyle(fontSize: 19)),
//                     Text(
//                       '$_totalTokens',
//                       style: TextStyle(fontSize: 19, color: Theme.of(context).indicatorColor),
//                     ),
//                   ],
//                 ),
//               ),
//             if (!isManualEntry && !isCsvUploaded) _buildInitialButtons(),
//             if (isManualEntry) _buildManualEntry(),
//             if (isCsvUploaded) _buildCsvTable(),
//             if (isManualEntry || isCsvUploaded)
//               Padding(
//                 padding: const EdgeInsets.only(top: 30.0),
//                 child: Center(
//                   child: SizedBox(
//                     width: 700,
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         TextButton(
//                           onPressed: widget.onBack,
//                           child: Text('< Back'),
//                         ),
//                         ElevatedButton(
//                           onPressed: widget.onNext,
//                           child: Text('Continue >'),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }
