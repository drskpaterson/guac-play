########################################################################
#                   guac-play
########################################################################

FROM centos:7

MAINTAINER drskpaterson

LABEL vendor="CentOS"

ENV HOME /home/developer

# Add the needed packages
RUN yum -y update;
RUN yum install epel-release -y;
RUN yum -y install dnf;
RUN yum -y update; yum clean all;
RUN yum -y install centos-release-openshift-origin;
RUN yum -y groups install "GNOME Desktop";

RUN dnf -y update;
RUN dnf -y install \
           gettext \
           gtk3 \
           java-1.8.0-openjdk-devel \
           liberation-sans-fonts \
           webkitgtk3 \
           maven \
           nss_wrapper \
           openbox \
           tigervnc-server \
           wmctrl \
           origin-clients

RUN dnf -y clean all;

# Create installation directory and set the openbox window manager
# configuration for all users
RUN    echo 'export DISPLAY=:1' >> /etc/xdg/openbox/environment \
    && echo 'exec gnome-session' >> /etc/xdg/openbox/autostart



# This script starts and cleanly shuts down gui and the Xvnc server
ADD resources/start.sh /usr/local/bin/

# This file is used to create a temporary passwd file for use by
# the NSS wrapper so that the openbox window manager can launch
# correctly.  OCP will use a non-deterministic user id, so we have
# to provide a valid passwd entry for that UID for openbox
ADD resources/passwd.template /usr/local/share/

# Create the home directory and set permissions
RUN    mkdir -p ${HOME} \
    && chmod a+rwX ${HOME} \
    && chmod a+rx /usr/local/bin/start.sh \
    && chmod a+r /usr/local/share/passwd.template

EXPOSE 5901

USER 1000

CMD /usr/local/bin/start.sh

# No volume support yet, so everything in /home/developer is ephemeral.
# Eventually this can be a mounted persistent volume so each user can
# have a persistent maven repository, workspace, etc.
