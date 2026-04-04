import os, re

BASE = r"C:\Users\basem\OneDrive\Desktop\Alhai"
DIRS = [
    os.path.join(BASE, "packages", "alhai_shared_ui", "lib", "src"),
    os.path.join(BASE, "packages", "alhai_pos", "lib", "src"),
    os.path.join(BASE, "apps", "cashier", "lib"),
    os.path.join(BASE, "apps", "admin", "lib"),
]

total_files = 0
total_fixes = 0

# Fix const TextStyle/Icon/Container that now contain Theme.of(context)
CONST_FIXES = [
    # const TextStyle(... Theme.of(context)... -> TextStyle(... Theme.of(context)...
    (r'const\s+TextStyle\(([^)]*?)Theme\.of\(', r'TextStyle(\1Theme.of('),
    # const Icon(... Theme.of(context)... -> Icon(... Theme.of(context)...
    (r'const\s+Icon\(([^)]*?)Theme\.of\(', r'Icon(\1Theme.of('),
    # const Container(... Theme.of(context)... -> Container(... Theme.of(context)...
    (r'const\s+Container\(([^)]*?)Theme\.of\(', r'Container(\1Theme.of('),
    # const Center(... Theme.of(context)... -> Center(... Theme.of(context)...
    (r'const\s+Center\(([^)]*?)Theme\.of\(', r'Center(\1Theme.of('),
    # const SnackBar(... Theme.of(context)... -> SnackBar(... Theme.of(context)...
    (r'const\s+SnackBar\(([^)]*?)Theme\.of\(', r'SnackBar(\1Theme.of('),
    # const Text(... Theme.of(context)... -> Text(... Theme.of(context)...
    (r'const\s+Text\(([^)]*?)Theme\.of\(', r'Text(\1Theme.of('),
]

for d in DIRS:
    if not os.path.isdir(d):
        continue
    for root, dirs, files in os.walk(d):
        for fname in files:
            if not fname.endswith('.dart'):
                continue
            fpath = os.path.join(root, fname)
            try:
                with open(fpath, 'r', encoding='utf-8') as f:
                    content = f.read()
            except:
                continue

            if 'Theme.of(' not in content:
                continue

            original = content
            file_count = 0

            for pattern, replacement in CONST_FIXES:
                new_content, n = re.subn(pattern, replacement, content, flags=re.DOTALL)
                if n > 0:
                    file_count += n
                    content = new_content

            if file_count > 0:
                with open(fpath, 'w', encoding='utf-8') as f:
                    f.write(content)
                total_files += 1
                total_fixes += file_count
                rel = os.path.relpath(fpath, BASE)
                print(f"  {rel}: {file_count} const fixes")

print(f"\nConst fix pass 2 DONE: {total_files} files, {total_fixes} fixes")
