#!/usr/bin/env python
import os, sys, math, re
import optparse
from optparse import *
import id3reader
import mad
import ElementTree

f="Stoneheart-Part01.mp3"

retval = 0

def sec2hms(s):
   h = int( s/3600 )
   s = s - (h*3600)
   m = int( s/60 )
   s = s - (m*60);
   return [h, m, s]

def main():
   epoch_seconds = 0
   for f in sys.argv[1:]:
      this_xml = "Unknown";
      this_length = 0
      if not os.path.isfile(f):
         print("File error: %s" % f)

      # print ("# Reading file %s" % f  )
      try: 
         mp3 = id3reader.Reader( f ); 
         # print("# Title = %s" % mp3.getValue('title') )
         this_xml = mp3.getValue('TXXX');
         if (this_xml): 
            # print("# Overdrive XML = %s" % this_xml[1] ) 
            pass
         else:
            print("# ERROR - no overdrive XML in %s" % f)
            continue
      except:
         print( "# Error reading tags from %s:" % f, sys.exc_info()[0] )
      try:
         m = mad.MadFile( f );
         this_length = (m.total_time() / 1000.0)
         # print("# Length = %.2f seconds" % this_length );
      except:
         print( "# Error reading mpeg frames from %s:" % f, sys.exc_info()[0] )
         continue
      
      try:
         et = ElementTree.fromstring( this_xml[1].encode('utf-8') )
         for marker in et.findall("Marker"):
            title =  marker.find("Name").text.strip()
            minsec = marker.find("Time").text.encode('utf-8')
            hms = minsec.split(":")
            # print("  length=%d; minsec=%s hms=" % (len(hms),minsec), hms)
            if (len(hms) == 3):
               sec = float(hms.pop()) + float(hms.pop())*60.0 + float(hms.pop())*3600.0
            elif (len(hms) == 2):
               sec = float(hms.pop()) + float(hms.pop())*60.0
            else:
               sec = float(hms.pop())
            if (re.search( "\(\d\d(:\d\d)+\)", title) == None):               
               n = sec2hms(epoch_seconds+sec)
               print( "%02d:%02d:%02d.000 %s" % (n[0], n[1], n[2] , title) )
            #print( "== title=%s  length=%s running_seconds=%d" % (title, sec, epoch_seconds+sec) )
      except:
         print( "# Error parsing XML from %s:" % f, sys.exc_info() )
      epoch_seconds += this_length
if __name__ == "__main__":
   retval = 0
   retval=main()
   sys.exit(retval)
   
