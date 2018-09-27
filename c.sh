#!/bin/bash

#====================================================
#	System Request: Debian 8+
#	Author: dylanbai8
#	Dscription: 小内存VPS 一键安装 Caddy+PHP7+Sqlite3 环境 一键绑定域名生成SSL证书
#	Blog: https://oo0.bid
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

typecho_path="https://github.com/typecho/typecho/releases/download/v1.1-17.10.30-release/1.1.17.10.30.-release.tar.gz"

kodcloud_path="https://github.com/kalcaddle/KodExplorer/archive/4.35.tar.gz"

wordpress_path="https://wordpress.org/latest.tar.gz"
wordpress_sqlite="https://downloads.wordpress.org/plugin/sqlite-integration.1.8.1.zip"

zblog_path="https://github.com/zblogcn/zblogphp/archive/1740.tar.gz"

source /etc/os-release

#脚本欢迎语
install_hello(){
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
domain_set(){
	echo -e "${Info} ${GreenBG} 【配置 1/3 】请输入你的域名信息(如:www.bing.com)，请确保域名A记录（或AAAA记录）已正确解析至服务器IP ${Font}"
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
	apt -y install bc unzip

	systemctl disable caddy >/dev/null 2>&1
	systemctl stop caddy >/dev/null 2>&1
	killall -9 caddy >/dev/null 2>&1


	rm -rf /www >/dev/null 2>&1
	rm -rf /usr/local/bin/caddy /etc/caddy /etc/systemd/system/caddy.service >/dev/null 2>&1
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

default_html(){
	rm -rf /www
	mkdir /www
	touch /www/index.php
	cat <<EOF > /www/index.php
启动：/etc/init.d/caddy start<br>
停止：/etc/init.d/caddy stop<br>
重启：/etc/init.d/caddy restart<br>
查看状态：/etc/init.d/caddy status<br>
查看Caddy启动日志：tail -f /tmp/caddy.log<br>
安装目录：/usr/local/caddy<br>
Caddy配置文件位置：/usr/local/caddy/Caddyfile<br>
网站根目录 /www
EOF

	judge "生成默认首页"

}



#生成caddy配置文件
caddy_conf_add(){
	mkdir ${caddy_conf_dir}
	touch ${caddy_conf_dir}/Caddyfile
	cat <<EOF > ${caddy_conf_dir}/Caddyfile
http://domain:port1 {
    redir https://domain:port2{url}
}
https://domain:port2 {
    gzip
    tls admin@domain
    root /www
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
	sed -i "s/port1/${port1}/g" "${caddy_conf}"
	sed -i "s/port2/${port2}/g" "${caddy_conf}"
	sed -i "s/domain/${domain}/g" "${caddy_conf}"
}



#检查ssl证书是否生成
check_ssl(){
	echo -e "${OK} ${GreenBG} 正在等待域名证书生成 ${Font}"
	sleep 8
if [[ -e /root/.caddy/acme/acme-v02.api.letsencrypt.org/sites/${domain}/${domain}.key ]]; then
	echo -e "${OK} ${GreenBG} SSL证书申请 成功 ${Font}"
else
	echo -e "${Error} ${RedBG} SSL证书申请 失败 请确认是否超出Let’s Encrypt申请次数或检查服务器网络 ${Font}"
	echo -e "${Error} ${RedBG} 注意：证书每个IP每3小时10次 7天内每个子域名不超过5次总计不超过20次 ${Font}"
	exit 1
fi
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
	echo -e "${Green} 网站目录：/www"
	
	echo -e "----------------------------------------------------------"
}

#重启caddy和v2ray程序 加载配置
start_process_systemd(){

	systemctl enable caddy >/dev/null 2>&1
	systemctl restart caddy
	judge "caddy 启动"

}

#安装web伪装站点
typecho_install(){
echo -e "${OK} ${GreenBG} 安装Website伪装站点 ${Font}"
rm -rf /www
mkdir /www

wget -N --no-check-certificate ${typecho_path} -O typecho.tar.gz
tar -zxvf typecho.tar.gz -C /www
mv /www/*build*/* /www
rm -rf /www/*build*
rm -rf typecho.tar.gz

chmod -R 777 /www/
chmod -R 755 /www/*
chown www-data:www-data -R /www/*
echo -e "${OK} ${GreenBG} 操作已完成 ${Font}"

}


#安装web伪装站点
kodexplorer_install(){
echo -e "${OK} ${GreenBG} 安装Website伪装站点 ${Font}"
rm -rf /www
mkdir /www

wget -N --no-check-certificate ${kodcloud_path} -O kodcloud.tar.gz
tar -zxvf kodcloud.tar.gz -C /www
mv /www/*KodExplorer*/* /www
rm -rf /www/*KodExplorer*
rm -rf kodcloud.tar.gz

chmod -R 777 /www/
chmod -R 755 /www/*
chown www-data:www-data -R /www/*
echo -e "${OK} ${GreenBG} 操作已完成 ${Font}"

}



#安装web伪装站点
wordpress_install(){
echo -e "${OK} ${GreenBG} 安装Website伪装站点 ${Font}"
rm -rf /www
mkdir /www

wget -N --no-check-certificate ${wordpress_path} -O wordpress.tar.gz
tar -zxvf wordpress.tar.gz -C /www
mv /www/wordpress/* /www
rm -rf /www/wordpress
rm -rf wordpress.tar.gz

chmod -R 777 /www/
chmod -R 755 /www/*
chown www-data:www-data -R /www/*

wget -N --no-check-certificate ${wordpress_sqlite} -O sqlite.zip
unzip sqlite.zip -d /www
mv /www/wp-config-sample.php /www/wp-config.php
mv /www/sqlite-integration /www/wp-content/plugins/
mv /www/wp-content/plugins/sqlite-integration/db.php /www/wp-content/
sed -i "s/define('DB_COLLATE', '');/define('DB_TYPE', 'sqlite');/g" /www/wp-config.php
rm -rf sqlite.zip

echo -e "${OK} ${GreenBG} 操作已完成 ${Font}"

}


#安装web伪装站点
zblog_install(){
echo -e "${OK} ${GreenBG} 安装Website伪装站点 ${Font}"
rm -rf /www
mkdir /www

wget -N --no-check-certificate ${zblog_path} -O zblog.tar.gz
tar -zxvf zblog.tar.gz -C /www
mv /www/*zblog*/* /www
rm -rf /www/*zblog*
rm -rf zblog.tar.gz

chmod -R 777 /www/
chmod -R 755 /www/*
chown www-data:www-data -R /www/*

echo -e "${OK} ${GreenBG} 操作已完成 ${Font}"

}


bak_www(){
rm -rf /www/www.zip
apt -y install zip
zip -q -r /www/www.zip /www
echo -e "${OK} ${GreenBG} 操作已完成 ${Font}"
echo -e "${OK} ${GreenBG} 下载地址为：https:\\域名\www.zip ${Font}"

}

#命令块执行列表
main(){
	is_root
	check_system
	install_hello
	domain_set
	apache_uninstall
	domain_check
	port_exist_check ${port1}
	port_exist_check ${port2}
	php_sqlite_install
	caddy_install
	default_html
	caddy_conf_add
	check_ssl
	show_information
	start_process_systemd
}




#Bash执行选项
if [[ $# > 0 ]];then
	key="$1"
	case $key in
		-t|--typecho_install)
		typecho_install
		;;
		-k|--kodexplorer_install)
		kodexplorer_install
		;;
		-w|--wordpress_install)
		wordpress_install
		;;
		-z|--zblog_install)
		zblog_install
		;;
	esac
else
	main
fi



