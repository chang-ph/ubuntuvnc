FROM ghcr.io/astral-sh/uv:python3.13-trixie-slim

ENV APT_INSTALL_PRE="apt -o Acquire::ForceIPv4=true update && DEBIAN_FRONTEND=noninteractive apt -o Acquire::ForceIPv4=true install -y --no-install-recommends"
ENV APT_INSTALL_POST="&& apt clean -y && rm -rf /var/lib/apt/lists/*"
ENV UID_OF_DOCKERUSER=1000
ENV VNC_PASSWD=123456

RUN ln -snf /usr/share/zoneinfo/PRC /etc/localtime && echo PRC > /etc/timezone

RUN eval ${APT_INSTALL_PRE} \
    curl sudo tigervnc-standalone-server tigervnc-common tigervnc-tools \
    fluxbox xterm git net-tools python3-tk xfce4 xfce4-goodies dbus-x11 \
    libglib2.0-bin libxtst6 \
    ${APT_INSTALL_POST}

RUN curl https://www.charlesproxy.com/packages/apt/charles-repo.asc -o - | sudo tee /etc/apt/keyrings/charles-repo.asc
RUN echo "deb [signed-by=/etc/apt/keyrings/charles-repo.asc] https://www.charlesproxy.com/packages/apt/ charles-proxy main" > /etc/apt/sources.list.d/charles.list

RUN curl -L https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -o /tmp/chrome.deb && \
    eval ${APT_INSTALL_PRE} /tmp/chrome.deb charles-proxy5 ${APT_INSTALL_POST} && \
    rm /tmp/chrome.deb


RUN sed -i 's/%sudo\s\+ALL=(ALL:ALL)\s\+ALL/%sudo ALL=(ALL:ALL) NOPASSWD :ALL/' /etc/sudoers \
    && sed -i 's/-Xmx1024M/-Xmx4096M/g' /usr/bin/charles

RUN useradd -m -s /bin/bash -U -G sudo -u ${UID_OF_DOCKERUSER} cph

RUN mkdir -p /home/cph/.cache /opt/startup_scripts

RUN chown -R cph:cph /home/cph && chown cph:cph /opt

WORKDIR /opt
COPY . /opt
RUN chmod +x /opt/x11vnc_entrypoint.sh /opt/container_startup.sh

# RUN mkdir -p /usr/share/menu \
#     && echo "?package(bash):needs=\"X11\" section=\"DockerCustom\" title=\"Google Chrome\" command=\"google-chrome --no-sandbox\"" >> /usr/share/menu/custom-docker \
#     && echo "?package(bash):needs=\"X11\" section=\"DockerCustom\" title=\"Xterm\" command=\"uxterm -ls -bg black -fg white\"" >> /usr/share/menu/custom-docker && \
#     update-menus

WORKDIR /home/cph

USER cph

EXPOSE 5900/tcp
EXPOSE 5901/tcp

ENTRYPOINT ["bash"]
CMD ["/opt/container_startup.sh"]
