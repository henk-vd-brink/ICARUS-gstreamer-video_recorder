FROM ubuntu:18.04

ENV TZ=Europe

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
	&& apt-get install -y \
		libgstreamer1.0-dev \
		libgstreamer-plugins-base1.0-dev \
		libgstreamer-plugins-bad1.0-dev \
		gstreamer1.0-plugins-base \
		gstreamer1.0-plugins-good \
		gstreamer1.0-plugins-bad \
		gstreamer1.0-plugins-ugly \
		gstreamer1.0-libav \
		gstreamer1.0-doc \
		gstreamer1.0-tools \
		gstreamer1.0-x \
		gstreamer1.0-alsa \
		gstreamer1.0-gl \
		gstreamer1.0-gtk3 \
		gstreamer1.0-qt5 \ 
		gstreamer1.0-pulseaudio \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get autoclean

RUN useradd gstreamer_user \
	&& chown "gstreamer_user:gstreamer_user" /usr/bin/gst* -R \
	&& chmod g+rwx /usr/bin/gst* \
	&& usermod -a -G video gstreamer_user

USER gstreamer_user

ENV GST_DEBUG 4

CMD gst-launch-1.0 -e udpsrc port=3100 \
    ! application/x-rtp,media=video,clock-rate=90000,encoding-name=H264,payload=96 \
    ! rtph264depay \
    ! avdec_h264 \
    ! videoconvert \
    ! jpegenc \
    ! avimux \
    ! filesink location=mjpeg.avi
