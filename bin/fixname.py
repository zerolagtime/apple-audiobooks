import os
import sys
import re

def clean_filename(filename):
    # Replace '&' with 'and'
    cleaned_name = filename.replace('&', 'and')
    # Replace special characters with '_'
    cleaned_name = re.sub(r'[^-\d\w,\.+=#:]', '_', cleaned_name)
    # Replace multiple occurrences of '_' with a single '_'
    cleaned_name = re.sub(r'__+', '_', cleaned_name)
    return cleaned_name

def main():
    for filepath in sys.argv[1:]:  # Skip the first argument, which is the script name
        directory, filename = os.path.split(filepath)
        good_filename = clean_filename(filename)
        
        if filename != good_filename:
            new_filepath = os.path.join(directory, good_filename)
            os.rename(filepath, new_filepath)
            print(f"Repaired {filepath}")
        else:
            print(f"Skipped {filepath}")

if __name__ == "__main__":
    main()
