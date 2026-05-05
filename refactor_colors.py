import os
import re

lib_dir = '/Users/piaggiodev/Desktop/MahttaDriver/piaggiodriver/lib'

color_map = {
    r'\bprimarycolor\b': 'AppThemes.primaryNavy',
    r'\bsecondarycolor\b': 'AppThemes.primaryOrange',
    r'\bdarkblue\b': 'AppThemes.primaryNavy',
    r'\btheredcolor\b': 'AppThemes.light.colorScheme.error',
}

for root, dirs, files in os.walk(lib_dir):
    for file in files:
        if file.endswith('.dart') and file != 'colors.dart':
            filepath = os.path.join(root, file)
            with open(filepath, 'r') as f:
                content = f.read()

            new_content = content
            for old, new in color_map.items():
                new_content = re.sub(old, new, new_content)

            if "package:piaggio_driver/constants/colors.dart" in new_content:
                new_content = re.sub(r"import\s+'package:piaggio_driver/constants/colors\.dart';\n?", "", new_content)
                if "package:piaggio_driver/constants/app_theme.dart" not in new_content:
                    # insert app_theme import at the top of the file
                    new_content = "import 'package:piaggio_driver/constants/app_theme.dart';\n" + new_content

            if new_content != content:
                with open(filepath, 'w') as f:
                    f.write(new_content)
                print(f"Updated {filepath}")

os.remove(os.path.join(lib_dir, 'constants', 'colors.dart'))
print("Deleted colors.dart")
