docker_shadowsocks_kcptun
===
无镜像，使用`docker-compose`启动。

## 本地环境需求

需要安装`jq`，mac系统使用`brew install jq`即可，其他系统未知。

## vps服务器安装docker

参考[Install Docker Engine on CentOS](https://docs.docker.com/engine/install/centos/)安装docker。

参考[Install Docker Compose](https://docs.docker.com/compose/install/)安装docker-compose。

在用户目录下的.bash_profile文件中增加变量

* export DOCKER_CLIENT_TIMEOUT=120
* export COMPOSE_HTTP_TIMEOUT=120

值得注意的是，如果在国内服务器搭建的话，需要用[腾讯软件源](https://mirrors.cloud.tencent.com/)中的`docker-ce.repo`地址替代官网文档中`docker-ce.repo`的地址。

## 命令

### 设置docker跟随系统启动

`sudo systemctl enable docker`

### 重启docker

`sudo systemctl restart docker`

### 进入容器

`docker exec -it {{container name}} /bin/sh`

### 关闭并删除所有容器

`docker stop $(docker ps -q) & docker rm $(docker ps -aq)`

### 关闭所有容器

`docker stop $(docker ps -a | awk '{ print $1}' | tail -n +2)`

### 删除所有容器

`docker rm $(docker ps -a | awk '{ print $1}' | tail -n +2)`

## 文件说明

文件里面有需要替换的变量，统一格式为：`{{var_xx}}`

### docker-compose.yml

该文件不用手动填写以及更改，由`gen.sh`脚本根据`config.json`配置生成。

### gen.sh

生成脚本，该脚本根据`config.json`配置生成`docker-compose.yml`文件。

该脚本内部没有需要替换的变量。

一般不需要修改。

### config.json

配置文件，手动填写。shadowsocks和kcptun的参数配置文件。

以json格式组织shadowsocks和kcptun的参数，data字段中，数组的每一项都会启动两个docker服务，分别对应shadowsocks和kcptun。

* `var_port` : shadowsocks端口；
* `var_pwd` : shadowsocks密码；
* `var_kcptun_port` : kcptun端口；
* `var_kcptun_pwd` : kcptun密码；
* `var_method` : shadowsocks启动参数中的`-m`，可有可无，参见`.env文件`文件中的`var_ss_method`变量；
* `var_own` : 注释，显示该配置是谁在使用；

当然，可以在该文件新增shadowsocks和kcptun的其他任意参数。需对应修改`gen.sh`文件。

### .env

配置文件，手动填写。docker-compose的环境配置文件，配置shadowsocks和kcptun公用的参数。

docker-compose在启动docker服务的时候，会读取同一目录下的`.env`文件。`.env`文件内设置的环境变量，可在`docker-compose.yml`中使用，所以需要把`docker-compose.yml`
和`.env`文件都上传到vps服务器。

* `var_ip` : vps服务器公网IP；
* `var_ss_method` : shadowsocks启动参数中的`-m`，如果不在`config.json`配置中指明特定的加密方法，则使用该环境文件配置的指定方法；
* `var_kcp_mode` : kcptun启动参数中的`--mode`；

当然，可以在该文件新增shadowsocks和kcptun的其他任意参数。需对应修改`gen.sh`文件。

### upload.sh

上传脚本，上传并启动。

* `var_user` : vps服务器用户；
* `var_ip` : vps服务器公网IP；
* `var_dir_cache` : vps服务器上的缓存目录，因为要把`docker-compose.yml`和`.env`文件上传到vps服务器；

## 注意事项

* kcp插件选项`key=[密码，不含分号;];mode=fast3;`
* 需要安装`jq`