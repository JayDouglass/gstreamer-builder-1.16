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
WORKDIR /build/gstreamer
# RUN PKG_CONFIG_PATH=/opt/vc/lib/pkgconfig/ meson --prefix=/opt/gstreamer \
#     -D examples=disabled -D doc=disabled -D introspection=disabled \
#     -D gst-plugins-base:gl=enabled \
#     -D gst-plugins-base:gl_api=gles2 \
#     -D gst-plugins-base:gl_platform=egl \
#     -D gst-plugins-base:gl_winsys=x11 \
#     -D omx=enabled -D gst-omx:target=rpi -D gst-omx:header_path="/opt/vc/include/IL" \
#     builddir
# RUN ninja -C builddir
# RUN mkdir /opt/gstreamer
# RUN meson install -C builddir
RUN PKG_CONFIG_PATH=/opt/vc/lib/pkgconfig/ meson --prefix=/opt/gstreamer build
RUN ninja -C build
RUN ninja -C build install

WORKDIR /build
RUN git clone -b 1.16 https://gitlab.freedesktop.org/gstreamer/gst-plugins-base.git
WORKDIR /build/gst-plugins-base
# disable gtk_doc because it errors on install
RUN PKG_CONFIG_PATH=/opt/vc/lib/pkgconfig/:/opt/gstreamer/lib/arm-linux-gnueabihf/pkgconfig \
    meson --prefix=/opt/gstreamer \
    -D gl=enabled \
    -D gl_api=gles2 \
    -D gl_platform=egl \
    -D gl_winsys=x11 \    
    -D gtk_doc=disabled \
    build
RUN ninja -C build
RUN ninja -C build install    

WORKDIR /build
RUN git clone -b 1.16 https://gitlab.freedesktop.org/gstreamer/gst-plugins-good.git
WORKDIR /build/gst-plugins-good
RUN PKG_CONFIG_PATH=/opt/vc/lib/pkgconfig/:/opt/gstreamer/lib/arm-linux-gnueabihf/pkgconfig \
    meson --prefix=/opt/gstreamer \
    build
RUN ninja -C build
RUN ninja -C build install   

WORKDIR /build
RUN install_packages tclsh libssl-dev cmake
RUN git clone https://github.com/Haivision/srt.git
WORKDIR /build/srt
RUN echo "set(CMAKE_CXX_LINK_FLAGS "${CMAKE_CXX_LINK_FLAGS} -latomic")" >> CMakeLists.txt
RUN ./configure --prefix=/opt/srt && make
RUN make install

WORKDIR /build
RUN git clone -b 1.16 https://gitlab.freedesktop.org/gstreamer/gst-plugins-bad.git
WORKDIR /build/gst-plugins-bad
RUN PKG_CONFIG_PATH=/opt/vc/lib/pkgconfig/:/opt/gstreamer/lib/arm-linux-gnueabihf/pkgconfig:/opt/srt/lib/pkgconfig/ \
    meson --prefix=/opt/gstreamer \
    -D srt=enabled \
	-D rtmp=enabled \    
    -D examples=disabled -D tests=disabled \
    build
RUN ninja -C build
RUN ninja -C build install   
