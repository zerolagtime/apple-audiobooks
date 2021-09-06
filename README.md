# MP3 to Apple Audiobook Conversion

This tool converts a collection of MP3 files into a single Apple MP4 audiobook with a `.m4b` extension.  Conversion happens in two stages.  In the first stage, `prepaudiobook` is used to search every source available to figure out metadata, even going out to Google Books if nothing can be found.  The metadata is usually pretty messy or inconsistent and will need to be cleaned up.  Books that are part of a series will also need consistent metadata. 
The second stage, `mp3tom4b *.mp3` takes the metadata and MP3 files and then converts it to an Apple Audiobook with these features:
* AAC encoded file with an `.m4b` file extension
* Recognized by Apple iTunes as an Audiobook, ready to import
* Cover art
* Author (Artist)
* Book Title (Album)
* Chapter marks (see below)
* Book description
* Publication year
* No copy protection
* Only one transcoding to reduce noise artifacts

## Installation and Use
This software has a lot of external dependencies which can be cumbersome to get installed onto a system.  Therefore, all of the tools have been embedded in a Docker container.  You must have permission to use Docker on your system, be it Linux or Windows.

### Build
Docker 1.19 or newer must be installed and access to the web must be enabled. 
The contaier is based upon Ubuntu 18.04 and pulls down source code or 
Deb packages for GPAC and FFMPEG.
To build, open a shell window in this folder and type: `./build.sh`.
A container named audiobook_tools:develop will be created, likely around
1.2GB in size.

### Linux
Add shortcuts and aliases to your shell by sourcing the `host_os.sh` file 
from $HOME/.bashrc which adds these commands to your path:
* **`prepaudiobook`** - examine mp3 files or Overdrive WAX and prepare for conversion
* **`mp3tom4b`** - convert a prepared folder to Apple's M4B format
* **`encode`** - a wrapper to mp4tom4b that allows multiple conversion 
  to run at once and not overload your system
* **`mp4chaps`** - reprocess chapter files without reconverting the book
* **`multipartEncode`** - split the book into sections
Test the tools out by typing `source host_os.sh`

## Preparing an Audiobook
With all of the MP3 files in a single folder, type `prepaudiobook`.
Three new files will exist: 
* `info.txt` - a _key_=_value_ file of Audiobook Info
* `description.txt` - a freeform file that has the book's summary
* `chapters.txt` - a file that defines chapters to place in the output
If the MP3 files came from Overdrive, like with a library, then the
.wax file will be used to extract more metadata and the chapter data
embedded as comments in the mp3 files will be used to build the chapter
file.  Not all books have good chapter information. No Overdrive books
have the year that they were published and you will have to dig this up.

The description.txt file should be cleaned up for non-ASCII characters.
The formal description can be at most 255 characters which can
be placed in a `description.short.txt` and still preserve the longer
description.

The info.txt file has all of the core data to be used.  The following
keys must be present:
* `TITLE`
* `ARTIST`
* `ALBUM` (frequently the TITLE, but a book series might use this)
* `YEAR`
* `COMMENT` (typically used for the narrator like "Read by George Guidall")
* `OUT` (the output filename with .m4b on the end) 
* (optional) `COVER` (the last image listed will be used)
Spaces are important in this file.  If no image is used, a default 
icon will be provided.  

This tool is also interactive.  A Google Books search will be conducted
and the top 10 books will be chosen.  Review the guessed values
from the MP3 files and if the Google Books search is better, use
one of those - this will include a description and cover image.  
You can also press Enter to choose none of the search results.

### Conversion
Conversion is as simple as typing `mp3tom4b`.  If you have several in
a row to convert before you head out for a while, you can use the
wrapper `encode &` which will load up the machine until it's almost 100%
busy and hold of on any other conversions.  Certainly, a more automated
orchestration system could be used, but would overcomplicate an already
complicated process.

`mp3tom4b` will just process the MP3 files in the current folder in
alphbetical order or you can specify the exact files you want to be
converted.  Be careful with your file names.  The `ls -l` command should
should show them in the correct order.  You can specify just a glob pattern
as a parameter in case you have extra MP3s, like from an interview.  
The files will be sorted alphabetically before being used.

### Multipart Books
Some books are very, very long. (I'm looking at you Ron Chernow).  iTunes
has historically had difficulty with audiobooks over 12 hours, frequently
incorrect showing the length as hundreds of hours or more. The output
can be split into parts, say three parts, by typing `multipartEncode 3`.
To set this up, your `info.txt` should have text that reads `$PART` or
`${PART}` which will be substituted with the number as appropriate.  Examples:
* `TITLE=Grant, Part ${PART}`
* `ALBUM=Grant`
* `OUT=ron_chernow-grant-part$PART.m4b`
The multipart encoder will then make the number of folders, substitute the
part number, move the MP3 files into their respective subfolder, encode
each part (`encode &`) and when done, move the MP3 files back up.  It
is your job to review the m4b's in the subfolder and determine if
you like the mix.
To choose how many parts, review the `chapters.txt` file and come up with
a divisor that makes sections 12 hours or less.  A 40 hours book might
get divided up into four parts.
If you leave the ALBUM constant as above, then iTunes groups all of the 
parts together which makes it easy to just put one of the sections on
your device at a time.

### Chapters
Chapter files must be of the form "HH:MM:SS.000 Title", where _Title_
can have spaces and other interesting characters.  Chapter files are
built from the metadata hiding in MP3s from Overdrive books. If there
is no other guidance, then chapter markers will be built the length
of each MP3 which is convenient if you get one chapter per MP3 file.

### Metadata
Metadata in MP3s will be used if available.  You should use a tool
dedicated to metadata manipulation.  One tools is EasyTAG, although
there are others that may be better for this purpose.

## Debugging
If you need to view what's going on with an active `encode` session,
the output of the internal mp3tom4b is being written to `encode.log`
which you can tail and stay up to date.

If a conversion seems to have gotten away from you, the easiest solution
is to issue a `docker kill` on the container you think is responsible.
This is a little more tricky if four or six conversions are active.

## LICENSE
This work is Copyright 2021 by Charlie Todd <zerolagtime@gmail.com>.
See the LICENSE for creating your own derivative works.

