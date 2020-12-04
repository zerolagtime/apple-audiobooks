#!/bin/sh

bindir=${BINDIR:-$HOME/bin}
if [ $# -ge 1 ]; then
   cmd=$(printf "$1" | sed -e 's/^.*\///; s/[^- ,._:A-Za-z0-9+=]//g')
   shift 1
else
   cmd="help"
fi

usage() {
   echo "Audiobook generation tools"
   echo "=========================="
   echo "Commands: "
   /bin/ls $BINDIR | grep -v "$(basename $0)" | sed -e 's/^/  /'
}
case $cmd in 
   help)
      usage; exit 2;;
   --h)
      usage; exit 2;;
   -h)
      usage; exit 2;;
   $(basename $0))
      usage; exit 2;;
esac
#if [ "$cmd" == "help" -o \
#     "$cmd" == "--h" -o \
#     "$cmd" == "-h" -o \
#     "$cmd" == "$(basename $0)" ]; then
#   usage
#   exit 2
#fi

if [ -f "$bindir/$cmd" ]; then
   "$bindir/$cmd" "$@"
   exit $?
else 
   echo "ERROR: Unrecognized command \"$cmd\""
   usage
   exit 2
fi
