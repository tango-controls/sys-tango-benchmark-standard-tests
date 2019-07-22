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

cd /benchmark/ds/CppBenchmarkTarget
make
make install

cd /benchmark/ds/JavaBenchmarkTarget
mvn package
cp target/JavaBenchmarkTarget-1.0.jar /usr/local/share/java/
cp src/scripts/JavaBenchmarkTarget /usr/local/bin/

cd /benchmark/ds/PyBenchmarkTarget
pip install .

tango_admin --add-server PyBenchmarkTarget/01 PyBenchmarkTarget sys/benchmark/python01
tango_admin --add-server CppBenchmarkTarget/01 CppBenchmarkTarget sys/benchmark/cpp01
tango_admin --add-server JavaBenchmarkTarget/01 JavaBenchmarkTarget sys/benchmark/java01

host=$(hostname -s)
tango_admin --add-server Starter/$host Starter tango/admin/$host
tango_admin --add-property tango/admin/$host StartDsPath /usr/bin,/usr/local/bin

Starter $host
