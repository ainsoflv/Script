#!/usr/bin/env bash
stty erase ^H
PORT=0
#判断当前端口是否被占用，没被占用返回0，反之1
function Listening() {
  TCPListeningnum=$(netstat -an | grep ":$1 " | awk '$1 == "tcp" && $NF == "LISTEN" {print $0}' | wc -l)
  UDPListeningnum=$(netstat -an | grep ":$1 " | awk '$1 == "udp" && $NF == "0.0.0.0:*" {print $0}' | wc -l)
  ((Listeningnum = TCPListeningnum + UDPListeningnum))
  if [ $Listeningnum == 0 ]; then
    echo "0"
  else
    echo "1"
  fi
}

case $(uname -m) in
x86_64) is_x86=1 ;;
aarch64) is_x86=0 ;;
esac

synology=0
if [[ $(uname -a) == *synology* ]]; then
  synology=1
fi

#指定区间随机数
function random_range() {
  shuf -i $1-$2 -n1
}

#得到随机端口
function get_random_port() {
  templ=0
  while [ $PORT == 0 ]; do
    temp1=$(random_range $1 $2)
    if [ $(Listening $temp1) == 0 ]; then
      PORT=$temp1
    fi
  done
  echo "port=$PORT"
}

TIME() {
  [[ -z "$1" ]] && {
    echo -ne " "
  } || {
    case $1 in
    r) export Color="\e[31;1m" ;;
    g) export Color="\e[32;1m" ;;
    b) export Color="\e[34;1m" ;;
    y) export Color="\e[33;1m" ;;
    z) export Color="\e[35;1m" ;;
    l) export Color="\e[36;1m" ;;
    esac
    [[ $# -lt 2 ]] && echo -e "\e[36m\e[0m ${1}" || {
      echo -e "\e[36m\e[0m ${Color}${2}\e[0m"
    }
  }
}

[[ ! "$USER" == "root" ]] && {
  echo
  TIME y "警告：请使用root用户操作!~~"
  echo
  exit 1
}
