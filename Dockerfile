# syntax=docker/dockerfile:1.0
FROM ubuntu:18.04

RUN useradd -m -d /home/abook abook

RUN apt-get update && \
    apt-get install -y \
        apt-utils \
        xz-utils \
        unzip \
        wget \
        bash \
        python-minimal \
        id3v2 \
        mp3info \
        vorbis-tools \
        gpac \
        mp4v2-utils \
        lame \
        mp4v2-utils \
        mpg123 \
        faac \
        python-pymad \
        perl-modules \
        python-pymad \
        grep 

ENV BINDIR=/opt/audiobook_tools
ENV EXTRAS=/opt/extra_tools
RUN mkdir -p $EXTRAS
RUN wget -O /tmp/ffmpeg.tar.xz --quiet \
       https://johnvansickle.com/ffmpeg/releases/ffmpeg-release-amd64-static.tar.xz  && \
    cd /tmp && tar xJf ffmpeg.tar.xz && cd ffmpeg*static && \
    install ffmpeg ffprobe $EXTRAS && \
    rm /tmp/ffmpeg.tar.xz

# binaries go into a place that permissions are locked down in
COPY bin $BINDIR
RUN ln -s $(command -v mp4chaps) $BINDIR/mp4chaps
COPY odc /opt/overdrive_chapters
COPY extras/ $EXTRAS
USER abook
ENV PATH=${PATH}:${BINDIR}:${EXTRAS}
WORKDIR /home/abook
ENTRYPOINT ["/opt/audiobook_tools/choose_exec.sh"]
CMD ["help"]


