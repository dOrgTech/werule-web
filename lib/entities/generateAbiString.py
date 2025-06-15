import json
import re

# Load the ABI from the Dart file
with open('abis.dart', 'r') as dart_file:
    dart_content = dart_file.read()

# Use regex to extract the ABI JSON string within the triple quotes (''')
# This assumes the ABI is assigned to a variable like: `String daoabi='''[ ... ];`
abi_match = re.search(r"wrapperAbiGlobal\s*=\s*'''(.*?)'''", dart_content, re.DOTALL)

if abi_match:
    abi_str = abi_match.group(1)
else:
    raise ValueError("Couldn't find the ABI definition in the Dart file.")

# Parse the extracted ABI string into JSON
abi = json.loads(abi_str)

# Extract relevant function signatures
flutter_abi_strings = [
    f"'function {item['name']} ({', '.join(input['type'] for input in item['inputs'])})'"
    for item in abi if item['type'] == 'function'
]

# Format as a Flutter list
output = "List<String> timelockAbiString=[\n  " + ",\n  ".join(flutter_abi_strings) + "\n];"

# Write to output file
with open('flutterAbi.txt', 'w') as output_file:
    output_file.write(output)

print("Flutter ABI saved to flutterAbi.txt")
