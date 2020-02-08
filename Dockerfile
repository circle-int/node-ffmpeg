FROM node:10
RUN npm install pm2 -g
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN npm install -g lerna
RUN apt-get update -y -qq && apt-get -y install \
  autoconf \
  automake \
  build-essential \
  cmake \
  git-core \
  libass-dev \
  libfreetype6-dev \
  libsdl2-dev \
  libtool \
  libva-dev \
  libvdpau-dev \
  libvorbis-dev \
  libxcb1-dev \
  libxcb-shm0-dev \
  libxcb-xfixes0-dev \
  pkg-config \
  texinfo \
  wget \
  zlib1g-dev

RUN apt-get install nasm yasm libx264-dev libx265-dev libnuma-dev libvpx-dev libtheora-dev  libmp3lame-dev libopus-dev -y

RUN wget -O fdk-aac.zip https://github.com/mstorsjo/fdk-aac/zipball/master \
&& unzip fdk-aac.zip \
&& cd mstorsjo-fdk-aac* \
&& autoreconf -fiv \
&& ./configure --prefix="$HOME/ffmpeg_build" --disable-shared \
&& make \
&& make install \
&& make distclean

RUN wget http://ffmpeg.org/releases/ffmpeg-snapshot.tar.bz2 \
&& tar xjvf ffmpeg-snapshot.tar.bz2 \
&& cd ffmpeg \
&& PKG_CONFIG_PATH="$HOME/ffmpeg_build/lib/pkgconfig" \
&& export PKG_CONFIG_PATH \
&& ./configure --prefix="$HOME/ffmpeg_build" --extra-cflags="-I$HOME/ffmpeg_build/include" \
   --extra-ldflags="-L$HOME/ffmpeg_build/lib" --bindir="$HOME/bin" --extra-libs="-ldl" --enable-gpl \
   --enable-libass --enable-libfdk-aac --enable-libfreetype --enable-libwebp --enable-libmp3lame --enable-libopus \
   --enable-libtheora --enable-libvorbis --enable-avresample --enable-libx265 --enable-openssl --enable-libvpx --enable-libx264 --enable-nonfree \
&& make \
&& make install \
&& make distclean \
&& hash -r
RUN apt-get install imagemagick -y
RUN apt-get install python-pip -y
RUN pip install ez_setup
RUN pip install moviepy==1.0.0
RUN pip install scipy

#things will end here 
