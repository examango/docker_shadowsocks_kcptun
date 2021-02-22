#!/bin/bash

set -e

echo '连接服务器 : 停止docker'
ssh -t -t {{var_user}}@{{var_ip}} <<EOF
docker stop $(docker ps -q) & docker rm $(docker ps -aq)
exit
EOF

echo '生成docker-compose.yml'
/bin/bash gen.sh

echo '上传docker-compose.yml'
scp docker-compose.yml {{var_user}}@{{var_ip}}:{{var_dir_cache}}
echo '上传.env'
scp .env {{var_user}}@{{var_ip}}:{{var_dir_cache}}

echo '连接服务器 : 启动docker'
ssh -t -t {{var_user}}@{{var_ip}} <<EOF
cd {{var_dir_cache}}
docker-compose up -d
exit
EOF

echo '操作完成'
