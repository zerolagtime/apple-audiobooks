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
### Linux
Add this command to a single shell or to your .bashrc - all containers are from dockerhub:
`alias prepaudiobook='docker run -it --rm --tmpfs=/tmp -v "$PWD:/home/abook" audiobook_tools:develop prepaudiobook'`
and 
`alias mp3tom4b="docker run -it --rm --tmpfs=/tmp -v '$PWD:/home/abook' zerolagtime/audiobook_tools:latetst prepaudiobook"`
If the lines have been added to $HOME/.bashrc, then read them in with `source $HOME/.bashrc`.  The software is "installed."

## Preparing an Audiobook