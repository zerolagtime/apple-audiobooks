import os
import subprocess
import argparse
import sys
import re
import tempfile

def check_dependencies(dependencies):
    missing_programs = []
    for prog in dependencies:
        if not shutil.which(prog):
            missing_programs.append(prog)
    if missing_programs:
        print("ERROR: Missing required programs:", ", ".join(missing_programs))
        sys.exit(1)

def parse_info_file(filename="info.txt"):
    data = {}
    if os.path.exists(filename):
        with open(filename, 'r') as file:
            for line in file:
                key, value = line.strip().split('=', 1)
                data[key] = value
    return data

def ffmpeg_available():
    for cmd in ['ffpb', 'ffmpeg']:
        if shutil.which(cmd):
            return cmd
    return None

def main():
    parser = argparse.ArgumentParser(description="Convert MP3 files to M4B.")
    parser.add_argument('-v', '--verbose', action='store_true', help='Enable verbose mode')
    parser.add_argument('-t', '--title', help='Title of the book')
    parser.add_argument('-a', '--artist', help='Artist name')
    parser.add_argument('-y', '--year', help='Year of production')
    parser.add_argument('-l', '--album', help='Album title')
    parser.add_argument('-b', '--bitrate', type=int, default=112, help='Bitrate for the output file')
    parser.add_argument('-c', '--comment', help='Comment for the file')
    parser.add_argument('-o', '--output', help='Output file name')
    parser.add_argument('-p', '--picture', help='Picture file for cover art')
    parser.add_argument('files', nargs='+', help='Input MP3 files')
    args = parser.parse_args()

    check_dependencies(['ffmpeg', 'id3v2', 'mp4chaps', 'MP4Box', 'lame', 'mpg123'])

    info = parse_info_file()
    for key, value in info.items():
        if getattr(args, key.lower()) is None:
            setattr(args, key.lower(), value)

    ffmpeg_cmd = ffmpeg_available()
    if not ffmpeg_cmd:
        print("ERROR: ffmpeg or ffpb is not installed.")
        sys.exit(1)

    if args.verbose:
        print("Using ffmpeg command:", ffmpeg_cmd)
        print("Converting files:", ", ".join(args.files))

    output_file = args.output or "output.m4b"
    command = [
        ffmpeg_cmd, '-i', 'concat:' + '|'.join(args.files),
        '-c:a', 'aac', '-b:a', f'{args.bitrate}k', output_file
    ]

    if args.picture:
        command.extend(['-i', args.picture, '-map', '0', '-map', '1', '-metadata:s:v', 'title="Album cover"',
                        '-metadata:s:v', f'comment="{args.comment}"'])

    if args.verbose:
        print("Running command:", ' '.join(command))

    subprocess.run(command, check=True)

    print(f"Conversion complete. Output file: {output_file}")

if __name__ == "__main__":
    main()
