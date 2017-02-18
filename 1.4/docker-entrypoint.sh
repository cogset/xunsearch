#!/bin/bash

XS_PREFIX=/usr/local/xunsearch
XS_LOG_FILE=$XS_PREFIX/tmp/docker.log

if [ "${1#-}" != "$1" ]; then
	exec "$@"
fi

function print_usage {
  echo
  echo "Usage:"
  echo "  [OPTIONS]"
  echo
  echo "Options:"
  echo "  -b, --bind string               Bind address or path"
  echo "  -l, --log-level int             Log level: 1 - 7"
  echo "  -s, --server string             Server type: index, search, both"
  echo "  -n, --worker-number int         Number of search worker process"
  echo "  -p, --port int                  Port number of index server, and the port number of search"
  echo "                                  will be <port+1>"
  echo
  echo "  -h, --help                      Print this message"
  echo
}

OPTIONS=`getopt -o b:l:s:n:p:h --long bind:,log-level:,server:,worker-number:,port:,help -n xunsearch -- "$@"`
if [ $? -ne 0 ]; then
  print_usage
  exit 1
fi

XS_BIND="0.0.0.0"
XS_PORT="8383"
XS_SERVER="both"
XS_WORKER=
XS_LOG_LEVEL=

eval set -- "$OPTIONS"
while true; do
  case "$1" in
    -b|--bind)                XS_BIND="$2";                   shift 2;;
    -l|--log-level)           XS_LOG_LEVEL="-L $2";           shift 2;;
    -s|--server)              XS_SERVER="$2";                 shift 2;;
    -n|--worker-number)       XS_WORKER="-n $2";              shift 2;;
    -p|--port)                XS_PORT="-p $2";                shift 2;;
    --)                                                       shift; break;;
    -h|--help)                print_usage;                    exit 0;;

    *)
      echo "Unexpected argument: $1"
      print_usage
      exit 1;;
  esac
done

case $XS_BIND in
  local)
    XS_INDEX_OPT="-b 127.0.0.1:$XS_PORT"
    XS_SEARCH_OPT="-b 127.0.0.1:"`expr $XS_PORT + 1`
    ;;
  unix)
    XS_INDEX_OPT="-b $XS_PREFIX/tmp/indexd.sock"
    XS_SEARCH_OPT="-b $XS_PREFIX/tmp/searchd.sock"
    ;;
  inet)
    XS_INDEX_OPT="-b $XS_PORT"
    XS_SEARCH_OPT="-b "`expr $XS_PORT + 1`
    ;;
  *)
    XS_INDEX_OPT="-b $XS_BIND:$XS_PORT"
    XS_SEARCH_OPT="-b $XS_BIND:"`expr $XS_PORT + 1`
    ;;
esac

XS_INDEX_OPT="-l $XS_LOG_FILE $XS_LOG_LEVEL $XS_SEARCH_OPT -k start"
XS_SEARCH_OPT="-l $XS_LOG_FILE $XS_LOG_LEVEL $XS_WORKER $XS_SEARCH_OPT -k start"

rm -f $XS_PREFIX/tmp/pid.*
echo -n > $XS_PREFIX/tmp/docker.log

case $XS_SERVER in
  index)
    $XS_PREFIX/bin/xs-indexd $XS_INDEX_OPT
    ;;
  search)
    $XS_PREFIX/bin/xs-searchd $XS_SEARCH_OPT
    ;;
  both)
    $XS_PREFIX/bin/xs-indexd $XS_INDEX_OPT
    $XS_PREFIX/bin/xs-searchd $XS_SEARCH_OPT
    ;;
  *)
    echo "Unknown server type: $XS_SERVER"
    print_usage
    exit 1;;
esac

tail -f $XS_LOG_FILE