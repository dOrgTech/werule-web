import 'blockscout.dart';

void main() async {
  var address = "0x394e83e6D2B9c0c20e3c328448D6Ce5aFc183b97";
  var balances = await getHolders(address);
  print(balances);
}
