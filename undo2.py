import json
import os

transcript_path = r'C:\Users\ACER\.gemini\antigravity-ide\brain\cd07278c-c09b-47b4-a249-61d3ad2ee90b\.system_generated\logs\transcript.jsonl'

edits = []

with open(transcript_path, 'r', encoding='utf-8') as f:
    for line in f:
        try:
            entry = json.loads(line)
        except:
            continue
            
        if 'replace_file_content' in line:
            if 'tool_calls' in entry:
                for tc in entry['tool_calls']:
                    name = tc.get('name', tc.get('function', {}).get('name', ''))
                    args_raw = tc.get('args', tc.get('function', {}).get('arguments', '{}'))
                    
                    if isinstance(args_raw, str):
                        try:
                            args = json.loads(args_raw)
                        except:
                            args = {}
                    else:
                        args = args_raw
                        
                    target_file = args.get('TargetFile')
                    if isinstance(target_file, str) and target_file.startswith('"') and target_file.endswith('"'):
                        target_file = target_file[1:-1]
                        
                    if name in ['default_api:replace_file_content', 'replace_file_content']:
                        old_t = args.get('TargetContent')
                        new_t = args.get('ReplacementContent')
                        if target_file and old_t and new_t:
                            edits.append({'file': target_file, 'old': old_t, 'new': new_t})
                    elif name in ['default_api:multi_replace_file_content', 'multi_replace_file_content']:
                        chunks_raw = args.get('ReplacementChunks', [])
                        if isinstance(chunks_raw, str):
                            try:
                                chunks_raw = json.loads(chunks_raw)
                            except:
                                chunks_raw = []
                        for chunk in chunks_raw:
                            if isinstance(chunk, str):
                                try:
                                    chunk = json.loads(chunk)
                                except:
                                    continue
                            old_t = chunk.get('TargetContent')
                            new_t = chunk.get('ReplacementContent')
                            if target_file and old_t and new_t:
                                edits.append({'file': target_file, 'old': old_t, 'new': new_t})

print(f"Total chunks extracted: {len(edits)}")

# Reverse the list to undo most recent first
edits.reverse()

success = 0
failed = 0

for e in edits:
    fp = e['file']
    old_t = e['old']
    new_t = e['new']
    
    # remove quotes if any
    if isinstance(old_t, str) and old_t.startswith('"') and old_t.endswith('"'):
        try: old_t = json.loads(old_t)
        except: pass
    if isinstance(new_t, str) and new_t.startswith('"') and new_t.endswith('"'):
        try: new_t = json.loads(new_t)
        except: pass
        
    if os.path.exists(fp):
        with open(fp, 'r', encoding='utf-8') as f:
            content = f.read()
        
        if new_t in content:
            content = content.replace(new_t, old_t, 1)
            with open(fp, 'w', encoding='utf-8') as f:
                f.write(content)
            print(f"Reversed chunk in {fp}")
            success += 1
        elif old_t in content:
            print(f"Already reversed chunk in {fp}")
            success += 1
        else:
            print(f"FAILED to find text to reverse in {fp}")
            failed += 1

print(f"Success: {success}, Failed: {failed}")
