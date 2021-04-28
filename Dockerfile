FROM node:10
RUN npm install pm2 -g
RUN mkdir -p /ffmpeg_sources /ffmpeg_build /bin
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

RUN apt-get install nasm yasm libx264-dev  libopencore-amrnb-dev libopencore-amrwb-dev libx265-dev libnuma-dev libvpx-dev libtheora-dev  libmp3lame-dev libopus-dev -y
RUN apt-get update && \ 
     apt-get install -yq --no-install-recommends \ 
     libasound2 libatk1.0-0 libc6 libcairo2 libcups2 libdbus-1-3 \ 
     libexpat1 libfontconfig1 libgcc1 libgconf-2-4 libgdk-pixbuf2.0-0 libglib2.0-0 libgtk-3-0 libnspr4 \ 
     libpango-1.0-0 libpangocairo-1.0-0 libstdc++6 libx11-6 libx11-xcb1 libxcb1 \ 
     libxcursor1 libxdamage1 libxext6 libxfixes3 libxi6 libxrandr2 libxrender1 libxss1 libxtst6 \ 
     libnss3 
RUN apt-get install software-properties-common -y

RUN wget -O fdk-aac.zip https://github.com/mstorsjo/fdk-aac/zipball/master \
&& unzip fdk-aac.zip \
&& cd mstorsjo-fdk-aac* \
&& autoreconf -fiv \
&& ./configure --prefix="/ffmpeg_build" --disable-shared \
&& make \
&& make install \
&& make distclean
# RUN git -C aom pull 2> /dev/null || git clone --depth 1 https://aomedia.googlesource.com/aom && \
# mkdir -p aom_build && \
# cd aom_build && \
# PATH="$HOME/bin:$PATH" cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="$HOME/ffmpeg_build" -DENABLE_SHARED=off -DENABLE_NASM=on ../aom && \
# PATH="$HOME/bin:$PATH" make && \
# make install
RUN echo "deb http://www.deb-multimedia.org stretch main" >> /etc/apt/sources.list \
 && apt-get update -y \
 && apt-get install deb-multimedia-keyring -y --allow-unauthenticated\
 && apt-get install libkvazaar-dev libvidstab-dev -y --allow-unauthenticated


RUN wget -O ffmpeg-4.2.2.tar.bz2 https://ffmpeg.org/releases/ffmpeg-4.2.2.tar.bz2 && \
tar xjvf ffmpeg-4.2.2.tar.bz2 && \
cd ffmpeg-4.2.2 && \
PATH="/bin:$PATH" PKG_CONFIG_PATH="/ffmpeg_build/lib/pkgconfig" ./configure \
  --prefix="/ffmpeg_build" \
  --pkg-config-flags="--static" \
  --extra-cflags="-I/ffmpeg_build/include" \
  --extra-ldflags="-L/ffmpeg_build/lib" \
  --extra-libs="-lpthread -lm" \
  --bindir="/bin" \
  --disable-debug \
 --disable-doc \
 --disable-ffplay \
 --enable-avresample \
 --enable-libopencore-amrnb \
 --enable-libopencore-amrwb \
 --enable-gpl \
 --enable-libass \
 --enable-libfreetype \
 --enable-libvidstab \
 --enable-libmp3lame \
 --enable-libopenjpeg \
 --enable-libopus \
 --enable-libtheora \
 --enable-libvorbis \
 --enable-libvpx \
 --enable-libwebp \
 --enable-libxcb \
 --enable-libx265 \
 --enable-libx264 \
 --enable-nonfree \
 --enable-openssl \
 --enable-libfdk-aac \
 --enable-libkvazaar \
 --enable-postproc \
 --enable-small \
 --enable-version3 \
 --enable-nonfree && \
PATH="/bin:$PATH" make && \
make install && \
hash -r

 
RUN apt-get install imagemagick -y
RUN apt-get install python-pip -y
RUN pip install ez_setup
RUN pip install moviepy==1.0.0
RUN pip install scipy
RUN apt-get install fonts-indic -y
RUN apt-get install fonts-noto -y
