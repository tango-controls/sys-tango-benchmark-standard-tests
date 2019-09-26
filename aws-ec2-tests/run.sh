#!/usr/bin/env bash

CLIENTS='1,2,4,8,16,32,64,96'
PERIOD='15'

TGT_PY=sys/benchmark/python01
TGT_CPP=sys/benchmark/cpp01
TGT_JAVA=sys/benchmark/java01

TGT_INSTANCES=(
  ec2-52-14-141-108.us-east-2.compute.amazonaws.com
  ec2-18-224-70-75.us-east-2.compute.amazonaws.com
  ec2-18-223-159-10.us-east-2.compute.amazonaws.com
  ec2-13-59-209-221.us-east-2.compute.amazonaws.com
)

function run_benchmark {
  client=$1
  bmark=$2
  device=$3
  host=$4
  shift 4
  csvfile=bmark_${client}_client_${bmark}_$(basename $device)_${host}.csv
  tg_${bmark}_benchmark -n "$CLIENTS" -p "$PERIOD" -d $device -f $csvfile $@
}

declare -A cpp_client_name
cpp_client_name=(
  ['read']='read'
  ['write']='write'
  ['cmd']='command'
  ['push_event']='pushevent'
  ['event']='event'
  ['pipe_read']='pipe_read'
  ['pipe_write']='pipe_write'
)

declare -A java_client_name
java_client_name=(
  ['read']='read'
  ['write']='write'
  ['cmd']='command'
  ['push_event']='pushevent'
  ['event']='event'
  ['pipe_read']='piperead'
  ['pipe_write']='pipewrite'
)

declare -A device_to_server
device_to_server=(
  ['sys/benchmark/python01']='PyBenchmarkTarget'
  ['sys/benchmark/cpp01']='CppBenchmarkTarget'
  ['sys/benchmark/java01']='JavaBenchmarkTarget'
)


for instance in ${TGT_INSTANCES[*]}; do
  for bmark in read write push_event event; do
    for device in $TGT_PY $TGT_CPP $TGT_JAVA; do
      cpp_client=${cpp_client_name[$bmark]}
      java_client=${java_client_name[$bmark]}
      server=${device_to_server[$device]}
      for client_kind in py; do

        declare -A client_kind_to_opts
        client_kind_to_opts=(
          ['py']=''
          ['cpp']="--worker tangobenchmarks.client.external.Worker --worker-program tg_benchmark_client_${cpp_client}"
          ['java']="--worker tangobenchmarks.client.external.Worker --worker-program tg_benchmark_client_java_${java_client}"
        )

        client_opts="${client_kind_to_opts[$client_kind]}"

        echo "Running $client_kind $bmark ($cpp_client) on $device ... @ $server @ $instance with: ${client_opts}"

        ssh -i ~/aws-keypar-01.pem ubuntu@$instance "TANGO_HOST=$TANGO_HOST TANGO_ROOT=/usr/local $server 01" &>/dev/null &
        sleep 2

	# python -c "import tango; tango.DeviceProxy('$device').ping()"
        run_benchmark $client_kind $bmark $device $instance ${client_opts}

        ssh -i ~/aws-keypar-01.pem ubuntu@$instance killall PyBenchmarkTarget CppBenchmarkTarget JavaBenchmarkTarget java &>/dev/null || true

      done
    done
  done

  # test read cpp server from cpp client
  # test read java server from java client
  # test read py server from cpp client

	server=${device_to_server[$TGT_CPP]}
        echo "Running cpp read on $TGT_CPP ... @ $server @ $instance"
        ssh -i ~/aws-keypar-01.pem ubuntu@$instance "TANGO_HOST=$TANGO_HOST TANGO_ROOT=/usr/local $server 01" &>/dev/null &
        sleep 2
        run_benchmark cpp read $TGT_CPP $instance --worker tangobenchmarks.client.external.Worker --worker-program tg_benchmark_client_read
        ssh -i ~/aws-keypar-01.pem ubuntu@$instance killall PyBenchmarkTarget CppBenchmarkTarget JavaBenchmarkTarget java &>/dev/null || true

	server=${device_to_server[$TGT_JAVA]}
        echo "Running java read on $TGT_JAVA ... @ $server @ $instance"
        ssh -i ~/aws-keypar-01.pem ubuntu@$instance "TANGO_HOST=$TANGO_HOST TANGO_ROOT=/usr/local $server 01" &>/dev/null &
        sleep 2
        run_benchmark java read $TGT_JAVA $instance --worker tangobenchmarks.client.external.Worker --worker-program tg_benchmark_client_java_read
        ssh -i ~/aws-keypar-01.pem ubuntu@$instance killall PyBenchmarkTarget CppBenchmarkTarget JavaBenchmarkTarget java &>/dev/null || true

	server=${device_to_server[$TGT_PY]}
        echo "Running cpp read on $TGT_PY ... @ $server @ $instance"
        ssh -i ~/aws-keypar-01.pem ubuntu@$instance "TANGO_HOST=$TANGO_HOST TANGO_ROOT=/usr/local $server 01" &>/dev/null &
        sleep 2
        run_benchmark cpp read $TGT_PY $instance --worker tangobenchmarks.client.external.Worker --worker-program tg_benchmark_client_read
        ssh -i ~/aws-keypar-01.pem ubuntu@$instance killall PyBenchmarkTarget CppBenchmarkTarget JavaBenchmarkTarget java &>/dev/null || true
done
