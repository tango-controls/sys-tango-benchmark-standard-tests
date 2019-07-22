# sys-tango-benchmark-standard-tests
A set of standard tests for Tango benchmark

See
[tango-controls/sys-tango-benchmark](https://github.com/tango-controls/sys-tango-benchmark)
for more information and detailed instructions.

## Quick launch steps

1. setup the server machine (see `setup-server.sh`),
1. setup the client machine (see `setup-client.sh`),
1. update server's `host` in `tango-benchmarks.yml`,
1. on the server machine:
   * ensure that `Starter` is running,
   * ensure that device servers are not running,
1. on the client machine:
   * run `tg_benchmarkrunner -c tango-benchmarks-attr-read.yml > results-attr-read.rst`,
   * run `tg_benchmarkrunner -c tango-benchmarks-attr-write.yml > results-attr-write.rst`,
   * run `tg_benchmarkrunner -c tango-benchmarks-command.yml > results-command.rst`,
   * run `tg_benchmarkrunner -c tango-benchmarks-pipe-read.yml > results-pipe-read.rst`,
   * run `tg_benchmarkrunner -c tango-benchmarks-pipe-write.yml > results-pipe-write.rst`,
   * run `tg_benchmarkrunner -c tango-benchmarks-event-sub.yml > results-event-sub.rst`,
   * run `tg_benchmarkrunner -c tango-benchmarks-event-push.yml > results-event-push.rst`,
1. share the results!

