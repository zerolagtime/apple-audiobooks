import sys
import re

def process_file_contents(contents):
    title = ""
    output_lines = []
    
    for line in contents.split('\n'):
        if "TITLE" in line:
            # Extract title after "TITLE " and remove last character (likely a quotation mark)
            title = re.sub(r'.*TITLE "', '', line)
            title = re.sub(r'"$', '', title)
        elif "INDEX" in line:
            # Process index lines
            parts = line.split()
            if len(parts) > 3 and parts[0] == "INDEX":
                time_str = parts[3]
                ts = time_str.split(':')
                if len(ts) == 3:
                    h = int(ts[0]) // 60
                    m = int(ts[0]) % 60
                    s = int(ts[1])
                    ms = int(ts[2])
                    # Format and store the output line
                    output_lines.append(f"{h:02d}:{m:02d}:{s:02d}.{ms:03d} {title}")

    return output_lines

def main():
    # Read file contents from files listed in command-line arguments
    if len(sys.argv) > 1:
        for filename in sys.argv[1:]:
            with open(filename, 'r') as file:
                contents = file.read()
                results = process_file_contents(contents)
                for result in results:
                    print(result)
    else:
        # Read from standard input if no files are provided
        contents = sys.stdin.read()
        results = process_file_contents(contents)
        for result in results:
            print(result)

if __name__ == "__main__":
    main()
