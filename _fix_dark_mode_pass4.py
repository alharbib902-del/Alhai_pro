import os, re, sys

BASE = r"C:\Users\basem\OneDrive\Desktop\Alhai"
DIRS = [
    os.path.join(BASE, "packages", "alhai_shared_ui", "lib", "src"),
    os.path.join(BASE, "packages", "alhai_pos", "lib", "src"),
    os.path.join(BASE, "apps", "cashier", "lib"),
    os.path.join(BASE, "apps", "admin", "lib"),
]

total_files = 0
total_replacements = 0

# Focus on isDark ternary patterns that remain
PATTERNS = [
    # isDark ? Colors.white : AppColors.textPrimary
    (r'isDark\s*\?\s*Colors\.white\s*:\s*AppColors\.textPrimary', 'Theme.of(context).colorScheme.onSurface'),
    # isDark ? Colors.white70 : AppColors.textSecondary
    (r'isDark\s*\?\s*Colors\.white70\s*:\s*AppColors\.textSecondary', 'Theme.of(context).colorScheme.onSurfaceVariant'),
    # isDark ? Colors.white54 : AppColors.textSecondary
    (r'isDark\s*\?\s*Colors\.white54\s*:\s*AppColors\.textSecondary', 'Theme.of(context).colorScheme.onSurfaceVariant'),
    # isDarkMode ? Colors.white : AppColors.textPrimary
    (r'isDarkMode\s*\?\s*Colors\.white\s*:\s*AppColors\.textPrimary', 'Theme.of(context).colorScheme.onSurface'),
    # isDarkMode ? Colors.white70 : AppColors.textSecondary
    (r'isDarkMode\s*\?\s*Colors\.white70\s*:\s*AppColors\.textSecondary', 'Theme.of(context).colorScheme.onSurfaceVariant'),
    # isDark ? Colors.white.withValues(alpha:0.1) : AppColors.border
    (r'isDark\s*\?\s*Colors\.white\.withValues\(alpha:\s*0\.1\)\s*:\s*AppColors\.border\b(?!\.)', 'Theme.of(context).dividerColor'),
    # isDarkMode ? Colors.white.withValues(alpha:0.1) : AppColors.border
    (r'isDarkMode\s*\?\s*Colors\.white\.withValues\(alpha:\s*0\.1\)\s*:\s*AppColors\.border\b(?!\.)', 'Theme.of(context).dividerColor'),
    # isDark ? Colors.white.withValues(alpha:0.05) : AppColors.border (end of line)
    (r'isDark\s*\?\s*Colors\.white\.withValues\(alpha:\s*0\.05\)\s*:\s*AppColors\.border\b(?!\.)', 'Theme.of(context).dividerColor'),
    # isDark/isDarkMode ? Colors.white.withValues(alpha:0.05) : AppColors.border.withValues(alpha:0.5)
    (r'isDark(?:Mode)?\s*\?\s*Colors\.white\.withValues\(alpha:\s*0\.05\)\s*:\s*AppColors\.border\.withValues\(alpha:\s*0\.5\)', 'Theme.of(context).dividerColor'),
    # isDark ? Colors.white.withValues(alpha:0.1) : AppColors.border.withValues(alpha:0.5)
    (r'isDark\s*\?\s*Colors\.white\.withValues\(alpha:\s*0\.1\)\s*:\s*AppColors\.border\.withValues\(alpha:\s*0\.5\)', 'Theme.of(context).dividerColor'),
    # isDark ? Colors.white.withValues(alpha:0.1) : AppColors.border.withValues(alpha:0.7)
    (r'isDark\s*\?\s*Colors\.white\.withValues\(alpha:\s*0\.1\)\s*:\s*AppColors\.border\.withValues\(alpha:\s*0\.7\)', 'Theme.of(context).dividerColor'),
    # isDark ? Colors.white.withValues(alpha:0.06) : AppColors.border.withValues(alpha:0.7)
    (r'isDark(?:Mode)?\s*\?\s*Colors\.white\.withValues\(alpha:\s*0\.06\)\s*:\s*AppColors\.border\.withValues\(alpha:\s*0\.7\)', 'Theme.of(context).dividerColor'),
    # isDark ? Colors.white.withValues(alpha:0.04) : AppColors.border.withValues(alpha:0.5)
    (r'isDark\s*\?\s*Colors\.white\.withValues\(alpha:\s*0\.04\)\s*:\s*AppColors\.border\.withValues\(alpha:\s*0\.5\)', 'Theme.of(context).dividerColor'),
    # isDark ? Colors.white.withValues(alpha:0.03) : AppColors.backgroundSecondary.withValues(alpha:0.5)
    (r'isDark(?:Mode)?\s*\?\s*Colors\.white\.withValues\(alpha:\s*0\.03\)\s*:\s*AppColors\.backgroundSecondary\.withValues\(alpha:\s*0\.5\)', 'Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)'),
    # isDark ? Colors.white.withValues(alpha:0.05) : AppColors.backgroundSecondary
    (r'isDark(?:Mode)?\s*\?\s*Colors\.white\.withValues\(alpha:\s*0\.05\)\s*:\s*AppColors\.backgroundSecondary', 'Theme.of(context).colorScheme.surfaceContainerHighest'),
    # isDark ? Colors.white.withValues(alpha:0.05) : AppColors.surfaceVariant
    (r'isDark(?:Mode)?\s*\?\s*Colors\.white\.withValues\(alpha:\s*0\.05\)\s*:\s*AppColors\.surfaceVariant', 'Theme.of(context).colorScheme.surfaceContainerHighest'),
    # isDark ? Colors.white.withValues(alpha:0.2) : AppColors.textTertiary
    (r'isDark(?:Mode)?\s*\?\s*Colors\.white\.withValues\(alpha:\s*0\.2\)\s*:\s*AppColors\.textTertiary', 'Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5)'),
    # isDark ? Colors.white.withValues(alpha:0.4) : AppColors.textTertiary
    (r'isDark(?:Mode)?\s*\?\s*Colors\.white\.withValues\(alpha:\s*0\.4\)\s*:\s*AppColors\.textTertiary', 'Theme.of(context).colorScheme.onSurfaceVariant'),
    # isDark ? Colors.white.withValues(alpha:0.5) : AppColors.textSecondary
    (r'isDark(?:Mode)?\s*\?\s*Colors\.white\.withValues\(alpha:\s*0\.5\)\s*:\s*AppColors\.textSecondary', 'Theme.of(context).colorScheme.onSurfaceVariant'),
    # isDark ? Colors.white.withValues(alpha:0.5) : AppColors.textTertiary
    (r'isDark(?:Mode)?\s*\?\s*Colors\.white\.withValues\(alpha:\s*0\.5\)\s*:\s*AppColors\.textTertiary', 'Theme.of(context).colorScheme.onSurfaceVariant'),
    # isDark ? Colors.white.withValues(alpha:0.6) : AppColors.textSecondary
    (r'isDark(?:Mode)?\s*\?\s*Colors\.white\.withValues\(alpha:\s*0\.6\)\s*:\s*AppColors\.textSecondary', 'Theme.of(context).colorScheme.onSurfaceVariant'),
    # isDark ? Colors.white.withValues(alpha:0.7) : AppColors.textPrimary
    (r'isDark(?:Mode)?\s*\?\s*Colors\.white\.withValues\(alpha:\s*0\.7\)\s*:\s*AppColors\.textPrimary', 'Theme.of(context).colorScheme.onSurface'),
    # isDark ? Colors.white.withValues(alpha:0.9) : AppColors.textPrimary
    (r'isDark(?:Mode)?\s*\?\s*Colors\.white\.withValues\(alpha:\s*0\.9\)\s*:\s*AppColors\.textPrimary', 'Theme.of(context).colorScheme.onSurface'),
    # isDark ? Colors.white38 : AppColors.textMuted
    (r'isDark(?:Mode)?\s*\?\s*Colors\.white38\s*:\s*AppColors\.textMuted', 'Theme.of(context).hintColor'),
    # isDark ? Colors.white70 : AppColors.textMuted
    (r'isDark(?:Mode)?\s*\?\s*Colors\.white70\s*:\s*AppColors\.textMuted', 'Theme.of(context).hintColor'),
    # dialogIsDark ? Colors.white : AppColors.textPrimary
    (r'dialogIsDark\s*\?\s*Colors\.white\s*:\s*AppColors\.textPrimary', 'Theme.of(dialogContext).colorScheme.onSurface'),
    # dialogIsDark ? Colors.white70 : AppColors.textSecondary
    (r'dialogIsDark\s*\?\s*Colors\.white70\s*:\s*AppColors\.textSecondary', 'Theme.of(dialogContext).colorScheme.onSurfaceVariant'),
    # dialogIsDark ? Colors.white38 : AppColors.textMuted
    (r'dialogIsDark\s*\?\s*Colors\.white38\s*:\s*AppColors\.textMuted', 'Theme.of(dialogContext).hintColor'),
    # dialogIsDark ? Colors.white.withValues(alpha: 0.05) : AppColors.surfaceVariant
    (r'dialogIsDark\s*\?\s*Colors\.white\.withValues\(alpha:\s*0\.05\)\s*:\s*AppColors\.surfaceVariant', 'Theme.of(dialogContext).colorScheme.surfaceContainerHighest'),
    # dialogIsDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border
    (r'dialogIsDark\s*\?\s*Colors\.white\.withValues\(alpha:\s*0\.1\)\s*:\s*AppColors\.border\b(?!\.)', 'Theme.of(dialogContext).dividerColor'),
    # isDark ? const Color(0xFF1E293B) : Colors.white (container background)
    (r'isDark(?:Mode)?\s*\?\s*const\s+Color\(0xFF1E293B\)\s*:\s*Colors\.white', 'Theme.of(context).colorScheme.surface'),
    # isDark ? Colors.white : Colors.black87
    (r'isDark\s*\?\s*Colors\.white\s*:\s*Colors\.black87', 'Theme.of(context).colorScheme.onSurface'),
    # isDark ? Colors.white70 : Colors.black54
    (r'isDark\s*\?\s*Colors\.white70\s*:\s*Colors\.black54', 'Theme.of(context).colorScheme.onSurfaceVariant'),
    # isDark ? Colors.white12 : Colors.grey.shade200
    (r'isDark\s*\?\s*Colors\.white12\s*:\s*Colors\.grey\.shade200', 'Theme.of(context).dividerColor'),
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

            original = content
            file_count = 0

            for pattern, replacement in PATTERNS:
                new_content, n = re.subn(pattern, replacement, content)
                if n > 0:
                    file_count += n
                    content = new_content

            if file_count > 0:
                with open(fpath, 'w', encoding='utf-8') as f:
                    f.write(content)
                total_files += 1
                total_replacements += file_count
                rel = os.path.relpath(fpath, BASE)
                print(f"  {rel}: {file_count} replacements")

print(f"\nPass 4 DONE: {total_files} files, {total_replacements} replacements")
