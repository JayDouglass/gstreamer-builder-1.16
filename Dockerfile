FROM balenalib/raspberrypi3:buster-build AS gstreamer_builder
RUN install_packages \
    libraspberrypi-dev \
    build-essential \
    pkg-config \
    python3 python3-pip python3-setuptools \
    python3-wheel ninja-build git \
    flex bison \
    autotools-dev automake autoconf checkinstall \
    libtool autopoint libxml2-dev zlib1g-dev libglib2.0-dev \
    wget tar gtk-doc-tools libasound2-dev \
    libgudev-1.0-dev libvorbis-dev libcdparanoia-dev \
    libtheora-dev libvisual-0.4-dev iso-codes \
    libraw1394-dev libiec61883-dev libavc1394-dev \
    libv4l-dev libcaca-dev libspeex-dev libpng-dev \
    libshout3-dev libjpeg-dev libflac-dev libdv4-dev \
    libtag1-dev libwavpack-dev libsoup2.4-dev libbz2-dev \
    libcdaudio-dev libdc1394-22-dev ladspa-sdk libass-dev \
    libcurl4-gnutls-dev libdca-dev libdvdnav-dev \
    libexempi-dev libexif-dev libfaad-dev libgme-dev libgsm1-dev \
    libiptcdata0-dev libkate-dev libmms-dev \
    libmodplug-dev libmpcdec-dev libofa0-dev libopus-dev \
    librtmp-dev \
    libsndfile1-dev libsoundtouch-dev libspandsp-dev \
    libxvidcore-dev libzvbi-dev liba52-0.7.4-dev \
    libcdio-dev libdvdread-dev libmad0-dev libmp3lame-dev \
    libmpeg2-4-dev libopencore-amrnb-dev libopencore-amrwb-dev \
    libsidplay1-dev libtwolame-dev libx264-dev libusb-1.0 \
    python-gi-dev yasm python3-dev libgirepository1.0-dev \
    freeglut3 libgl1-mesa-dri \
    weston wayland-protocols pulseaudio libpulse-dev libssl-dev \
    libgtk-3-dev gettext freeglut3-dev \
    libx11-xcb-dev \
    libegl1-mesa-dev libgles2-mesa-dev 
RUN pip3 install meson
WORKDIR /build
RUN git clone -b 1.16 https://gitlab.freedesktop.org/gstreamer/gstreamer.git
RUN PKG_CONFIG_PATH=/opt/vc/lib/pkgconfig/ meson --prefix=/opt/gstreamer \
    -D examples=disabled -D doc=disabled -D introspection=disabled \
    -D gst-plugins-base:gl=enabled \
    -D gst-plugins-base:gl_api=gles2 \
    -D gst-plugins-base:gl_platform=egl \
    -D gst-plugins-base:gl_winsys=x11 \
    -D orc=enabled -D orc:orc-backend=neon \
    -D omx=enabled -D gst-omx:target=rpi -D gst-omx:header_path="/opt/vc/include/IL" \
    builddir
RUN ninja -C builddir
RUN mkdir /opt/gstreamer
RUN meson install -C builddir

