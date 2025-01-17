import os
import json

def gather_text_to_md(config_file, output_file):
    # Load configuration file
    with open(config_file, 'r') as f:
        config = f.readlines()

    base_path = os.path.dirname(os.path.abspath(__file__))
    all_files = set()

    for line in config:
        line = line.strip()

        if not line or line.startswith("#"):
            # Skip empty lines or comments
            continue

        if line.endswith("/"):
            # Handle directories
            directory = os.path.join(base_path, line[:-1])
            if os.path.isdir(directory):
                for root, _, files in os.walk(directory):
                    for file in files:
                        all_files.add(os.path.relpath(os.path.join(root, file), base_path))
            else:
                print(f"Directory not found: {directory}")
        else:
            # Handle individual files
            file_path = os.path.join(base_path, line)
            if os.path.isfile(file_path):
                all_files.add(os.path.relpath(file_path, base_path))
            else:
                print(f"File not found: {file_path}")

    # Open the output Markdown file for writing
    with open(output_file, 'w') as md_file:
        for relative_path in sorted(all_files):
            absolute_path = os.path.join(base_path, relative_path)

            if os.path.isfile(absolute_path):
                # Write the file name
                md_file.write(f"### {relative_path}\n\n")

                # Write the file content as code block
                with open(absolute_path, 'r') as code_file:
                    content = code_file.read()
                    md_file.write("```\n")
                    md_file.write(content)
                    md_file.write("\n````\n\n")

    print(f"Markdown file created: {output_file}")

# Example usage:
# Assuming a config file exists with the following structure:
# folder_name/
# file_name
# folder_name/file_name
config_path = "config.txt"
output_path = "output.md"

# Call the function to generate the Markdown file
gather_text_to_md(config_path, output_path)
