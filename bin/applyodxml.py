import os
import glob
import subprocess

def main():
    # Check if any .odxml files are present
    odxml_files = glob.glob('*.odxml')
    if not odxml_files:
        # If no .odxml files, execute the ripmp3_to_odc.py script
        subprocess.run(['python3', '/opt/overdrive_chapters/ripmp3_to_odc.py'])

    # Process each .odxml file
    for f in odxml_files:
        mp3 = f.replace('.odxml', '.mp3')
        if os.path.isfile(mp3):
            print(f"ADD chapter info to {mp3}")
            with open(f, 'r') as file:
                chapter_info = file.read()
            # Running id3v2 command to add chapter info to mp3
            subprocess.run(['id3v2', '--TXXX', chapter_info, mp3])
        else:
            print("No .odxml files. This script does not apply.")
            print("Only use this script for CD rips with rip_audiocd2mp3")
            exit(1)

if __name__ == "__main__":
    main()
