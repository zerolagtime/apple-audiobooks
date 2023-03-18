
FROM ubuntu:jammy-20221020 AS build
# tzdata will prompt for a timezone if one is not set.  Set one as recommended at
#   https://dev.to/setevoy/docker-configure-tzdata-and-timezone-during-build-20bk
ENV TZ=America/New_York
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone && \
    apt-get update && \
    apt-get -y install git cmake make build-essential && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir /src && chown 1000 /src
USER 1000
RUN git clone https://github.com/wez/atomicparsley.git /src/ap  
WORKDIR /src/ap
RUN git checkout --detach 20210124.204813.840499f 
RUN cmake . && \
    cmake --build . --config Release 

# syntax=docker/dockerfile:1.0
FROM ubuntu:bionic-20221019
#COPY --from=build /src/ap/AtomicParsley /usr/bin/AtomicParsley
RUN useradd -m -d /home/abook abook

        # gpac \
RUN \
    apt-get update && \
    apt-get install -y \
        atomicparsley \
        apt-utils \
        xz-utils \
        unzip \
        wget \
        bash \
        python-minimal \
        id3v2 \
        mp3info \
        vorbis-tools \
        mp4v2-utils \
        lame \
        mp4v2-utils \
        mpg123 \
        faac \
        python-pymad \
        perl-modules \
        python-pymad \
        grep \
        python3 \
        python3-pip \
    && rm -rf /var/lib/apt/lists/*
# see https://gpac.wp.imt.fr/downloads/ for GPAC updates
# note that this is very sloppy and pulls in over 170 packages so that
# we can get one tool
#RUN wget "http://download.tsi.telecom-paristech.fr/gpac/release/1.0.1/gpac_1.0.1-rev0-gd8538e8a-master_amd64.deb" && apt install -y ./gpac_1.0.1-rev0-gd8538e8a-master_amd64.deb && rm gpac_1.0.1-rev0-gd8538e8a-master_amd64.deb
RUN wget -q https://download.tsi.telecom-paristech.fr/gpac/release/2.0/gpac_2.0-rev0-g418db414-master_amd64.deb && apt install -y ./gpac_2.0-rev0-g418db414-master_amd64.deb && rm ./gpac_2.0-rev0-g418db414-master_amd64.deb
ENV BINDIR=/opt/audiobook_tools
ENV EXTRAS=/opt/extra_tools
RUN mkdir -p $EXTRAS
RUN wget -O /tmp/ffmpeg.tar.xz --quiet \
       https://johnvansickle.com/ffmpeg/releases/ffmpeg-release-amd64-static.tar.xz  && \
    cd /tmp && tar xJf ffmpeg.tar.xz && cd ffmpeg*static && \
    install ffmpeg ffprobe $EXTRAS && \
    rm /tmp/ffmpeg.tar.xz

RUN command -v pip3 && pip3 install --user ffpb
# binaries go into a place that permissions are locked down in
COPY odc /opt/overdrive_chapters
COPY extras/ $EXTRAS
COPY bin $BINDIR
RUN ln -s $(command -v mp4chaps) $BINDIR/mp4chaps
USER abook
ENV PATH=${PATH}:${BINDIR}:${EXTRAS}
WORKDIR /home/abook
ENTRYPOINT ["/opt/audiobook_tools/choose_exec.sh"]
CMD ["help"]


