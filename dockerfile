FROM python:2.7-slim

WORKDIR /app

# Update sources.list to use Debian archive mirrors for Buster
RUN sed -i 's|http://deb.debian.org/debian|http://archive.debian.org/debian|g' /etc/apt/sources.list \
    && sed -i 's|http://security.debian.org/debian-security|http://archive.debian.org/debian-security|g' /etc/apt/sources.list \
    && apt-get update \
    && apt-get install -y git wget ca-certificates \
    && apt-get install -y curl \
    && apt-get install -y owncloud-client \
    && rm -rf /var/lib/apt/lists/* \
    # Download Nextcloud AppImage and extract nextcloudcmd if not present
    && if ! command -v owncloudcmd >/dev/null 2>&1; then \
        wget -O /tmp/Nextcloud.AppImage "https://github.com/nextcloud/desktop/releases/download/v3.7.3/Nextcloud-3.7.3-x86_64.AppImage" && \
        chmod +x /tmp/Nextcloud.AppImage && \
        /tmp/Nextcloud.AppImage --appimage-extract && \
        cp squashfs-root/usr/bin/nextcloudcmd /usr/local/bin/nextcloudcmd && \
        ln -s /usr/local/bin/nextcloudcmd /usr/local/bin/owncloudcmd && \
        cp -r squashfs-root/usr/lib/* /usr/local/lib/ && \
        rm -rf /tmp/Nextcloud.AppImage squashfs-root; \
    fi

# Set LD_LIBRARY_PATH so owncloudcmd can find libnextcloudsync.so.0
ENV LD_LIBRARY_PATH="/usr/local/lib:$LD_LIBRARY_PATH"



COPY requirements.txt /app/
RUN pip install pyocclient

# Ensure pyocclient (owncloud) is importable
ENV PYTHONPATH="/app/src/pyocclient:$PYTHONPATH"


COPY . /app


CMD ["bash"]