FROM debian:13

ENV DEBIAN_FRONTEND=noninteractive
ENV PROTON_VERSION=8.0-5
ENV PROTON_DIR=/opt/proton
ENV WINEPREFIX=/winedata
ENV DISPLAY=:0

# Enable i386 architecture & install dependencies
RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        xvfb \
        x11vnc \
        xdotool \
        dbus \
        wine64 \
        wine32 \
        winbind \
        cabextract \
        unzip \
        git \
        bash \
        xauth \
        libx11-6 \
        libxext6 \
        libxrender1 \
        libxrandr2 \
        libxi6 \
        libfreetype6 \
        libfontconfig1 && \
    rm -rf /var/lib/apt/lists/*

# Install Proton
RUN mkdir -p $PROTON_DIR $WINEPREFIX && \
    curl -L "https://github.com/ValveSoftware/Proton/releases/download/proton-$PROTON_VERSION/Proton-$PROTON_VERSION.tar.gz" \
    -o /tmp/proton.tar.gz && \
    tar -xf /tmp/proton.tar.gz -C $PROTON_DIR --strip-components=1 && \
    rm /tmp/proton.tar.gz

# Add FMD2 files (replace with your path)
COPY FMD2/ /app/FMD2/
# Or:
# RUN git clone https://github.com/dazedcat19/FMD2 /app/FMD2

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

WORKDIR /app/FMD2

ENTRYPOINT ["/entrypoint.sh"]
