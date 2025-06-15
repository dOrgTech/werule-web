import json
from pathlib import Path
import re

# Path to your RooCode conversation history file
file_path = Path('./api_conversation_history.json')

if not file_path.exists():
    print(f"Error: File not found at {file_path}")
    exit(1)

with open(file_path, 'r', encoding='utf-8') as f:
    data = json.load(f)

def extract_metadata(env_text: str):
    lines = [line.strip() for line in env_text.splitlines()]
    time = cost = tokens = slug = model = ''
    i = 0
    while i < len(lines):
        line = lines[i]
        if line == '# Current Time':
            j = i + 1
            while j < len(lines) and not lines[j]:
                j += 1
            if j < len(lines):
                time = lines[j]
            i = j
        elif line == '# Current Cost':
            j = i + 1
            while j < len(lines) and not lines[j]:
                j += 1
            if j < len(lines):
                cost = lines[j]
            i = j
        elif line.startswith('# Current Context Size'):
            j = i + 1
            while j < len(lines) and not lines[j]:
                j += 1
            if j < len(lines):
                tokens = lines[j]
            i = j
        else:
            if '<slug>' in line and '</slug>' in line:
                m = re.search(r'<slug>([^<]+)</slug>', line)
                if m:
                    slug = m.group(1)
            if '<model>' in line and '</model>' in line:
                m = re.search(r'<model>([^<]+)</model>', line)
                if m:
                    model = m.group(1)
        i += 1

    return time, cost, tokens, slug, model

tasks_info = []
total_cost = 0.0
total_tokens = 0

for entry in data:
    if entry.get('role') != 'user':
        continue

    content_list = entry.get('content', [])
    if not content_list:
        continue

    first_text = content_list[0].get('text', '')
    first_message = re.sub(r'</?task>', '', first_text).strip()

    env_text = ''
    for item in content_list:
        txt = item.get('text', '')
        if '# Current Time' in txt or '# Current Cost' in txt:
            env_text = txt
            break

    if env_text:
        time, cost, tokens, slug, model = extract_metadata(env_text)
    else:
        time = cost = tokens = slug = model = ''

    # parse cost (format: "$<number>")
    cost_value = 0.0
    if cost.startswith('$'):
        try:
            cost_value = float(cost.replace('$', '').strip())
        except ValueError:
            cost_value = 0.0
    total_cost += cost_value

    # parse tokens (numeric or "(Not available)")
    tokens_value = 0
    if tokens.isdigit():
        tokens_value = int(tokens)
    total_tokens += tokens_value

    tasks_info.append({
        'First Message': first_message,
        'Time': time,
        'Cost': cost,
        'Tokens': tokens,
        'Mode': slug,
        'Model': model
    })

for idx, task in enumerate(tasks_info, start=1):
    print(f"Task {idx}:")
    print(f"  First Message: {task['First Message']}")
    print(f"  Time:          {task['Time']}")
    print(f"  Cost:          {task['Cost']}")
    print(f"  Tokens:        {task['Tokens']}")
    print(f"  Mode:          {task['Mode']}")
    print(f"  Model:         {task['Model']}")
    print("\n" + "-"*50 + "\n")

print(f"Total Tasks:   {len(tasks_info)}")
print(f"Total Cost:    ${total_cost:.2f}")
print(f"Total Tokens:  {total_tokens}")
