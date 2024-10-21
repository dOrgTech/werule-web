
Map<String, DateTime> statusHistory={};




void main() {
  statusHistory.addAll({"pending":DateTime.now()});
  print("hello");
  
 statusHistory.forEach((key, value) { 
  print(key);
 });
}
  