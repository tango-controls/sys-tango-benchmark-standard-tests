#!/usr/bin/env bash

CLIENTS='1,2,4,8,16,26,36,46,58,72,84,96,112,128'
PERIOD='15'

TGT_PY=sys/benchmark/python01
TGT_CPP=sys/benchmark/cpp01
TGT_JAVA=sys/benchmark/java01

declare -A size_to_hostname_tgt
size_to_hostname_tgt=(
  ['large']='ec2-3-16-130-116.us-east-2.compute.amazonaws.com'
  ['xlarge']='ec2-18-191-108-241.us-east-2.compute.amazonaws.com'
  ['2xlarge']='ec2-18-224-45-35.us-east-2.compute.amazonaws.com'
  ['4xlarge']='ec2-3-17-110-112.us-east-2.compute.amazonaws.com'
  ['9xlarge']='ec2-18-218-252-2.us-east-2.compute.amazonaws.com'
  ['18xlarge']='ec2-3-15-206-41.us-east-2.compute.amazonaws.com'
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


# server testing
# for inst_size in large xlarge 2xlarge 4xlarge 9xlarge 18xlarge; do
#   for bmark in read write; do
#     for device in $TGT_PY $TGT_CPP $TGT_JAVA; do
#       cpp_client=${cpp_client_name[$bmark]}
#       java_client=${java_client_name[$bmark]}
#       server=${device_to_server[$device]}
#       instance="${size_to_hostname_tgt[$inst_size]}"
#       for client_kind in py; do
# 
#         declare -A client_kind_to_opts
#         client_kind_to_opts=(
#           ['py']=''
#           ['cpp']="--worker tangobenchmarks.client.external.Worker --worker-program tg_benchmark_client_${cpp_client}"
#           ['java']="--worker tangobenchmarks.client.external.Worker --worker-program tg_benchmark_client_java_${java_client}"
#         )
# 
#         client_opts="${client_kind_to_opts[$client_kind]}"
# 
#         echo "Running $client_kind $bmark ($cpp_client) on $device ... @ $server @ $instance with: ${client_opts}"
# 
#         ssh -i ~/aws-keypar-01.pem ubuntu@$instance "TANGO_HOST=$TANGO_HOST TANGO_ROOT=/usr/local $server 01" &>/dev/null &
#         sleep 2
# 
#         run_benchmark $client_kind $bmark $device $inst_size ${client_opts}
# 
#         ssh -i ~/aws-keypar-01.pem ubuntu@$instance killall PyBenchmarkTarget CppBenchmarkTarget JavaBenchmarkTarget java &>/dev/null || true
# 
#       done
#     done
#   done
# done


# client testing
for inst_size in 18xlarge; do
  for bmark in read write; do
    for device in $TGT_PY; do
      cpp_client=${cpp_client_name[$bmark]}
      java_client=${java_client_name[$bmark]}
      server=${device_to_server[$device]}
      instance="${size_to_hostname_tgt[$inst_size]}"
      for client_kind in py cpp java; do

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

        run_benchmark $client_kind $bmark $device $inst_size ${client_opts}

        ssh -i ~/aws-keypar-01.pem ubuntu@$instance killall PyBenchmarkTarget CppBenchmarkTarget JavaBenchmarkTarget java &>/dev/null || true

      done
    done
  done
done
