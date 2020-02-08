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
RUN git -C aom pull 2> /dev/null || git clone --depth 1 https://aomedia.googlesource.com/aom && \
mkdir -p aom_build && \
cd aom_build && \
PATH="$HOME/bin:$PATH" cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="$HOME/ffmpeg_build" -DENABLE_SHARED=off -DENABLE_NASM=on ../aom && \
PATH="$HOME/bin:$PATH" make && \
make install

# RUN wget http://ffmpeg.org/releases/ffmpeg-snapshot.tar.bz2 \
# && tar xjvf ffmpeg-snapshot.tar.bz2 \
# && cd ffmpeg \
# && PKG_CONFIG_PATH="$HOME/ffmpeg_build/lib/pkgconfig" \
# && export PKG_CONFIG_PATH \
# && ./configure --prefix="$HOME/ffmpeg_build" --extra-cflags="-I$HOME/ffmpeg_build/include" \
#    --extra-ldflags="-L$HOME/ffmpeg_build/lib" --bindir="$HOME/bin" --extra-libs="-ldl" --enable-gpl \
#    --enable-libass --enable-libfdk-aac --enable-libfreetype --enable-libwebp --enable-libmp3lame --enable-libopus \
#    --enable-libtheora --enable-libvorbis --enable-avresample --enable-libx265 --enable-openssl --enable-libvpx --enable-libx264 --enable-nonfree \
# && make \
# && make install \
# && make distclean \
# && hash -r
RUN wget -O ffmpeg-snapshot.tar.bz2 https://ffmpeg.org/releases/ffmpeg-snapshot.tar.bz2 && \
tar xjvf ffmpeg-snapshot.tar.bz2 && \
cd ffmpeg && \
PATH="$HOME/bin:$PATH" PKG_CONFIG_PATH="$HOME/ffmpeg_build/lib/pkgconfig" ./configure \
  --prefix="$HOME/ffmpeg_build" \
  --pkg-config-flags="--static" \
  --extra-cflags="-I$HOME/ffmpeg_build/include" \
  --extra-ldflags="-L$HOME/ffmpeg_build/lib" \
  --extra-libs="-lpthread -lm" \
  --bindir="$HOME/bin" \
  --enable-gpl \
  --enable-libaom \
  --enable-libass \
  --enable-libfdk-aac \
  --enable-libfreetype \
  --enable-libmp3lame \
  --enable-libopus \
  --enable-libvorbis \
  --enable-libvpx \
  --enable-libx264 \
  --enable-libx265 \
  --enable-nonfree && \
PATH="$HOME/bin:$PATH" make && \
make install && \
hash -r
RUN apt-get install imagemagick -y
RUN apt-get install python-pip -y
RUN pip install ez_setup
RUN pip install moviepy==1.0.0
RUN pip install scipy

#things will end here 
