#!/usr/bin/env bash

clear

echo -e "\e[36m

      ___                                                  ___     
     /\  \          ___         ___         _____         /\__\    
     \:\  \        /\  \       /\__\       /::\  \       /:/  /    
      \:\  \       \:\  \     /:/__/      /:/\:\  \     /:/  /     
  _____\:\  \       \:\  \   /::\  \     /:/  \:\__\   /:/  /  ___ 
 /::::::::\__\  ___  \:\__\  \/\:\  \   /:/__/ \:|__| /:/__/  /\__\	
 \:\~~\~~\/__/ /\  \ |:|  |   ~~\:\  \  \:\  \ /:/  / \:\  \ /:/  /
  \:\  \       \:\  \|:|  |      \:\__\  \:\  /:/  /   \:\  /:/  / 
   \:\  \       \:\__|:|__|      /:/  /   \:\/:/  /     \:\/:/  /  
    \:\__\       \::::/__/      /:/  /     \::/  /       \::/  /   
     \/__/        ~~~~          \/__/       \/__/         \/__/    

-------------------------------版本2021.12.27---------------------------
------------------------------------------------------------------------
\e[0m\n"

#时间
echo "当前时间:" $(date +"%Y-%m-%d %H:%M:%S")
#等待3s
sleep 3

DOCKER_IMG_NAME="nolanhzy/nvjdc"
JD_PATH=""
SHELL_FOLDER=$(pwd)
CONTAINER_NAME=""
TAG="latest"
NETWORK="bridge"
JD_PORT=5701

HAS_IMAGE=false
PULL_IMAGE=true
HAS_CONTAINER=false
DEL_CONTAINER=true
INSTALL_WATCH=false
ENABLE_HANGUP=true
ENABLE_WEB_PANEL=true
OLD_IMAGE_ID=""


log() {
	echo -e "\e[32m\n$1 \e[0m\n"
}

inp() {
	echo -e "\e[33m\n$1 \e[0m\n"
}

opt() {
	echo -n -e "\e[36m输入您的选择->\e[0m"
}

warn() {
	echo -e "\e[31m$1 \e[0m\n"
}

cancelrun() {
	if [ $# -gt 0 ]; then
		echo -e "\e[31m $1 \e[0m"
	fi
	exit 1
}

unzip_install() {
	echo "检测 unzip......"
	if [ -x "$(command -v unzip)" ]; then
		echo "检测到 unzip 已安装!"
	else
		if [ -r /etc/os-release ]; then
			lsb_dist="$(. /etc/os-release && echo "$ID")"
		fi
		if [ $lsb_dist == "Ubuntu" ]; then
			echo "Ubuntu 安装 unzip"
			sudo apt-get install unzip -y
			echo "Ubuntu 安装 unzip安装完成!"
			exit 1
		else
			echo "群晖安装 unzip"
			ipkg install unzip
			echo "群晖安装 unzip安装完成!"
		fi
	fi
}

wget_install() {
	echo "检测 wget......"
	if [ -x "$(command -v wget)" ]; then
		echo "检测到 wget 已安装!"
	else
		if [ -r /etc/os-release ]; then
			lsb_dist="$(. /etc/os-release && echo "$ID")"
		fi
		if [ $lsb_dist == "Ubuntu" ]; then
			echo "Ubuntu 安装 wget"
			sudo apt-get install wget -y
			echo "Ubuntu 安装 git安装完成!"
			exit 1
		else
			echo "群晖安装 wget"
			ipkg install wget
			echo "群晖安装 wget安装完成!"
		fi
	fi
}


git_install() {
	echo "检测 git......"
	if [ -x "$(command -v git)" ]; then
		echo "检测到 git 已安装!"
	else
		if [ -r /etc/os-release ]; then
			lsb_dist="$(. /etc/os-release && echo "$ID")"
		fi
		if [ $lsb_dist == "Ubuntu" ]; then
			echo "Ubuntu 安装 git"
			sudo apt-get install git -y
			echo "Ubuntu 安装 git安装完成!"
			exit 1
		else
			echo "群晖安装 git"
			ipkg install git
			echo "群晖安装 git安装完成!"
		fi
	fi
	echo "禁用Git SSL验证"
	git config --global http.sslVerify false
}

docker_install() {
	echo "检测 Docker......"
	if [ -x "$(command -v docker)" ]; then
		echo "检测到 Docker 已安装!"
	else
		if [ -r /etc/os-release ]; then
			lsb_dist="$(. /etc/os-release && echo "$ID")"
		fi
		if [ $lsb_dist == "openwrt" ]; then
			echo "openwrt 环境请自行安装 docker"
			exit 1
		else
			echo "安装 docker 环境..."
			curl -fsSL https://get.docker.com | bash -s docker --mirror Aliyun
			echo "安装 docker 环境...安装完成!"
			systemctl enable docker
			systemctl start docker
		fi
	fi
}
unzip_install
wget_install
git_install
docker_install
warn "降低学习成本，小白回车到底，一路默认选择"
# 配置文件保存目录
echo -n -e "\e[33m一、请输入配置文件保存的绝对路径（示例：/root)，回车默认为当前目录:\e[0m"
read jd_path
if [ -z "$jd_path" ]; then
	JD_PATH=$SHELL_FOLDER
elif [ -d "$jd_path" ]; then
	JD_PATH=$jd_path
else
	mkdir -p $jd_path
	JD_PATH=$jd_path
fi

CONFIG_PATH=$JD_PATH/nolanjdc
APP_PATH=$JD_PATH/nolanjdc/Config

check_up_or_install() {
	# 检测镜像是否存在
	if [ ! -z "$(docker images -q $DOCKER_IMG_NAME:$TAG 2> /dev/null)" ]; then
		HAS_IMAGE=true
		OLD_IMAGE_ID=$(docker images -q --filter reference=$DOCKER_IMG_NAME:$TAG)
		inp "检测到先前已经存在的镜像."
		opt
	else
		inp "未检测到存在的镜像，请选择新装来拉取最新的镜像拉取。"
		cancelrun "** 错误：未检测到存在的镜像，请选择新装来拉取最新的镜像拉取。"
	fi
	# 检测容器是否存在
	check_container_name() {
		if [ ! -z "$(docker ps -a | grep $CONTAINER_NAME 2> /dev/null)" ]; then
			inp "检测到先前已经存在的容器，开始更新。"
			opt
			cd $CONFIG_PATH
			docker stop $CONTAINER_NAME
			git pull
			docker start $CONTAINER_NAME
			cancelrun "** 更新完成。"
		else
			inp "未检测到存在的容器，请检查存在错误。"
			cancelrun "** 错误：未检测到存在的容器，请检查存在错误。"
		fi
	}
	# 容器名称
	input_container_name() {
		echo -n -e "\e[33m\n升级容器的名称[默认为：nolanjdc]->\e[0m"
		read container_name
		if [ -z "$container_name" ]; then
			CONTAINER_NAME="nolanjdc"
		else
			CONTAINER_NAME=$container_name
		fi
		check_container_name
	}
	input_container_name
}
# 更新or安装 nolanjdc
inp "更新 nolanjdc 1.2以后 or 新装nolanjdc ：\n1) 更新\n2) 安装[默认]"
opt
read checkuporinstall
if [ "$checkuporinstall" = "1" ]; then
check_up_or_install
fi
# 检测镜像是否存在
if [ ! -z "$(docker images -q $DOCKER_IMG_NAME:$TAG 2> /dev/null)" ]; then
	HAS_IMAGE=true
	OLD_IMAGE_ID=$(docker images -q --filter reference=$DOCKER_IMG_NAME:$TAG)
	inp "检测到先前已经存在的镜像，是否拉取最新的镜像：\n1) 拉取[默认]\n2) 不拉取"
	opt
	read update
	if [ "$update" = "2" ]; then
		PULL_IMAGE=false
	fi
fi
# 检测容器是否存在
check_container_name() {
	if [ ! -z "$(docker ps -a | grep $CONTAINER_NAME 2> /dev/null)" ]; then
		HAS_CONTAINER=true
		inp "检测到先前已经存在的容器，是否删除先前的容器：\n1) 删除[默认]\n2) 不删除"
		opt
		read update
		if [ "$update" = "2" ]; then
			PULL_IMAGE=false
			inp "您选择了不删除之前的容器，需要重新输入容器名称"
			input_container_name
		fi
	fi
}

# 容器名称
input_container_name() {
	echo -n -e "\e[33m\n二、请输入要创建的 Docker 容器名称[默认为：nolanjdc]->\e[0m"
	read container_name
	if [ -z "$container_name" ]; then
		CONTAINER_NAME="nolanjdc"
	else
		CONTAINER_NAME=$container_name
	fi
	check_container_name
}
input_container_name

# 是否安装 WatchTower
inp "是否安装 containrrr/watchtower 自动更新 Docker 容器：\n1) 安装\n2) 不安装[默认](可以不装)"
opt
read watchtower
if [ "$watchtower" = "1" ]; then
	INSTALL_WATCH=true
fi

inp "请选择容器的网络类型：\n1) host\n2) bridge[默认]"
opt
read net
if [ "$net" = "1" ]; then
	NETWORK="host"
	MAPPING_JD_PORT=""
fi



# 端口问题
modify_nvjdc_port() {
	inp "是否修改NVJDC端口[默认 5701]：\n1) 修改\n2) 不修改[默认]"
	opt
	read change_nvjdc_port
	if [ "$change_nvjdc_port" = "1" ]; then
		echo -n -e "\e[36m输入您想修改的端口->\e[0m"
		read JD_PORT
	fi
}

if [ "$NETWORK" = "bridge" ]; then
	inp "是否映射端口：\n1) 映射[默认]\n2) 不映射"
	opt
	read port
	if [ "$port" = "2" ]; then
		MAPPING_JD_PORT=""
	else
		modify_nvjdc_port    fi
	fi


	# 是否拉库NVJDC
	if [ ! -f "$CONFIG_PATH/NETJDC.exe" ]; then
		log "检测到未拉库，请到$JD_PATH删除nolanjdc文件夹或按照下面拉库"
		log "检测到未拉库，请到$JD_PATH删除nolanjdc文件夹或按照下面拉库"
		log "检测到未拉库，请到$JD_PATH删除nolanjdc文件夹或按照下面拉库"
		log "检测到未拉库，请到$JD_PATH删除nolanjdc文件夹或按照下面拉库"
	fi
	inp "是否拉库NVJDC 拉过不用拉，第一次安装需要拉：\n1) 国内拉库（未拉过必须拉。）\n2) 国外拉库(未拉过必须拉。)\n3) 不拉库（拉过不要在拉。)[默认]"
	opt
	read gitenvjdc
	if [ "$gitenvjdc" = "1" ]; then
		log "开始拉国内库NVJDC https://ghproxy.com/https://github.com/NolanHzy/nvjdcdocker.git"
		git clone https://ghproxy.com/https://github.com/NolanHzy/nvjdcdocker.git $CONFIG_PATH
		log "拉库NVJDC完毕"
	fi
	if [ "$gitenvjdc" = "2" ]; then
		log "开始拉国外库NVJDC git clone https://github.com/NolanHzy/nvjdcdocker.git"
		git clone https://github.com/NolanHzy/nvjdcdocker.git $CONFIG_PATH
		log "拉库NVJDC完毕"
	fi
	log "跳过拉库"


	# 创建chromium
	inp "是否创建chromium,第一次运行必须创建：\n1) 创建\n2) 不创建[默认]"
	opt
	read chromium
	if [ "$chromium" = "1" ]; then
		cd $CONFIG_PATH
		wget https://mirrors.huaweicloud.com/chromium-browser-snapshots/Linux_x64/884014/chrome-linux.zip
		unzip $CONFIG_PATH/chrome-linux.zip
		mkdir -p $CONFIG_PATH/.local-chromium/Linux-884014
		cp $CONFIG_PATH/chrome-linux $CONFIG_PATH/.local-chromium/Linux-884014/ -r
		rm -f $CONFIG_PATH/chrome-linux.zip
		rm -rf $CONFIG_PATH/chrome-linux
		cd $CONFIG_PATH
	fi

	# 配置已经创建完成，开始执行
	log "1.开始创建配置文件目录"
	PATH_LIST=($CONFIG_PATH $APP_PATH)
	for i in ${PATH_LIST[@]}; do
		mkdir -p $i
	done

	if [ $HAS_CONTAINER = true ] && [ $DEL_CONTAINER = true ]; then
		log "2.1.删除先前的容器"
		docker stop $CONTAINER_NAME >/dev/null
		docker rm $CONTAINER_NAME >/dev/null
	fi

	if [ $HAS_IMAGE = true ] && [ $PULL_IMAGE = true ]; then
		if [ ! -z "$OLD_IMAGE_ID" ] && [ $HAS_CONTAINER = true ] && [ $DEL_CONTAINER = true ]; then
			log "2.2.删除旧的镜像"
			docker image rm $OLD_IMAGE_ID
		fi
		log "2.3.开始拉取最新的镜像"
		docker pull $DOCKER_IMG_NAME:$TAG
		if [ $? -ne 0 ] ; then
			cancelrun "** 错误：拉取不到镜像！"
		fi
	fi

	#检查文件是否存在
	if [ ! -f "$CONFIG_PATH/Config/Config.json" ]; then
		log "错误：找不到配置文件！系统自动生成默认配置到"$CONFIG_PATH/Config/Config.json"之后自己修改参数。"
		log "错误：找不到配置文件！系统自动生成默认配置到"$CONFIG_PATH/Config/Config.json"之后自己修改参数。"
		log "错误：找不到配置文件！系统自动生成默认配置到"$CONFIG_PATH/Config/Config.json"之后自己修改参数。"

		cat>>$CONFIG_PATH/Config/Config.json<<-EOF
			{
				///浏览器最多几个网页
				"MaxTab": "4",
				//网站标题
				"Title": "NolanJDCloud",
				//回收时间分钟 不填默认3分钟
				"Closetime": "5",
				//网站公告
				"Announcement": "为提高账户的安全性，请关闭免密支付。",
				///开启打印等待日志卡短信验证登陆 可开启 拿到日志群里回复 默认不要填写
				"Debug": "",
				///自动滑块次数5次 5次后手动滑块 可设置为0默认手动滑块
				"AutoCaptchaCount": "0",
				///XDD PLUS Url  http://IP地址:端口/api/login/smslogin
				"XDDurl": "",
				///xddToken
				"XDDToken": "",
				///登陆预警 0 0 12 * * ?  每天中午十二点 https://www.bejson.com/othertools/cron/ 表达式在线生成网址
				"ExpirationCron": " 0 0 12 * * ?",
				///个人资产 0 0 10,20 * * ?  早十点晚上八点
				"BeanCron": "0 0 10,20 * * ?",
				// ======================================= WxPusher 通知设置区域 ===========================================
				// 此处填你申请的 appToken. 官方文档：https://wxpusher.zjiecode.com/docs
				// WP_APP_TOKEN 可在管理台查看: https://wxpusher.zjiecode.com/admin/main/app/appToken
				// MainWP_UID 填你自己uid
				///这里的通知只用于用户登陆 删除 是给你的通知
				"WP_APP_TOKEN": "",
				"MainWP_UID": "",
				// ======================================= pushplus 通知设置区域 ===========================================
				///Push Plus官方网站：http" //www.pushplus.plus  只有青龙模式有用
				///下方填写您的Token，微信扫码登录后一对一推送或一对多推送下面的token，只填" "PUSH_PLUS_TOKEN",
				"PUSH_PLUS_TOKEN": "",
				//下方填写您的一对多推送的 "群组编码" ，（一对多推送下面->您的群组(如无则新建)->群组编码）
				"PUSH_PLUS_USER": "",
				///青龙配置  注意对接XDD 对接芝士 设置为"Config":[]
				"Config": [
				{
					//序号必填从1 开始
					"QLkey": 1,
					//服务器名称
					"QLName": "阿里云",
					//青龙地址
					"QLurl": "http://ip:5700",
					//青龙2,9 OpenApi Client ID
					"QL_CLIENTID": "",
					//青龙2,9 OpenApi Client Secret
					"QL_SECRET": "",
					//CK最大数量
					"QL_CAPACITY": 99,
					///建议一个青龙一个WxPusher 应用
					"WP_APP_TOKEN": ""
				}
				]
			}
			EOF
			#        cancelrun "** 错误：找不到配置文件！"
		fi

		# 端口存在检测
		check_port() {
			echo "正在检测端口:$1"
			netstat -tlpn | grep "\b$1\b"
		}
		if [ "$port" != "2" ]; then
			while check_port $JD_PORT; do
				echo -n -e "\e[31m端口:$JD_PORT 被占用，请重新输入NVJDC端口：\e[0m"
				read JD_PORT
			done
			echo -e "\e[34m恭喜，端口:$JD_PORT 可用\e[0m"
			MAPPING_JD_PORT="-p $JD_PORT:80"
		fi

		log "3.开始创建容器并执行"
		docker run -dit \
		-v $CONFIG_PATH:/app  \
		-v /etc/localtime:/etc/localtime:ro \
		$MAPPING_JD_PORT \
		--name $CONTAINER_NAME \
		--restart always \
		--network $NETWORK \
		-it --privileged=true  $DOCKER_IMG_NAME:$TAG


		if [ $? -ne 0 ] ; then
			cancelrun "** 错误：容器创建失败，请翻译以上英文报错，Google/百度尝试解决问题！"
		fi

		if [ $INSTALL_WATCH = true ]; then
			log "3.1.开始创建容器并执行"
			docker run -d \
			--name watchtower \
			--restart always \
			-v /var/run/docker.sock:/var/run/docker.sock \
			containrrr/watchtower -c\
			--schedule "13,14,15 3 * * * *" \
			$CONTAINER_NAME
		fi

		# 检查 config 文件是否存在
		#if [ ! -f "$CONFIG_PATH/config/config.json" ]; then
		#    docker cp $CONTAINER_NAME:/ql/sample/config.sample.sh $CONFIG_PATH/config.sh
		#    if [ $? -ne 0 ] ; then
		#        cancelrun "** 错误：找不到配置文件！"
		#    fi
		#fi
		log "4.下面列出所有容器"
		docker ps


		# 防止 CPU 占用过高导致死机
		echo -e "-------- 等待一会让NVJDC启动一下 --------"
		sleep 5

	else
		exit 0
		fi
