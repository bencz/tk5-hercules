FROM alpine AS builder

WORKDIR /tk5/
ADD https://www.prince-webdesign.nl/images/downloads/mvs-tk5.zip /tk5/

RUN apk add --no-cache unzip

RUN unzip mvs-tk5.zip && rm -rf mvs-tk5.zip

RUN cd mvs-tk5 && \
    mv * .. && \
    cd .. && \
    rm -rf mvs-tk5 && \
    chmod -R +x *

RUN echo "CONSOLE" > /tk5/unattended/mode

RUN rm -rf /tk5/hercules/darwin /tk5/hercules/windows


FROM alpine

WORKDIR /tk5/

COPY --from=builder /tk5/ .

RUN apk add --no-cache \
    gcompat \
    libstdc++ \
    bash \
    libbz2 \
    python3 \
    py3-pip && \
    pip3 install --break-system-packages websockify && \
    cd /usr/lib && ln -sf libbz2.so.1 libbz2.so.1.0

EXPOSE 6080
EXPOSE 3270

CMD ["bash", "-c", "websockify 0.0.0.0:${PORT:-6080} 127.0.0.1:3270 & exec /tk5/mvs"]
