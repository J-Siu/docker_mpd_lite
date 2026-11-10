# docker_mpd_lite
ARG VER="0.24.18"
ARG USR="https://github.com/J-Siu"

FROM alpine:edge AS base

FROM base AS build_base
ARG VER

RUN VER=$(echo ${VER} | cut -d. -f-2) \
&& wget https://www.musicpd.org/download/mpd/${VER}/mpd-${VER}.tar.xz \
&& tar xf mpd-${VER}.tar.xz

WORKDIR /mpd-${VER}
RUN apk --no-cache add \
alsa-lib-dev \
boost \
boost-dev \
build-base \
ffmpeg-dev \
meson \
ninja \
sqlite-dev \
&& meson . output/release \
--prefix=/usr \
--sysconfdir=/etc \
--mandir=/usr/share/man \
--localstatedir=/var \
--buildtype=release \
-Dadplug=disabled \
-Dalsa=enabled \
-Dandroid_abi=disabled \
-Dao=disabled \
-Daudiofile=disabled \
-Dbzip2=disabled \
-Dcdio_paranoia=disabled \
-Dchromaprint=disabled \
-Dcue=true \
-Dcurl=disabled \
-Ddaemon=false \
-Ddatabase=true \
-Ddbus=disabled \
-Ddocumentation=disabled \
-Ddsd=false \
-Depoll=true \
-Deventfd=true \
-Dexpat=disabled \
-Dfaad=disabled \
-Dffmpeg=enabled \
-Dfifo=true \
-Dflac=disabled \
-Dfluidsynth=disabled \
-Dgme=disabled \
-Dhttpd=false \
-Diconv=disabled \
-Dicu=disabled \
-Did3tag=disabled \
-Dinotify=true \
-Dipv6=enabled \
-Diso9660=disabled \
-Djack=disabled \
-Dlame=disabled \
-Dlibmpdclient=disabled \
-Dlibsamplerate=disabled \
-Dlocal_socket=false \
-Dmad=disabled \
-Dmikmod=disabled \
-Dmms=disabled \
-Dmodplug=disabled \
-Dmpcdec=disabled \
-Dmpg123=disabled \
-Dneighbor=false \
-Dnfs=disabled \
-Dopenal=disabled \
-Dopus=disabled \
-Doss=disabled \
-Dpcre=disabled \
-Dpipe=true \
-Dpulse=disabled \
-Dqobuz=disabled \
-Drecorder=false \
-Dshine=disabled \
-Dshout=disabled \
-Dsidplay=disabled \
-Dsignalfd=true \
-Dsmbclient=disabled \
-Dsnapcast=false \
-Dsndfile=disabled \
-Dsndio=disabled \
-Dsolaris_output=disabled \
-Dsoxr=disabled \
-Dsqlite=enabled \
-Dsyslog=disabled \
-Dsystemd=disabled \
-Dtcp=true \
-Dtest=false \
-Dtremor=disabled \
-Dtwolame=disabled \
-Dudisks=disabled \
-Dupnp=auto \
-Dvorbis=disabled \
-Dvorbisenc=disabled \
-Dwave_encoder=false \
-Dwavpack=disabled \
-Dwebdav=disabled \
-Dwildmidi=disabled \
-Dzeroconf=disabled \
-Dzlib=disabled \
-Dzzip=disabled \
&& meson configure --no-pager output/release \
&& ninja -j 4 -C output/release

FROM base
ARG VER
ARG USR
LABEL version=${VER}
LABEL maintainers="[John Sing Dao Siu](${USR})"
LABEL name="mpd_lite"
LABEL usage="${USR}/docker_mpd/blob/master/README.md"
LABEL description="Docker - MPD Lite with UID/GID + audio GID handling."

COPY --from=build_base /mpd-${VER}/output/release/mpd /usr/bin/
RUN apk --no-cache add alsa-lib sqlite-libs ffmpeg-libs

COPY docker-compose.yml env start.sh mpd.conf /
RUN chmod u+x /start.sh \
&& chmod ugo+x /usr/bin/mpd \
&& mkdir /mpd

CMD ["/start.sh"]
