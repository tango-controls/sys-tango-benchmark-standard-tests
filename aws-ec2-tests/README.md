
```bash
git clone https://github.com/tango-controls/sys-tango-benchmark-standard-tests
cd sys-tango-benchmark-standard-tests/aws-ec2-tests/
sudo ./install.sh

# database
sudo docker run --name mariadb -e MYSQL_ROOT_PASSWORD=secret -p3306:3306 -d mariadb:10.4
cd /usr/local/share/tango/db/
mysql -h 127.0.0.1 -uroot -psecret < create_db.sql
TANGO_HOST=127.0.0.1:10000 MYSQL_HOST=127.0.0.1:3306 MYSQL_USER=root MYSQL_PASSWORD=secret MYSQL_DATABASE=tango DataBaseds 2 -ORBendPoint giop:tcp::10000

# devices
tango_admin --add-server PyBenchmarkTarget/01 PyBenchmarkTarget sys/benchmark/python01
tango_admin --add-server CppBenchmarkTarget/01 CppBenchmarkTarget sys/benchmark/cpp01
tango_admin --add-server JavaBenchmarkTarget/01 JavaBenchmarkTarget sys/benchmark/java01

# target server
export TANGO_HOST=ec2-3-16-217-170.us-east-2.compute.amazonaws.com:10000
taskset -a -c 0-8 CppBenchmarkTarget 01

# benchmark server
export TANGO_HOST=ec2-3-16-217-170.us-east-2.compute.amazonaws.com:10000
tg_read_benchmark -n 1,2,4,8,16 -p 10 -d sys/benchmark/cpp01
