FROM ubuntu:jammy-20221020 AS build
# tzdata will prompt for a timezone if one is not set.  Set one as recommended at
#   https://dev.to/setevoy/docker-configure-tzdata-and-timezone-during-build-20bk
ENV TZ=America/New_York
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone && \
    apt-get update -qqqqqq && \
    apt-get -y install -qqqqqq \
        git cmake make build-essential wget \
        build-essential pkg-config g++ git cmake yasm gcc python3 python3-pip python3-pip-whl \
        python3-setuptools-whl python3-wheel python3-venv \
        zlib1g-dev libfreetype6-dev libjpeg62-dev libpng-dev libmad0-dev \
        libfaad-dev libogg-dev libvorbis-dev libtheora-dev \
        libavcodec58 \
        libavdevice58 \
        libavfilter7 \
        libfaad2  && \
    mkdir /src && chown 1000 /src
RUN wget https://github.com/goreleaser/nfpm/releases/download/v2.32.0/nfpm_2.32.0_amd64.deb && \
    apt-get install ./nfpm_2.32.0_amd64.deb && \
    rm ./nfpm_2.32.0_amd64.deb
RUN useradd -m -d /home/abook --uid=1000 abook
USER 1000
RUN git clone -b 20210124.204813.840499f https://github.com/wez/atomicparsley.git /src/ap  
WORKDIR /src/ap
# RUN git checkout --detach 20210124.204813.840499f 
RUN cmake . && \
    cmake --build . --config Release 

RUN git clone -b v2.1.3 https://github.com/enzo1982/mp4v2.git /src/mp4v2
WORKDIR /src/mp4v2
RUN mkdir inst && \
    cmake . && \
    make && \
    rm mp4*.* 

RUN git clone -b v2.2.1 https://github.com/gpac/gpac.git /src/gpac
WORKDIR /src/gpac
RUN mkdir inst && \
    ./configure --static-bin --prefix=/src/gpac/inst && \
    make && \
    make install && \
    find /src/gpac/inst

ARG PYMADVERSION=0.11.3
RUN pip3 install --upgrade setuptools build pip && \
    python3 -m pip download --source :all: --dest . --no-cache pymad==$PYMADVERSION && \
    mkdir /src/pymad && \
    tar xf pymad-$PYMADVERSION.tar.gz -C /src/pymad --strip-components=1 && \
    cd /src/pymad && \
    python3 -m build . && \
    rm dist/*.tar.gz

# syntax=docker/dockerfile:1.0
FROM ubuntu:jammy-20221020
COPY --from=build /src/pymad/dist/*.whl /tmp/wheel/
COPY --from=build /src/ap/AtomicParsley /usr/bin/AtomicParsley
COPY --from=build /src/mp4v2/mp4* /usr/bin/
COPY --from=build /src/mp4v2/*.so* /usr/lib/
COPY --from=build /src/mp4v2/*.a /usr/lib/
COPY --from=build /src/mp4v2/include/* /usr/include/
COPY --from=build /src/gpac/inst/bin/MP4Box /usr/bin/

        # gpac \
        # atomicparsley \
RUN \
    apt-get update -qqqqqq && \
    apt-get install -y -qqqqqq --no-install-recommends --no-upgrade --quiet \
        a52dec \
        apt-utils \
        bash \
        faac \
        grep \
        id3v2 \
        lame \
        libasound2 \
        libavcodec58 \
        libavdevice58        \
        libavfilter7 \
        libfaad2        \
        libgl1        \
        libglu1-mesa        \
        libjack-jackd2-0 \
        libjpeg62        \
        libmad0-dev \
        libsdl2-2.0-0 \
        libxv1 \
        mp3info \
        mpg123 \
        perl-modules \
        python3 \
        python3-pip \
        python3-venv        \
        unzip \
        vorbis-tools \
        wget \
        xz-utils 
ENV BINDIR /opt/audiobook_tools
ENV EXTRAS /opt/extra_tools
RUN mkdir -p $EXTRAS
RUN wget -O /tmp/ffmpeg.tar.xz --quiet \
       https://johnvansickle.com/ffmpeg/releases/ffmpeg-release-amd64-static.tar.xz  && \
    cd /tmp && tar xJf ffmpeg.tar.xz && cd ffmpeg*static && \
    install ffmpeg ffprobe $EXTRAS && \
    rm /tmp/ffmpeg.tar.xz

RUN command -v pip3 \
    && python3 -m pip install --upgrade setuptools pip wheel 
# binaries go into a place that permissions are locked down in
COPY ./bin/* $BINDIR/
COPY ./odc /opt/overdrive_chapters
COPY ./extras/ $EXTRAS
COPY ./requirements.txt /tmp/requirements.txt
RUN ln -s $(command -v mp4chaps) $BINDIR/mp4chaps
RUN python3 -m pip  install  \
       requests  
RUN pip3 install /tmp/wheel/*.whl
RUN pip3 install -r /tmp/requirements.txt
RUN useradd --uid 1000 --create-home abook
USER abook
COPY requirements.txt /tmp/requirements.txt
ENV PATH=${PATH}:${BINDIR}:${EXTRAS}
WORKDIR /home/abook
ENTRYPOINT ["/opt/audiobook_tools/choose_exec.sh"]
CMD ["help"]


