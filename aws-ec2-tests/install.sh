set -e
set -x

cd /tmp

apt update
apt install -y \
  git \
  make \
  docker.io \
  python-pip \
  mariadb-client \
  libboost-python1.65.1 \
  libomniorb4-dev \
  libczmq-dev \
  libomnithread4-dev \
  libcos4-dev \
  libzmq5 \
  libomniorb4-2 \
  libcos4-2 \
  libomnithread4 \
  libsodium23 \
  libpgm-5.2-0 \
  libmariadb3 \
  openjdk-8-jdk-headless \
  maven

update-java-alternatives --set java-1.8.0-openjdk-amd64

pip install numpy
pip install sphinx

ID=$(docker create registry.gitlab.com/s2innovation/tangobox-docker/tango-source-distribution:latest)
docker cp $ID:/tango-source-distribution_9.3.3-SNAPSHOT_amd64.deb .
docker cp $ID:/pytango-9.3.0-cp27-cp27mu-linux_x86_64.whl .
docker rm $ID
dpkg -i ./tango-source-distribution_9.3.3-SNAPSHOT_amd64.deb
pip install ./pytango-9.3.0-cp27-cp27mu-linux_x86_64.whl

ldconfig

export TANGO_ROOT=/usr/local
git clone https://github.com/tango-controls/sys-tango-benchmark.git
cd sys-tango-benchmark
git checkout af8dd0de316b1db86123100ff6b33ae682d5a9d0
cd benchmarks
pip install .
cd ../cppclient
make
make install
cd ../javaclient
./javaclient-build.sh
./javaclient-install.sh
cd ../ds/PyBenchmarkTarget
pip install .
cd ../CppBenchmarkTarget
make
make install
cd ../JavaBenchmarkTarget
mvn package
cp target/JavaBenchmarkTarget-1.0.jar /usr/local/share/java/
cp src/scripts/JavaBenchmarkTarget /usr/local/bin/
