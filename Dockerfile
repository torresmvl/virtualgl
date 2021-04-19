FROM ubuntu:focal as base

ENV DEBIAN_FRONTEND noninteractive

RUN apt update -y && \
    apt install --no-install-recommends -y -qq \
    dumb-init \
    supervisor \
    libglvnd0 \
    libgl1 \
    libglx0 \
    libegl1 \
    libglu1-mesa \
    libxext6 \
    libxtst6 \
    libx11-6 \
    libxv1 \
    xserver-xorg-core \
    x11-xserver-utils \
    mesa-utils \
    xauth \
    xterm \
    curl \
    ca-certificates \
    openssh-server && \
    apt autoclean && apt autoremove && \
    rm -rf /var/lib/apt/lists/*

FROM base as vgl

WORKDIR /tmp
RUN curl -fsSL -O 'https://sourceforge.net/projects/virtualgl/files/2.6.5/virtualgl_2.6.5_amd64.deb' \
    && curl -fsSL -O 'https://sourceforge.net/projects/turbovnc/files/2.2.6/turbovnc_2.2.6_amd64.deb' \
    && dpkg -i *.deb \
    && printf "1\nn\nn\nn\nx\n" | /opt/VirtualGL/bin/vglserver_config \
    && sed -i 's/$host:/unix:/g' /opt/TurboVNC/bin/vncserver \
    && rm -f /tmp/*.deb

FROM vgl as pre-release
RUN sed -i "s/^.*X11Forwarding.*$/X11Forwarding yes/; s/^.*X11UseLocalhost.*$/X11UseLocalhost no/; s/^.*PermitRootLogin prohibit-password/PermitRootLogin yes/; s/^.*X11UseLocalhost.*/X11UseLocalhost no/;" /etc/ssh/sshd_config
RUN mkdir -p /run/sshd && \
    echo root:virtualgl | chpasswd
COPY supervisord.conf /etc/

FROM scratch as release
ENV NVIDIA_DRIVER_CAPABILITIES graphics,utility,compute
ENV NVIDIA_VISIBLE_DEVICES all
ENV DISPLAY=:0
ENV PATH ${PATH}:/opt/VirtualGL/bin:/opt/TurboVNC/bin
COPY --from=pre-release / /
ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["/usr/bin/supervisord", "-n"]