FROM debian:latest

# Highly inspirated from EvilFreelancer/docker-lfs-build
LABEL description="Automated LFS (HexaSquare distro)"
LABEL version="11.0-80-systemd"
LABEL maintainer="me@nox.finance"

# LFS mount point
ENV LFS=/lfs

# Other LFS params
ENV LC_ALL=POSIX
ENV LFS_TGT=x86_64-hexasquare-linux-gnu
ENV PATH=/tools/bin:/bin:/usr/bin:/sbin:/usr/bin
ENV MAKEFLAGS="-j2"

# set 1 to run tests; running tests takes much more time
ENV LFS_TEST=0

# set 1 to install documentation; slighty increases final size
ENV LFS_DOCS=1

# degree of parallelism for compilation
ENV JOB_COUNT=2

# loop device
ENV LOOP=/dev/loop2

# mount point of loop device, for creating the iso image
ENV LOOP_DIR=/image/loop

# initial ram disk size in KB
# must be in sync with CONFIG_BLK_DEV_RAM_SIZE
ENV IMAGE_SIZE=1000000

# output images
ENV IMAGE_RAM=/dist/lfs.ram
ENV IMAGE_BZ2=/dist/lfs.bz2
ENV IMAGE_ISO=/dist/lfs.iso
ENV IMAGE_HDD=/dist/lfs.hdd

# location of initrd tree
ENV INITRD_TREE=$LFS

# set bash as default shell
WORKDIR /bin
RUN rm sh && ln -s bash sh

# insall required packages
RUN apt-get update && apt-get install -y \
		build-essential											 \
		bison																 \
		file																 \
		gawk																 \
		texinfo															 \
		wget																 \
		sudo																 \
		genisoimage													 \
 && apt-get -q -y autoremove						 \
 && rm -rf /var/lib/apt/lists/*

# create sources directory as writable and sticky
RUN mkdir -p			$LFS/sources	\
 && chmod -v a+wt $LFS/sources	\
 && ln -sv				$LFS/sources /

# create book directory as writable and sticky
RUN mkdir -p			$LFS/book	\
 && chmod -v a+wt $LFS/book	\
 && ln -sv				$LFS/book /

# create image directory as writable and sticky
RUN mkdir -p			$LFS/image	\
 && chmod -v a+wt $LFS/image	\
 && ln -sv				$LFS/image /

# copy additional scripts and archives
COPY ["book/",		"$LFS/book/"]
COPY ["image/",		"$LFS/image/"]
COPY ["sources/",	"$LFS/sources/"]

# create tools directory and symlink
RUN mkdir -pv $LFS/tools	\
 && ln -sv		$LFS/tools /

# check environment
RUN $LFS/book/version-check.sh \
 && $LFS/book/library-check.sh

# create lfs user with 'lfs' password
RUN groupadd lfs																		\
 && useradd -s /bin/bash -g lfs -m -k /dev/null lfs \
 && echo "lfs:lfs" | chpasswd
RUN adduser lfs sudo

# give lfs user ownership of directories
RUN chown -v lfs $LFS/tools		\
 && chown -v lfs $LFS/sources

# avoid sudo password
RUN echo 'Defaults secure_path="/tools/bin:/bin:/usr/bin:/sbin:/usr/sbin"' >> /etc/sudoers
RUN echo "lfs ALL = NOPASSWD : ALL" >> /etc/sudoers
RUN echo 'Defaults env_keep += "LFS LC_ALL LFS_TGT PATH MAKEFLAGS FETCH_TOOLCHAIN_MODE LFS_TEST LFS_DOCS JOB_COUNT LOOP LOOP_DIR IMAGE_SIZE INITRD_TREE IMAGE_RAM IMAGE_BZ2 IMAGE_ISO IMAGE_HDD"' >> /etc/sudoers

# login as lfs user
USER lfs
COPY [".bash_profile", ".bashrc", "/home/lfs"]
RUN source ~/.bash_profile

# change path to home folder as default
WORKDIR /home/lfs

# download all sources
RUN /book/chapter-3.sh

# let's the party begin
ENTRYPOINT ["/book/book.sh"]
