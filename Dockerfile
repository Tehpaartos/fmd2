FROM debian:13

ENV DEBIAN_FRONTEND=noninteractive
ENV PROTON_VERSION=8.0-5
ENV PROTON_DIR=/opt/proton
ENV WINEPREFIX=/winedata
ENV DISPLAY=:0

# Enable i386 and install dependencies
RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        git \
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
        xauth \
        libx11-6 \
        libxext6 \
        libxrender1 \
        libxrandr2 \
        libxi6 \
        libfreetype6 \
        libfontconfig1 \
        mingw-w64 \
        ca-certificates \
        bash && \
    rm -rf /var/lib/apt/lists/*

# Install .NET Framework MSBuild inside Wine via winetricks
RUN apt-get update && apt-get install -y winetricks && \
    winetricks -q dotnet472

# Install Proton
RUN mkdir -p $PROTON_DIR $WINEPREFIX && \
    curl -L "https://github.com/ValveSoftware/Proton/releases/download/proton-$PROTON_VERSION/Proton-$PROTON_VERSION.tar.gz" \
    -o /tmp/proton.tar.gz && \
    tar -xf /tmp/proton.tar.gz -C $PROTON_DIR --strip-components=1 && \
    rm /tmp/proton.tar.gz

# Clone FMD2 from GitHub
RUN git clone https://github.com/dazedcat19/FMD2 /src/FMD2

# Build FMD2 using Wine MSBuild
RUN wine "C:\\windows\\Microsoft.NET\\Framework\\v4.0.30319\\MSBuild.exe" \
    Z:\\src\\FMD2\\FMD2.csproj /p:Configuration=Release

# Copy built EXE to /app
RUN mkdir -p /app/FMD2 && \
    cp -r /src/FMD2/bin/Release/* /app/FMD2/

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

WORKDIR /app/FMD2
ENTRYPOINT ["/entrypoint.sh"]
