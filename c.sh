#!/bin/bash

#====================================================
#	System Request:Debian 7+/Ubuntu 15+/Centos 6+
#	Author: wulabing & dylanbai8
#	Dscription: V2RAY 基于 CADDY 的 VMESS+H2+TLS+Website(Use Host)+Rinetd BBR
#	Blog: https://www.wulabing.com https://oo0.bid
#	Official document: www.v2ray.com
#====================================================

#定义文字颜色
Green="\033[32m"
Red="\033[31m"
GreenBG="\033[42;37m"
RedBG="\033[41;37m"
Font="\033[0m"

#定义提示信息
Info="${Green}[信息]${Font}"
OK="${Green}[OK]${Font}"
Error="${Red}[错误]${Font}"

#定义配置文件路径
caddy_conf_dir="/etc/caddy"
caddy_conf="${caddy_conf_dir}/Caddyfile"

port1="80"
port2="443"
www_root="/www"
typecho_path="https://github.com/typecho/typecho/releases/download/v1.1-17.10.30-release/1.1.17.10.30.-release.tar.gz"

source /etc/os-release

#脚本欢迎语
v2ray_hello(){
	echo ""
	echo -e "${Info} ${GreenBG} 你正在执行 小内存VPS 一键安装 Caddy+PHP7+Sqlite3+Domain_ssl 环境 脚本 ${Font}"
	echo ""
}



#检测root权限
is_root(){
	if [ `id -u` == 0 ]
		then echo -e "${OK} ${GreenBG} 当前用户是root用户，开始安装流程 ${Font}"
		sleep 3
	else
		echo -e "${Error} ${RedBG} 当前用户不是root用户，请切换到root用户后重新执行脚本 ${Font}"
		exit 1
	fi
}

#检测系统版本
check_system(){
	VERSION=`echo ${VERSION} | awk -F "[()]" '{print $2}'`

	if [[ "${ID}" == "debian" && ${VERSION_ID} -ge 8 ]];then
		echo -e "${OK} ${GreenBG} 当前系统为 Debian ${VERSION_ID} ${VERSION} ${Font}"
		INS="apt"
	else
		echo -e "${Error} ${RedBG} 当前系统为 ${ID} ${VERSION_ID} 不在支持的系统列表内，安装中断 ${Font}"
		exit 1
	fi
}

#检测安装完成或失败
judge(){
	if [[ $? -eq 0 ]];then
		echo -e "${OK} ${GreenBG} $1 完成 ${Font}"
		sleep 1
	else
		echo -e "${Error} ${RedBG} $1 失败 ${Font}"
		exit 1
	fi
}

#用户设定 域名 端口 alterID
port_alterid_set(){
	echo -e "${Info} ${GreenBG} 【配置 1/3 】请输入你的域名信息(如:www.bing.com)，请确保域名A记录已正确解析至服务器IP ${Font}"
	stty erase '^H' && read -p "请输入：" domain

	echo -e "----------------------------------------------------------"
	echo -e "${Info} ${GreenBG} 你输入的配置信息为 域名：${domain}"
	echo -e "----------------------------------------------------------"
}

#强制清除可能残余的http服务 v2ray服务 关闭防火墙 更新源
apache_uninstall(){
	echo -e "${OK} ${GreenBG} 正在强制清理可能残余的http服务 ${Font}"

	systemctl disable apache2 >/dev/null 2>&1
	systemctl stop apache2 >/dev/null 2>&1
	apt purge apache2 -y >/dev/null 2>&1

	echo -e "${OK} ${GreenBG} 正在更新源 请稍后 …… ${Font}"

	apt -y update


	systemctl disable caddy >/dev/null 2>&1
	systemctl stop caddy >/dev/null 2>&1

	systemctl disable rinetd-bbr >/dev/null 2>&1
	systemctl stop rinetd-bbr >/dev/null 2>&1
	killall -9 rinetd-bbr >/dev/null 2>&1

	rm -rf /www >/dev/null 2>&1
	rm -rf /usr/local/bin/caddy /etc/caddy /etc/systemd/system/caddy.service >/dev/null 2>&1

	rm -rf /usr/bin/rinetd-bbr /etc/rinetd-bbr.conf /etc/systemd/system/rinetd-bbr.service >/dev/null 2>&1
}



#检测域名解析是否正确
domain_check(){
	domain_ip=`ping ${domain} -c 1 | sed '1{s/[^(]*(//;s/).*//;q}'`
	echo -e "${OK} ${GreenBG} 正在获取 公网ip 信息，请耐心等待 ${Font}"
	local_ip=`curl -4 ip.sb`
	echo -e "${OK} ${GreenBG} 域名dns解析IP：${domain_ip} ${Font}"
	echo -e "${OK} ${GreenBG} 本机IP: ${local_ip} ${Font}"
	sleep 2
	if [[ $(echo ${local_ip}|tr '.' '+'|bc) -eq $(echo ${domain_ip}|tr '.' '+'|bc) ]];then
		echo -e "${OK} ${GreenBG} 域名dns解析IP  与 本机IP 匹配 域名解析正确 ${Font}"
		sleep 2
	else
		echo -e "${Error} ${RedBG} 域名dns解析IP 与 本机IP 不匹配 是否继续安装？（y/n）${Font}" && read install
		case $install in
		[yY][eE][sS]|[yY])
			echo -e "${GreenBG} 继续安装 ${Font}"
			sleep 2
			;;
		*)
			echo -e "${RedBG} 安装终止 ${Font}"
			exit 2
			;;
		esac
	fi
}

#检测端口是否占用
port_exist_check(){
	if [[ 0 -eq `lsof -i:"$1" | wc -l` ]];then
		echo -e "${OK} ${GreenBG} $1 端口未被占用 ${Font}"
		sleep 1
	else
		echo -e "${Error} ${RedBG} 检测到 $1 端口被占用，以下为 $1 端口占用信息 ${Font}"
		lsof -i:"$1"
		echo -e "${OK} ${GreenBG} 5s 后将尝试自动 kill 占用进程 ${Font}"
		sleep 5
		lsof -i:"$1" | awk '{print $2}'| grep -v "PID" | xargs kill -9
		echo -e "${OK} ${GreenBG} kill 完成 ${Font}"
		sleep 1
	fi
}


#安装 PHP7 和 Sqlite3
php_sqlite_install(){
#Debian 8系统
#添加源
echo "deb http://packages.dotdeb.org jessie all" | tee --append /etc/apt/sources.list
echo "deb-src http://packages.dotdeb.org jessie all" | tee --append /etc/apt/sources.list
#添加key
wget --no-check-certificate https://www.dotdeb.org/dotdeb.gpg
apt-key add dotdeb.gpg
#更新系统
apt-get update -y
#安装PHP 7和Sqlite 3
apt-get install php7.0-cgi php7.0-fpm php7.0-curl php7.0-gd php7.0-mbstring php7.0-xml php7.0-sqlite3 sqlite3 -y

#Debian 9系统
#更新系统
apt-get update -y
#安装PHP 7和Sqlite 3
apt-get install php7.0-cgi php7.0-fpm php7.0-curl php7.0-gd php7.0-mbstring php7.0-xml php7.0-sqlite3 sqlite3 -y
}

#安装caddy主程序
caddy_install(){
	curl https://getcaddy.com | bash -s personal

	touch /etc/systemd/system/caddy.service
	cat <<EOF > /etc/systemd/system/caddy.service
[Unit]
Description=Caddy server
[Service]
ExecStart=/usr/local/bin/caddy -conf=/etc/caddy/Caddyfile -agree=true -ca=https://acme-v02.api.letsencrypt.org/directory
Restart=always
User=root
[Install]
WantedBy=multi-user.target
EOF

judge "caddy 安装"
}





#生成caddy配置文件
caddy_conf_add(){
	mkdir ${caddy_conf_dir}
	touch ${caddy_conf_dir}/Caddyfile
	cat <<EOF > ${caddy_conf_dir}/Caddyfile
http://moerats.com {
    redir https://www.moerats.com{url}
    }
    https://www.moerats.com {
    gzip
    tls admin@moerats.com
    root /typecho
    fastcgi / /run/php/php7.0-fpm.sock php
    rewrite {
        if {path} not_match ^\/admin
        to {path} {path}/ /index.php?{query}
     }
}
EOF

	modify_caddy
	judge "caddy 配置"

	systemctl daemon-reload
	systemctl start caddy
}



#修正caddy配置配置文件
modify_caddy(){
	sed -i "s/SETPORT443/${port}/g" "${caddy_conf}"
	sed -i "s/SETPORTV/${PORT}/g" "${caddy_conf}"
	sed -i "s/SETPATH/${v2raypath}/g" "${caddy_conf}"
	sed -i "s/SETSERVER/${domain}/g" "${caddy_conf}"
}



#检查ssl证书是否生成
check_ssl(){
	echo -e "${OK} ${GreenBG} 正在等待域名证书生成 ${Font}"
	sleep 5
if [[ -e /root/.caddy/acme/acme-v02.api.letsencrypt.org/sites/${domain}/${domain}.key ]]; then
	echo -e "${OK} ${GreenBG} SSL证书申请 成功 ${Font}"
else
	echo -e "${Error} ${RedBG} SSL证书申请 失败 请确认是否超出Let’s Encrypt申请次数或检查服务器网络 ${Font}"
	echo -e "${Error} ${RedBG} 注意：证书每个IP每3小时10次 7天内每个子域名不超过5次总计不超过20次 ${Font}"
	exit 1
fi
}

#重启caddy和v2ray程序 加载配置
start_process_systemd(){
	systemctl enable v2ray >/dev/null 2>&1
	systemctl enable caddy >/dev/null 2>&1

	systemctl restart caddy
	judge "caddy 启动"

	systemctl start v2ray
	judge "V2ray 启动"
}

#展示客户端配置信息
show_information(){
	clear
	echo ""
	echo -e "${Info} ${GreenBG} 小内存 VPS 安装 Caddy+PHP7+Sqlite3 环境一键脚本 安装成功 ${Font}"
	echo -e "----------------------------------------------------------"
	echo -e "${Green} 启动：/etc/init.d/caddy start"
	echo -e "${Green} 停止：/etc/init.d/caddy stop"
	echo -e "${Green} 重启：/etc/init.d/caddy restart"
	echo -e "${Green} 查看状态：/etc/init.d/caddy status"
	echo -e "${Green} 查看Caddy启动日志：tail -f /tmp/caddy.log"
	echo -e "${Green} caddy安装目录：/usr/local/caddy"
	echo -e "${Green} Caddy配置文件位置：/usr/local/caddy/Caddyfile"
	echo ""
	echo -e "${Green} 网站首页：https://${domain}"
	echo -e "${Green} 网站目录：https://${domain}"
	
	echo -e "----------------------------------------------------------"
}

#命令块执行列表
main(){
	is_root
	check_system
	v2ray_hello
	port_alterid_set
	apache_uninstall
	dependency_install
	domain_check
	port_exist_check 80
	port_exist_check ${port}
	time_modify
	v2ray_install
	modify_crontab
	caddy_install
	web_install
	v2ray_conf_add
	caddy_conf_add
	user_config_add
	rinetdbbr_install
	win64_v2ray
	check_ssl
	show_information
	start_process_systemd
}




#Bash执行选项
if [[ $# > 0 ]];then
	key="$1"
	case $key in
		-r|--rm_userjson)
		rm_userjson
		;;
		-n|--new_uuid)
		new_uuid
		;;
		-s|--add_share)
		add_share
		;;
		-m|--share_uuid)
		share_uuid
		;;
		-x|--add_xmr)
		add_xmr
		;;
	esac
else
	main
fi


#安装web伪装站点
web_install(){
	echo -e "${OK} ${GreenBG} 安装Website伪装站点 ${Font}"

mkdir /typecho && cd /typecho
#以下为最新稳定版
wget http://typecho.org/downloads/1.1-17.10.30-release.tar.gz
tar zxvf 1.1*
mv ./build/* ./
rm -rf 1.1* buil*
chmod -R 755 ./*
chown www-data:www-data -R ./*

}

