#!/bin/bash

json=$(cat config.json)
#echo "json数据 : $json"
list=$(echo "$json" | jq '.data')
#echo "data数据 : $list"

len=$(echo "$list" | jq '.|length')
#echo "data数据长度 : $len"

#echo '写入docker-compose.yml : 头部'
echo "\
version: \"3.3\"
services:" >docker-compose.yml

#echo '开始遍历'
for index in $(seq 1 "$len"); do
  item=$(echo "$list" | jq ".[$index-1]")
  #	echo "索引:$index"
  #	echo "内容:$item"
  port=$(echo "$item" | jq -r'.port')
  pwd=$(echo "$item" | jq -r '.pwd')
  kcptun_port=$(echo "$item" | jq -r'.kcptun_port')
  kcptun_pwd=$(echo "$item" | jq -r '.kcptun_pwd')
  method=$(echo "$item" | jq -r '.method')
  if [ "$method" = 'null' ]; then
    method="\${METHOD}"
  fi
  own=$(echo "$item" | jq -r '.own')
  echo "\
  # user : $own
  '$port':
    image: shadowsocks/shadowsocks-libev
    ports:
      - \"$port:$port\"
    environment:
      - SERVER_PORT=$port
      - METHOD=$method
      - PASSWORD=$pwd
    restart: always
  '$port-$kcptun_port.kcptun':
    image: xtaci/kcptun
    ports:
      - \"$kcptun_port:$kcptun_port/udp\"
    command: server -t \${IP}:$port -l :$kcptun_port -key $kcptun_pwd -mode \${MODE}
    depends_on:
      - \"$port\"
    restart: always" >>docker-compose.yml
  #	echo "写入索引($index)数据成功"
done
#echo '结束遍历'
