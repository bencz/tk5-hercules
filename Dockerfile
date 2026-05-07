FROM ubuntu:24.04 AS builder

WORKDIR /tk5/

RUN apt-get update && apt-get install -y --no-install-recommends \
    unzip \
    ca-certificates \
    wget \
    && rm -rf /var/lib/apt/lists/*

RUN wget -O mvs-tk5.zip https://www.prince-webdesign.nl/images/downloads/mvs-tk5.zip

RUN unzip mvs-tk5.zip && rm mvs-tk5.zip

RUN cd mvs-tk5 && \
    mv * .. && \
    cd .. && \
    rm -rf mvs-tk5 && \
    chmod -R +x *

RUN echo "CONSOLE" > /tk5/unattended/mode

RUN rm -rf /tk5/hercules/darwin /tk5/hercules/windows


FROM ubuntu:24.04

WORKDIR /tk5/

COPY --from=builder /tk5/ .

RUN apt-get update && apt-get install -y --no-install-recommends \
    bash \
    python3 \
    python3-pip \
    libbz2-1.0 \
    libstdc++6 \
    ca-certificates \
    && pip3 install --break-system-packages websockify \
    && chmod +x /tk5/mvs \
    && rm -rf /var/lib/apt/lists/*

EXPOSE 6080
EXPOSE 3270

CMD ["bash", "-lc", "cd /tk5 && set -x && websockify 0.0.0.0:${WS_PORT:-6080} 127.0.0.1:3270 & exec ./mvs"]
