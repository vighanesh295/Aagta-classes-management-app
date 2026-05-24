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
        
        if 'tool_calls' in entry:
            for tc in entry['tool_calls']:
                name = tc.get('name', '')
                if not name:
                    name = tc.get('function', {}).get('name', '')
                
                args_raw = tc.get('args', {})
                if not args_raw:
                    args_raw = tc.get('function', {}).get('arguments', '{}')

                if isinstance(args_raw, str):
                    try:
                        args = json.loads(args_raw)
                    except:
                        args = {}
                else:
                    args = args_raw
                
                for k, v in args.items():
                    if isinstance(v, str) and (v.startswith('{') or v.startswith('[')):
                        try:
                            args[k] = json.loads(v)
                        except:
                            pass
                
                if name in ['default_api:replace_file_content', 'replace_file_content']:
                    try:
                        target_file = args.get('TargetFile')
                        target_content = args.get('TargetContent')
                        repl_content = args.get('ReplacementContent')
                        if target_file and target_content and repl_content:
                            edits.append({
                                'file': target_file,
                                'old': target_content,
                                'new': repl_content
                            })
                    except:
                        pass
                elif name in ['default_api:multi_replace_file_content', 'multi_replace_file_content']:
                    try:
                        target_file = args.get('TargetFile')
                        chunks = args.get('ReplacementChunks', [])
                        if isinstance(chunks, str):
                            try:
                                chunks = json.loads(chunks)
                            except:
                                chunks = []
                        for chunk in chunks:
                            target_content = chunk.get('TargetContent')
                            repl_content = chunk.get('ReplacementContent')
                            if target_file and target_content and repl_content:
                                edits.append({
                                    'file': target_file,
                                    'old': target_content,
                                    'new': repl_content
                                })
                    except Exception as e:
                        print('Error parsing chunk:', e)

print(f'Found {len(edits)} edits in history.')

# Reverse
edits.reverse()

success_count = 0
failed_count = 0

for edit in edits:
    filepath = edit['file']
    old_text = edit['old']
    new_text = edit['new']
    
    if os.path.exists(filepath):
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
            
        if new_text in content:
            content = content.replace(new_text, old_text, 1)
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(content)
            print(f'Reversed an edit in {filepath}')
            success_count += 1
        elif old_text in content:
            print(f'Edit already reversed or not applied in {filepath}')
        else:
            print(f'Failed to undo in {filepath}')
            failed_count += 1
            
print(f'Successfully reversed {success_count} edits. Failed {failed_count}.')
