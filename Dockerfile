FROM ghcr.io/astral-sh/uv:python3.14-trixie-slim

ENV APT_INSTALL_PRE="apt -o Acquire::ForceIPv4=true update && DEBIAN_FRONTEND=noninteractive apt -o Acquire::ForceIPv4=true install -y --no-install-recommends"
ENV APT_INSTALL_POST="&& apt clean -y && rm -rf /var/lib/apt/lists/*"
ENV UID_OF_DOCKERUSER=1000
ENV VNC_PASSWD=123456

RUN ln -snf /usr/share/zoneinfo/PRC /etc/localtime && echo PRC > /etc/timezone

RUN eval ${APT_INSTALL_PRE} curl sudo tigervnc-standalone-server tigervnc-common tigervnc-tools fluxbox xterm git net-tools ${APT_INSTALL_POST}

RUN curl -L https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -o /tmp/chrome.deb && \
    eval ${APT_INSTALL_PRE} /tmp/chrome.deb ${APT_INSTALL_POST} && \
    rm /tmp/chrome.deb

RUN sed -i 's/%sudo\s\+ALL=(ALL:ALL)\s\+ALL/%sudo ALL=(ALL:ALL) NOPASSWD :ALL/' /etc/sudoers

RUN useradd -m -s /bin/bash -U -G sudo -u ${UID_OF_DOCKERUSER} cph

RUN mkdir -p /home/cph/.cache /opt/startup_scripts

RUN chown -R cph:cph /home/cph && chown cph:cph /opt

WORKDIR .
RUN echo `pwd` && ls
RUN cp x11vnc_entrypoint.sh /opt/x11vnc_entrypoint.sh \
    && cp container_startup.sh /opt/container_startup.sh \
    && chmod +x /opt/x11vnc_entrypoint.sh /opt/container_startup.sh

RUN mkdir -p /usr/share/menu \
    && echo "?package(bash):needs=\"X11\" section=\"DockerCustom\" title=\"Google Chrome\" command=\"google-chrome --no-sandbox\"" >> /usr/share/menu/custom-docker \
    && echo "?package(bash):needs=\"X11\" section=\"DockerCustom\" title=\"Xterm\" command=\"xterm -ls -bg black -fg white\"" >> /usr/share/menu/custom-docker && \
    update-menus

WORKDIR /home/cph

USER cph

EXPOSE 5900/tcp
EXPOSE 5901/tcp

ENTRYPOINT ["bash"]
CMD ["/opt/container_startup.sh"]
