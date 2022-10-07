FROM ubuntu:20.04
LABEL maintainer tomas.kalibera@gmail.com

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
  apt-get -y upgrade && \
  apt-get install -yq --no-install-recommends apt-utils && \
  rm -rf /var/lib/apt/lists/* && \
  apt autoremove -y

ENV TZ=Europe/Prague

# Install R build dependencies
RUN apt-get update && \
    sed -i 's/^# deb-src/deb-src/g' /etc/apt/sources.list && \
    apt-get update && \
    apt-get -y build-dep r-base && \
    apt-get -yq install rsync subversion && \
    apt-get -yq install libpcre2-dev && \
    rm -rf /var/lib/apt/lists/* && \
    apt autoremove -y
    
# Install hugo, pandoc
RUN apt-get update && \
  apt-get install -yq --no-install-recommends hugo pandoc && \
  rm -rf /var/lib/apt/lists/* && \
  apt autoremove -y

# Build R
RUN svn checkout https://svn.r-project.org/R/trunk && \
  cd trunk && \
  ./tools/rsync-recommended && \
  cd .. && \
  mkdir build && \
  cd build && \
  ../trunk/configure && \
  make -j 4 && \
  echo 'options(repos = c(CRAN="https://cran.r-project.org"))' > etc/Rprofile.site && \
  cd ..

# Install libraries for packages
RUN apt-get update && \
  apt-get install -yq --no-install-recommends libxml2-dev libssl-dev && \
  rm -rf /var/lib/apt/lists/* && \
  apt autoremove -y

# Install blogdown
RUN ./build/bin/Rscript -e 'install.packages(c("blogdown"), Ncpus=4)'

# Install required R packages
RUN ./build/bin/Rscript -e 'install.packages(c("dplyr", "MASS", "colorspace", "tidyr", "bench", "ggplot2", "tidyr", "ggbeeswarm", "kableExtra"), Ncpus=4)'

# Hack to pretend there is a web browser
RUN ln -s /bin/true /usr/local/bin/links

EXPOSE 4321

CMD cd /Blog && /build/bin/R
