# For debian / ubuntu.
# Requires Tango to be installed.
# Tested on docker image: registry.gitlab.com/s2innovation/tangobox-docker/tangobox-base

apt update

apt install -y \
    git \
    g++ \
    make \
    libomniorb4-dev \
    libzmq3-dev \
    libcos4-dev \
    openjdk-8-jdk-headless \
    maven \
    python-pip

pip install 'docutils<0.15'
pip install sphinx

export TANGO_ROOT=/usr/local

git clone https://github.com/tango-controls/sys-tango-benchmark.git /benchmark

cd /benchmark/benchmarks
pip install .

cd /benchmark/cppclient
make
make install

cd /benchmark/javaclient
./javaclient-build.sh
./javaclient-install.sh
