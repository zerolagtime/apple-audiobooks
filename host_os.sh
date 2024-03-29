# add these lines to your $HOME/.bashrc or source them from here

waitQuiet () 
{ 
    lowLoad=1;
    while [ $lowLoad -eq 1 ]; do
        load=$( echo  $(cat /proc/loadavg | cut -f1 -d' ') \* 100  | bc -ql | sed -e 's/\..*//');
        test $load -lt 300 && break;
        lowLoad=$?;
        echo "[$(date)] Too busy.  Waiting.";
        sleep 5;
    done;
    echo "[$(date)] All is quiet.  Proceeding."
}

encode () 
{ 
    name=$1;
    if [ -z "$name" ]; then
       name=$(basename "$(pwd)" | sed -e 's/[^-_A-Za-z0-9]//g'| tr '[:upper:]' '[:lower:]')
    fi;
    echo "Encoding starting when idle.  See encode.log for status";
    waitQuiet >> encode.log;
    sleep $[ $RANDOM % 30];
    waitQuiet >> encode.log;
    echo "Encoding beginning for $(basename "$(pwd)") (container $name)";

    (docker run --name "$name" --rm --tmpfs=/tmp -v "$PWD:/home/abook" --user $UID audiobook_tools:develop mp3tom4b 2>&1 ) 2>&1 >> encode.log
}

multipartEncode () 
{ 
    PARTS=$1;
    if [ -z "$PARTS" ]; then
        echo "Usage: multipartEncode [num_parts]";
        echo "Don't forget to put \${PARTS} into info.txt";
        echo "and check that files end in .mp3";
        return 1;
    fi;
    if [ "$PARTS" -le 1 ]; then
        echo "Usage: multipartEncode [num_parts]";
        return 1;
    fi;
    if [ ! -f info.txt ]; then
        echo "info.txt missing";
        return 1;
    fi;
    egrep --color=auto -E --silent '(${PART}|PART)' info.txt;
    if [ $? -ne 0 ]; then
        echo "info.txt has no \$PART text";
        return 1;
    fi;
    numMp3=$(ls -1 *.mp3 | wc -l);
    if [ "$numMp3" -eq 0 -o "$numMp3" -lt $PARTS ]; then
        echo "No MP3 files or too few MP3 files";
        return 1;
    fi;
    offset=75;
    numPerPart=$(echo "(($numMp3 * 100 /$PARTS) + $offset)/100 " | bc -q);
    partList=$(c=1; while [ $c -le $PARTS ]; do echo $c; c=$[ $c + 1 ]; done );
    alias prepaudiobook_notty='docker run --name "prepaudiobook-$RANDOM" -i --rm --tmpfs=/tmp --user $UID -v "$PWD:/home/abook" audiobook_tools:develop prepaudiobook'
    for PART in $partList;
    do
        export PART;
        ( echo "=========== Part $PART ============";
        alias prepaudiobook_notty='docker run --name "prepaudiobook-$RANDOM" -i --rm --tmpfs=/tmp --user $UID -v "$PWD:/home/abook" audiobook_tools:develop prepaudiobook'
        mkdir part$PART;
        echo "Moving $numPerPart or less files";
        ls --color=auto -1 *.mp3 | head -$numPerPart | xargs -I {} mv {} part$PART/;
        if [ -f "$(echo *.wax)" ]; then
           cp *.wax part$PART/.
        fi
        name=$(basename "$(pwd)" | sed -e 's/[^-_A-Za-z0-9]//g'| tr '[:upper:]' '[:lower:]')-p$PART
        cd part$PART;
        echo "Computing chapter marks";
        prepaudiobook_notty </dev/null >/dev/null
        cat chapters.txt
        cp ../*.jpg ../description.txt .;
        echo "Calculating the info.txt file";
        cat ../info.txt | envsubst > info.txt;
        echo "Scheduling the encoding";
        ( encode $name;
        bash -c "mv *.mp3 *.m4b .." ) & echo "Done with part $PART" );
    done;
    return 0
}
alias mp3tom4b="docker run --name "mp3tom4b-$RANDOM" -it --rm --tmpfs=/tmp --user $UID -v '$PWD:/home/abook' audiobook_tools:develop mp3tom4b"
alias prepaudiobook='docker run --name "prepaudiobook-$RANDOM" -it --rm --tmpfs=/tmp --user $UID -v "$PWD:/home/abook" audiobook_tools:develop prepaudiobook'
alias prepaudiobook_notty='docker run --name "prepaudiobook-$RANDOM" -i --rm --tmpfs=/tmp --user $UID -v "$PWD:/home/abook" audiobook_tools:develop prepaudiobook'
alias mp4chaps='docker run --name "mp4chaps-$RANDOM" -it --rm --tmpfs=/tmp --user $UID -v "$PWD:/home/abook" audiobook_tools:develop mp4chaps'
alias odm2xml='docker run --name "odm2xml-$RANDOM" -it --rm --tmpfs=/tmp --user $UID -v "$PWD:/home/abook" audiobook_tools:develop odm2xml'
