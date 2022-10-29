#!/usr/bin/env python3
import os, sys, math, re, glob
import optparse
from optparse import *
#import id3reader
#import mad
#import ElementTree
from collections import OrderedDict

def cdp_import(cdp_text, disc):
    """
    Import output from "cdparanoid -Q"
    into an internal dict/array structure
    that can be converted to XML
    """
    markers = OrderedDict()
    for line in cdp_text.split("\n"):
        matches = re.match(r'^\s*(\d+)\.\s+\d+\s+\[\d\d:\d\d.\d\d\]\s+\d+\s+\[(\d\d:\d\d.\d\d)\]', line)
        if matches: 
            if disc:
                chapter = f"Disc {disc}, Chapter {matches.group(1)}"
            else:
                chapter = f"Chapter {matches.group(1)}"
            start_ms=matches.group(2) + "0" # imply 3 digits of floating point precision
            #print(f"Chapter {chapter} starts at {start_ms}")
            markers[chapter] = start_ms
    return markers

def cdp2xml(cdp_file):
    with open(cdp_file, "r") as f:
        lines = f.read()
    disc = None
    match = re.search(r'[Pp]art(\d+)\D', cdp_file)
    if match:
        disc = match.group(1)
    chapters_od = cdp_import(lines, disc=disc)
    return chapters_od

def process_all_cdp_files(cdp_files):
    discs = OrderedDict()
    for one_file in cdp_files:
        markers_od = cdp2xml(cdp_file=one_file)
        if markers_od and len(markers_od) > 0:
            xml_file = one_file.replace(".cdp",".odxml")
            xml_str = "OverDrive MediaMarkers:<Markers>" + \
               str.join("",
                list(map(lambda x,y: f"<Marker><Name>{x}</Name><Time>{y}</Time></Marker>", markers_od.keys(), markers_od.values()))
                ) + \
               "</Markers>"
            print(f"Input file: {one_file}")
            print(f"  Output file: {xml_file}")
            # print(f"  XML: {xml_str}")
            with open(xml_file, "w") as f:
                f.write(xml_str)


def generate_odwax(cdp_files, wax_file="overdrive.wax"):
    mp3_files = [x.replace(".cdp",".mp3") for x in cdp_files]
    xml_str = "<asx>\n" + \
        str.join("\n",
          list(map(lambda x: f"\tentry>\n\t\t<ref href=\"c:\\path\\{x}\"/>\n\t</entry>", mp3_files))
        ) + \
        "\n</asx>"
    print(f"Wax file: {wax_file}")
    # print(f"Wax contents: {xml_str}")
    with open(wax_file, "wb") as f:
        f.write(xml_str.encode("utf-16le"))


if __name__ == "__main__":
    cdp_files = sys.argv[1:]
    if cdp_files is None or len(cdp_files) == 0:
        cdp_files = glob.glob("*.cdp")
    if len(cdp_files) == 0:
        print(f"ERROR: {sys.argv[0]} {{ file.cdp file.cdp ... }}")
        print(f"Purpose: Convert cdparanoia content tables to xml for")
        print(f"import as a TXXX flag to mimic OverDrive files.")
    process_all_cdp_files(cdp_files=cdp_files)
    generate_odwax(cdp_files=sorted(cdp_files))