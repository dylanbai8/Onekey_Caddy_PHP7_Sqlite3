#!/bin/bash

#====================================================
#	System Request: Centos 7+ Debian 8+
#	Author: dylanbai8
#	* 小内存VPS 一键安装 Caddy+PHP7+Sqlite3 环境 （支持VPS最小内存64M）
#	* 一键绑定域名自动生成SSL证书开启https（ssl自动续期）、支持IPv6
#	* 一键安装 typecho、wordpress、zblog、kodexplorer、laverna、一键整站备份
#	* 一键安装 v2ray、rinetdbbr
#	* 经典组合 [Website(caddy+php7+sqlite3+tls)+V2ray(vmess+websocket)]use_path+Rinetdbbr
#	* 推荐系统：Debian 8 （建议选择mini版）
#	* 开源地址：https://github.com/dylanbai8/Onekey_Caddy_PHP7_Sqlite3
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
Default_dir(){
conf_dir="/etc/dylanbai8"
}

Default_caddy(){
caddy_conf_dir="${conf_dir}/caddy"
caddy_conf="${caddy_conf_dir}/Caddyfile"
}

Default_v2ray(){
v2ray_conf_dir="${conf_dir}/v2ray"
v2ray_conf="${v2ray_conf_dir}/config.json"
}

Default_rinetdbbr(){
rinetdbbr_conf_dir="${conf_dir}/rinetdbbr"
rinetdbbr_conf="${rinetdbbr_conf_dir}/config.conf"
rinetdbbr_url="https://github.com/dylanbai8/Onekey_Caddy_PHP7_Sqlite3/raw/master/bbr"
}

win64_source(){
bat_url="https://raw.githubusercontent.com/dylanbai8/Onekey_Caddy_PHP7_Sqlite3/master/zip"
}

#80端口用于签发验证ssl证书
port1="80"
#端口port2可自定义
port2="443"

# alterId值越小越省内存
alterId="8"
#用于websocket分流的随机端口
let port3=$RANDOM+10000

source /etc/os-release


# 网站源码下载地址 如失效可自行修改或自定义版本
# ====================================

wwwroot="/www"

# https://github.com/typecho/typecho/releases
typecho_path="https://github.com/typecho/typecho/releases/download/v1.1-17.10.30-release/1.1.17.10.30.-release.tar.gz"

# https://github.com/kalcaddle/KodExplorer/releases
kodcloud_path="https://github.com/kalcaddle/KodExplorer/archive/4.35.tar.gz"

wordpress_path="https://wordpress.org/latest.tar.gz"
# https://github.com/jumpstarter-io/wp-sqlite-integration
wordpress_sqlite="https://downloads.wordpress.org/plugin/sqlite-integration.1.8.1.zip"

# https://github.com/zblogcn/zblogphp/releases
zblog_path="https://github.com/zblogcn/zblogphp/archive/1740.tar.gz"

# https://github.com/Laverna/static-laverna
laverna_path="https://github.com/Laverna/static-laverna/archive/gh-pages.zip"

# ====================================


#脚本欢迎语
install_hello(){
Default_dir
if [[ -e ${conf_dir} ]]; then

	clear
	echo ""
	echo -e "${Error} ${RedBG} 检测到你已安装环境 请勿重复执行 ${Font}"
	echo -e "----------------------------------------------------------"
	echo ""
	echo -e "${Green} 一键安装 typecho 博客：${Font} bash c.sh -t"
	echo -e "${Green} 一键安装 wordpress 博客：${Font} bash c.sh -w"
	echo -e "${Green} 一键安装 zblog 博客：${Font} bash c.sh -z"
	echo -e "${Green} 一键安装 kodexplorer 可道云：${Font} bash c.sh -k"
	echo -e "${Green} 一键安装 laverna 印象笔记：${Font} bash c.sh -l"
	echo -e "${Green} 一键整站备份：${Font} bash c.sh -a"
	echo -e "${Green} 一键安装 v2ray 翻墙：${Font} bash c.sh -v"
	echo -e "${Green} 一键安装 rinetd bbr 端口加速：${Font} bash c.sh -b"
	echo ""
	echo -e "${Green} 一键卸载 caddy：${Font} bash c.sh -unc"
	echo -e "${Green} 一键卸载 php+sqlite：${Font} bash c.sh -unp"
	echo -e "${Green} 一键卸载 v2ray：${Font} bash c.sh -unv"
	echo -e "${Green} 一键卸载 rinetdbbr：${Font} bash c.sh -unb"
	echo ""
	echo -e "${Green} 提示：如果在上次执行中由于错误而中断了安装，请先执行 一键卸载 caddy ${Font}"
	echo ""
	echo -e "----------------------------------------------------------"
	exit 1

else

	clear
	echo ""
	echo -e "${Info} ${GreenBG} 你正在执行 小内存VPS Caddy+PHP7+Sqlite3 环境（支持VPS最小内存64M）一键安装脚本 ${Font}"

fi
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


#更新源
add_source7(){
echo -e "${OK} ${GreenBG} 正在为 Centos7 更新源 ${Font}"
setsebool -P httpd_can_network_connect 1 >/dev/null 2>&1
${INS} update -y
${INS} install curl -y
${INS} install epel-release -y
rpm -Uvh https://mirror.webtatic.com/yum/el7/webtatic-release.rpm
${INS} update -y
}

add_source8(){
echo -e "${OK} ${GreenBG} 正在为 Debian8 更新源 ${Font}"
${INS} update -y
${INS} install curl -y
curl https://www.dotdeb.org/dotdeb.gpg | apt-key add -
echo "deb http://packages.dotdeb.org jessie all" >> /etc/apt/sources.list
echo "deb-src http://packages.dotdeb.org jessie all" >> /etc/apt/sources.list
${INS} update -y
}

add_source9(){
echo -e "${OK} ${GreenBG} 正在为 Debian9 更新源 ${Font}"
${INS} update -y
${INS} install curl -y
}


#检测系统版本
check_system(){
	VERSION=`echo ${VERSION} | awk -F "[()]" '{print $2}'`

	if [[ "${ID}" == "centos" && ${VERSION_ID} -ge 7 ]];then
		echo -e "${OK} ${GreenBG} 当前系统为 Centos ${VERSION_ID} ${VERSION} ${Font}"
		add_source="add_source7"
		INS="yum"
		UNS="erase"
	elif [[ "${ID}" == "debian" && ${VERSION_ID} -ge 8 && ${VERSION_ID} -lt 9 ]];then
		echo -e "${OK} ${GreenBG} 当前系统为 Debian ${VERSION_ID} ${VERSION} ${Font}"
		add_source="add_source8"
		INS="apt"
		UNS="purge"
	elif [[ "${ID}" == "debian" && ${VERSION_ID} -ge 9 ]];then
		echo -e "${OK} ${GreenBG} 当前系统为 Debian ${VERSION_ID} ${VERSION} ${Font}"
		add_source="add_source9"
		INS="apt"
		UNS="purge"
	else
		echo -e "${Error} ${RedBG} 当前系统为 ${ID} ${VERSION_ID} 不在支持的系统列表内，脚本终止继续安装 ${Font}"
		exit 1
	fi
}


#检测依赖
systemd_chack(){
echo -e "${OK} ${GreenBG} 正在检测是否支持 systemd ${Font}"
	for CMD in iptables grep cut xargs systemctl ip awk
	do
		if ! type -p ${CMD}; then
			echo -e "${Error} ${RedBG} 系统过度精简 缺少必要依赖 脚本终止继续安装 ${Font}"
			exit 1
		fi
	done
	echo -e "${OK} ${GreenBG} 符合安装条件 ${Font}"
}


#检测安装完成或失败
judge(){
	if [[ $? -eq 0 ]];then
		echo -e "${OK} ${GreenBG} $1 完成 ${Font}"
		sleep 1
	else
		echo -e "${Error} ${RedBG} $1 失败 ${Font}"
		echo -e "${Info} ${GreenBG} 脚本终止继续安装 反馈地址：https://git.io/issues4c.sh ${Font}"
		exit 1
	fi
}


#设定域名
domain_set(){
	echo -e "${Info} ${GreenBG} 请输入你的域名信息(如:www.bing.com)，请确保域名A记录（或AAAA记录）已正确解析至服务器IP（支持IPv6）${Font}"
	stty erase '^H' && read -e -p "请输入：" domain
	[[ -z ${domain} ]] && domain="none"
	if [ "${domain}" = "none" ];then
		domain_set
	else
	echo -e "${OK} ${GreenBG} 你设置的域名为：${domain} ${Font}"

	Default_dir
	mkdir ${conf_dir} >/dev/null 2>&1
	touch ${conf_dir}/domain.txt
	cat <<EOF > ${conf_dir}/domain.txt
${domain}
EOF
	touch ${conf_dir}/port2.txt
	cat <<EOF > ${conf_dir}/port2.txt
${port2}
EOF
	touch ${conf_dir}/port3.txt
	cat <<EOF > ${conf_dir}/port3.txt
${port3}
EOF
	v2ray_path=`cat /dev/urandom | head -n 10 | md5sum | head -c 8`
	touch ${conf_dir}/v2ray_path.txt
	cat <<EOF > ${conf_dir}/v2ray_path.txt
${v2ray_path}
EOF
	fi
}


#卸载caddy
uninstall_caddy(){
Default_dir
Default_caddy
check_system

echo -e "${OK} ${GreenBG} 正在卸载 caddy 请稍后 ... ${Font}"
systemctl disable caddy >/dev/null 2>&1
systemctl stop caddy >/dev/null 2>&1
killall -9 caddy >/dev/null 2>&1

rm -rf /usr/local/bin/caddy >/dev/null 2>&1
rm -rf ${caddy_conf_dir} >/dev/null 2>&1
rm -rf /etc/systemd/system/caddy.service >/dev/null 2>&1

rm -rf ${wwwroot} >/dev/null 2>&1
rm -rf /root/.caddy >/dev/null 2>&1
rm -rf /root/.gnupg >/dev/null 2>&1
rm -rf /root/.pki >/dev/null 2>&1
rm -rf ${conf_dir} >/dev/null 2>&1
echo -e "${OK} ${GreenBG} 操作已完成 ${Font}"
}


#卸载php和sqlite
uninstall_php_sqlite(){
check_system

if [[ "${ID}" == "centos" ]];then

	echo -e "${OK} ${GreenBG} 正在卸载 php+sqlite 请稍后 ... ${Font}"
	${INS} ${UNS} php70w-cgi php70w-fpm php70w-curl php70w-gd php70w-mbstring php70w-xml php70w-sqlite3 sqlite-devel -y >/dev/null 2>&1
	${INS} ${UNS} unzip zip -y >/dev/null 2>&1
	echo -e "${OK} ${GreenBG} 操作已完成 ${Font}"

else

	echo -e "${OK} ${GreenBG} 正在卸载 php+sqlite 请稍后 ... ${Font}"
	${INS} ${UNS} php7.0-cgi php7.0-fpm php7.0-curl php7.0-gd php7.0-mbstring php7.0-xml php7.0-sqlite3 sqlite3 -y >/dev/null 2>&1
	${INS} ${UNS} unzip zip -y >/dev/null 2>&1
	echo -e "${OK} ${GreenBG} 操作已完成 ${Font}"

fi
}


#卸载v2ray
uninstall_v2ray(){
Default_dir
Default_v2ray
check_system

echo -e "${OK} ${GreenBG} 正在卸载 v2ray 请稍后 ... ${Font}"
systemctl disable v2ray >/dev/null 2>&1
systemctl stop v2ray >/dev/null 2>&1
killall -9 v2ray >/dev/null 2>&1

rm -rf /usr/bin/v2ray >/dev/null 2>&1
rm -rf ${v2ray_conf_dir} >/dev/null 2>&1
rm -rf /etc/systemd/system/v2ray.service >/dev/null 2>&1

${INS} ${UNS} bc lsof ntpdate -y >/dev/null 2>&1
echo -e "${OK} ${GreenBG} 操作已完成 ${Font}"
}


#卸载bbr
uninstall_bbr(){
Default_dir
Default_rinetdbbr
check_system

echo -e "${OK} ${GreenBG} 正在卸载 rinetdbbr 请稍后 ... ${Font}"
systemctl disable rinetd-bbr >/dev/null 2>&1
systemctl stop rinetd-bbr >/dev/null 2>&1
killall -9 rinetd-bbr >/dev/null 2>&1

rm -rf /usr/bin/rinetd-bbr >/dev/null 2>&1
rm -rf ${rinetdbbr_conf_dir} >/dev/null 2>&1
rm -rf /etc/systemd/system/rinetd-bbr.service >/dev/null 2>&1

echo -e "${OK} ${GreenBG} 操作已完成 ${Font}"
}


#卸载apache2
uninstall_apache2(){

if [[ "${ID}" == "centos" ]];then

	systemctl disable httpd >/dev/null 2>&1
	systemctl stop httpd >/dev/null 2>&1
	killall -9 httpd >/dev/null 2>&1

	rm -rf /etc/httpd >/dev/null 2>&1
	rm -rf /etc/systemd/system/httpd.service >/dev/null 2>&1

	${INS} ${UNS} httpd httpd-tools apr apr-util -y >/dev/null 2>&1

	systemctl disable firewalld >/dev/null 2>&1
	systemctl stop firewalld >/dev/null 2>&1
	killall -9 firewalld >/dev/null 2>&1

else

	systemctl disable apache2 >/dev/null 2>&1
	systemctl stop apache2 >/dev/null 2>&1
	killall -9 apache2 >/dev/null 2>&1

	rm -rf /etc/apache2 >/dev/null 2>&1
	rm -rf /etc/systemd/system/apache2.service >/dev/null 2>&1

	${INS} ${UNS} apache2 -y >/dev/null 2>&1

fi
}


#强制清除可能残余的http服务 更新源
apache_uninstall(){
	echo -e "${OK} ${GreenBG} 正在强制清理可能残余的http服务 ${Font}"

	uninstall_apache2

	echo -e "${OK} ${GreenBG} 正在更新源 请稍后 ... ${Font}"

	${add_source}
	judge "系统更新"

	${INS} install ntpdate bc lsof unzip zip -y
	judge "必要软件 bc lsof unzip 安装"
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
		echo -e "${OK} ${GreenBG} 域名dns解析IP与本机IP匹配 域名解析正确 ${Font}"
		sleep 2
	else
		echo -e "${Error} ${RedBG} 检测到域名dns解析IP与本机IP不匹配 请检查域名解析是否已生效 ${Font}"
		echo -e "${Error} ${RedBG} 如果你使用了 IPv6（AAAA记录） 或者 cloudflareCDN 直接输入y继续安装！（y/n）${Font}" && read install
		case $install in
		[yY][eE][sS]|[yY])
			echo -e "${GreenBG} 继续安装 ${Font}"
			sleep 2
			;;
		*)
			echo -e "${RedBG} 脚本终止继续安装 ${Font}"
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
if [[ "${ID}" == "centos" ]];then

	${INS} install php70w-cgi php70w-fpm php70w-curl php70w-gd php70w-mbstring php70w-xml php70w-sqlite3 sqlite-devel -y
	judge "php+sqlite3 安装"

	setphp="127.0.0.1:9000"
	systemctl enable php-fpm
	systemctl restart php-fpm

else

	${INS} install php7.0-cgi php7.0-fpm php7.0-curl php7.0-gd php7.0-mbstring php7.0-xml php7.0-sqlite3 sqlite3 -y
	judge "php+sqlite3 安装"

	setphp="/run/php/php7.0-fpm.sock"
	systemctl enable php-fpm
	systemctl restart php-fpm

fi
}


#安装caddy主程序
caddy_install(){

	Default_caddy
	#caddy官方脚本
	curl https://getcaddy.com | bash -s personal

	#添加自启动 加载配置文件
	touch /etc/systemd/system/caddy.service
	cat <<EOF > /etc/systemd/system/caddy.service
[Unit]
Description=Caddy server
After=network.target
Wants=network.target

[Service]
Type=simple
PIDFile=/var/run/caddy.pid
ExecStart=/usr/local/bin/caddy -conf=${caddy_conf} -agree=true -ca=https://acme-v02.api.letsencrypt.org/directory
RestartPreventExitStatus=23
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF

	judge "caddy 安装"
}


# 生成网站默认首页
default_html(){
	#添加用户组和用户
	groupadd www-data
	useradd --shell /sbin/nologin -g www-data www-data

	rm -rf ${wwwroot}
	mkdir ${wwwroot}

	touch ${wwwroot}/index.php
	cat <<EOF > ${wwwroot}/index.php
提示：Caddy+PHP7+Sqlite3 环境安装成功！<br><br>
常用命令：<br>
启动：systemctl start caddy<br>
停止：systemctl stop caddy<br>
重启：systemctl restart caddy<br><br>

网站根目录：${wwwroot}
EOF

	chown www-data:www-data -R ${wwwroot}/*
	chmod -R 777 ${wwwroot}

	judge "生成默认首页"
}


#生成caddy配置文件
caddy_conf_add(){
	getport3=$(cat ${conf_dir}/port3.txt)
	getv2ray_path=$(cat ${conf_dir}/v2ray_path.txt)

	rm -rf ${caddy_conf_dir}
	mkdir ${caddy_conf_dir}

	touch ${caddy_conf}
	cat <<EOF > ${caddy_conf}
http://${domain}:${port1} {
	redir https://${domain}:${port2}{url}
	}
https://${domain}:${port2} {
	gzip
	tls admin@${domain}
	root ${wwwroot}
	proxy /${getv2ray_path} localhost:${getport3} {
		websocket
		header_upstream -Origin
	}
	fastcgi / ${setphp} php
}
EOF

	judge "caddy 配置"
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


#展示配置信息
show_information(){
	clear
	echo ""
	echo -e "${Info} ${GreenBG} 小内存VPS 一键安装 Caddy+PHP7+Sqlite3 环境 （支持VPS最小内存64M） 安装成功 ${Font}"
	echo -e "----------------------------------------------------------"
	echo ""
	echo -e "${Green} 启动：${Font} systemctl start caddy"
	echo -e "${Green} 停止：${Font} systemctl stop caddy"
	echo -e "${Green} 重启：${Font} systemctl restart caddy"
	echo ""
	echo -e "${Green} 网站首页：${Font} http://${domain}"
	echo -e "${Green} 网站目录：${Font} ${wwwroot}"
	echo ""
	echo -e "----------------------------------------------------------"
}


#重启caddy加载配置
restart_caddy(){
	systemctl daemon-reload
	systemctl enable caddy >/dev/null 2>&1
	systemctl restart caddy >/dev/null 2>&1
	judge "Caddy+PHP7+Sqlite3 启动"
}


#安装typecho
typecho_install(){
Default_dir
if [[ -e ${conf_dir} ]]; then

echo -e "${OK} ${GreenBG} 正在安装 typecho 到 ${wwwroot} 目录 ${Font}"
rm -rf ${wwwroot}
mkdir ${wwwroot}

wget --no-check-certificate ${typecho_path} -O typecho.tar.gz
tar -zxvf typecho.tar.gz -C ${wwwroot}
mv ${wwwroot}/*build*/* ${wwwroot}
rm -rf ${wwwroot}/*build*
rm -rf typecho.tar.gz

	chown www-data:www-data -R ${wwwroot}/*
	chmod -R 777 ${wwwroot}

echo -e "${OK} ${GreenBG} 操作已完成 ${Font}"
getdomain=$(cat ${conf_dir}/domain.txt)
echo -e "${OK} ${GreenBG} 访问网站首页查看 http://${getdomain} ${Font}"

else
	echo -e "${Error} ${RedBG} 请先执行以下命令安装环境 ${Font}"
	echo -e "${OK} ${GreenBG} wget -N --no-check-certificate git.io/c.sh && chmod +x c.sh && bash c.sh ${Font}"
	exit 1
fi
}


#安装wordpress
wordpress_install(){
Default_dir
if [[ -e ${conf_dir} ]]; then

echo -e "${OK} ${GreenBG} 正在安装 wordpress 到 ${wwwroot} 目录 ${Font}"
rm -rf ${wwwroot}
mkdir ${wwwroot}

wget --no-check-certificate ${wordpress_path} -O wordpress.tar.gz
tar -zxvf wordpress.tar.gz -C ${wwwroot}
mv ${wwwroot}/wordpress/* ${wwwroot}
rm -rf ${wwwroot}/wordpress
rm -rf wordpress.tar.gz

wget --no-check-certificate ${wordpress_sqlite} -O sqlite.zip
unzip sqlite.zip -d ${wwwroot}
mv ${wwwroot}/wp-config-sample.php ${wwwroot}/wp-config.php
mv ${wwwroot}/sqlite-integration ${wwwroot}/wp-content/plugins/
mv ${wwwroot}/wp-content/plugins/sqlite-integration/db.php ${wwwroot}/wp-content/
sed -i "s/define('DB_COLLATE', '');/define('DB_TYPE', 'sqlite');/g" ${wwwroot}/wp-config.php
rm -rf sqlite.zip

	chown www-data:www-data -R ${wwwroot}/*
	chmod -R 777 ${wwwroot}

echo -e "${OK} ${GreenBG} 操作已完成 ${Font}"
getdomain=$(cat ${conf_dir}/domain.txt)
echo -e "${OK} ${GreenBG} 访问网站首页查看 http://${getdomain} ${Font}"

else
	echo -e "${Error} ${RedBG} 请先执行以下命令安装环境 ${Font}"
	echo -e "${OK} ${GreenBG} wget -N --no-check-certificate git.io/c.sh && chmod +x c.sh && bash c.sh ${Font}"
	exit 1
fi
}


#安装zblog
zblog_install(){
Default_dir
if [[ -e ${conf_dir} ]]; then

echo -e "${OK} ${GreenBG} 正在安装 zblog 到 ${wwwroot} 目录 ${Font}"
rm -rf ${wwwroot}
mkdir ${wwwroot}

wget --no-check-certificate ${zblog_path} -O zblog.tar.gz
tar -zxvf zblog.tar.gz -C ${wwwroot}
mv ${wwwroot}/*zblog*/* ${wwwroot}
rm -rf ${wwwroot}/*zblog*
rm -rf zblog.tar.gz

	chown www-data:www-data -R ${wwwroot}/*
	chmod -R 777 ${wwwroot}

echo -e "${OK} ${GreenBG} 操作已完成 ${Font}"
getdomain=$(cat ${conf_dir}/domain.txt)
echo -e "${OK} ${GreenBG} 访问网站首页查看 http://${getdomain} ${Font}"

else
	echo -e "${Error} ${RedBG} 请先执行以下命令安装环境 ${Font}"
	echo -e "${OK} ${GreenBG} wget -N --no-check-certificate git.io/c.sh && chmod +x c.sh && bash c.sh ${Font}"
	exit 1
fi
}


#安装kedexplorer
kodexplorer_install(){
Default_dir
if [[ -e ${conf_dir} ]]; then

echo -e "${OK} ${GreenBG} 正在安装 kedexplorer 到 ${wwwroot} 目录 ${Font}"
rm -rf ${wwwroot}
mkdir ${wwwroot}

wget --no-check-certificate ${kodcloud_path} -O kodcloud.tar.gz
tar -zxvf kodcloud.tar.gz -C ${wwwroot}
mv ${wwwroot}/*KodExplorer*/* ${wwwroot}
rm -rf ${wwwroot}/*KodExplorer*
rm -rf kodcloud.tar.gz

	chown www-data:www-data -R ${wwwroot}/*
	chmod -R 777 ${wwwroot}

echo -e "${OK} ${GreenBG} 操作已完成 ${Font}"
getdomain=$(cat ${conf_dir}/domain.txt)
echo -e "${OK} ${GreenBG} 访问网站首页查看 http://${getdomain} ${Font}"

else
	echo -e "${Error} ${RedBG} 请先执行以下命令安装环境 ${Font}"
	echo -e "${OK} ${GreenBG} wget -N --no-check-certificate git.io/c.sh && chmod +x c.sh && bash c.sh ${Font}"
	exit 1
fi
}


#安装laverna
laverna_install(){
Default_dir
if [[ -e ${conf_dir} ]]; then

echo -e "${OK} ${GreenBG} 正在安装 laverna 到 ${wwwroot} 目录 ${Font}"
rm -rf ${wwwroot}
mkdir ${wwwroot}

wget --no-check-certificate ${laverna_path} -O laverna.zip
unzip laverna.zip -d ${wwwroot}

mv ${wwwroot}/*laverna*/* ${wwwroot}
rm -rf ${wwwroot}/*laverna*
rm -rf laverna.zip

	chown www-data:www-data -R ${wwwroot}/*
	chmod -R 777 ${wwwroot}

echo -e "${OK} ${GreenBG} 操作已完成 ${Font}"
getdomain=$(cat ${conf_dir}/domain.txt)
echo -e "${OK} ${GreenBG} 访问网站首页查看 http://${getdomain} ${Font}"

else
	echo -e "${Error} ${RedBG} 请先执行以下命令安装环境 ${Font}"
	echo -e "${OK} ${GreenBG} wget -N --no-check-certificate git.io/c.sh && chmod +x c.sh && bash c.sh ${Font}"
	exit 1
fi
}


#整站备份
bak_wwwroot(){
Default_dir
if [[ -e ${conf_dir} ]]; then

echo -e "${OK} ${GreenBG} 正在整站备份（含数据库） ${Font}"

unzip_password_w=`cat /dev/urandom | head -n 10 | md5sum | head -c 8`
rm -rf ${wwwroot}/www.zip
zip -q -r -P ${unzip_password_w} ${wwwroot}/www.zip ${wwwroot}

getdomain=$(cat ${conf_dir}/domain.txt)
echo -e "${OK} ${GreenBG} 操作已完成 ${Font}"
echo -e "${OK} ${GreenBG} 下载地址为：http:\\${getdomain}\www.zip ${Font}"
echo -e "${OK} ${Green} 解压密码（由函数随机生成）：${Font} ${unzip_password_w}"

else
	echo -e "${Error} ${RedBG} 请先执行以下命令安装环境 ${Font}"
	echo -e "${OK} ${GreenBG} wget -N --no-check-certificate git.io/c.sh && chmod +x c.sh && bash c.sh ${Font}"
	exit 1
fi
}


#同步服务器时间
time_modify(){
	systemctl stop ntp &>/dev/null

	echo -e "${Info} ${GreenBG} 正在进行时间同步 ${Font}"
	ntpdate time.nist.gov

	if [[ $? -eq 0 ]];then 
		echo -e "${OK} ${GreenBG} 时间同步成功 ${Font}"
		echo -e "${OK} ${GreenBG} 当前系统时间 `date -R`（时区时间换算后误差应为三分钟以内）${Font}"
		sleep 1
	else
		echo -e "${Error} ${RedBG} 时间同步失败，请检查ntpdate服务是否正常工作 ${Font}"
	fi 
}


#生成v2ray配置文件
v2ray_conf_add(){
	touch ${v2ray_conf}
	cat <<EOF > ${v2ray_conf}
{
  "inbound": {
	"port": ${getport3},
	"listen":"127.0.0.1",
	"protocol": "vmess",
	"settings": {
	  "clients": [
		{
		  "id": "${UUID}",
		  "alterId": ${alterId}
		}
	  ]
	},
	"streamSettings": {
	  "network": "ws",
	  "wsSettings": {
	  "path": "/${getv2ray_path}"
	  }
	}
  },
  "outbound": {
	"protocol": "freedom",
	"settings": {}
  }
}
EOF

	judge "V2ray 配置"
}


#生成v2ray客户端json文件
v2ray_user_config(){
	touch ./V2rayPro/v2ray/config.json
	cat <<EOF > ./V2rayPro/v2ray/config.json
{
  "inbound": {
	"port": 1080,
	"listen": "127.0.0.1",
	"protocol": "socks",
	"domainOverride": ["tls","http"],
	"settings": {
	  "auth": "noauth",
	  "udp": false
	}
  },
  "outbound": {
	"protocol": "vmess",
	"settings": {
	  "vnext": [
		{
		  "address": "${getdomain}",
		  "port": ${getport2},
		  "users": [
			{
			  "id": "${UUID}",
			  "alterId": ${alterId}
			}
		  ]
		}
	  ]
	},
	"streamSettings": {
	  "network": "ws",
	  "security": "tls",
	  "wsSettings": {
		"path": "/${getv2ray_path}"
	  }
	}
  }
}
EOF

judge "客户端json配置"
}


#生成Windows客户端
win64_v2ray(){
	win64_source
	TAG_URL="https://api.github.com/repos/v2ray/v2ray-core/releases/latest"
	NEW_VER=`curl -s ${TAG_URL} --connect-timeout 10| grep 'tag_name' | cut -d\" -f4`

	echo -e "${OK} ${GreenBG} 正在生成Windows客户端 v2ray-core最新版本 ${NEW_VER} ${Font}"
	rm -rf ./V2rayPro
	mkdir ./V2rayPro
	mkdir ./V2rayPro/v2ray
	wget --no-check-certificate https://github.com/v2ray/v2ray-core/releases/download/${NEW_VER}/v2ray-windows-64.zip -O v2ray.zip
	unzip v2ray.zip -d ./V2rayPro/v2ray
	wget --no-check-certificate ${bat_url} -O bat.zip
	unzip bat.zip
	mv bat ./V2rayPro/start.bat
	mv exe ./V2rayPro/v2ray/wv2ray-service.exe

	v2ray_user_config

	echo -e "${OK} ${GreenBG} 正在打包 v2ray-windows-64 客户端 ${Font}"

	rm -rf ${wwwroot}/V2rayPro.zip
	zip -q -r -P ${unzip_password_v} ${wwwroot}/V2rayPro.zip ./V2rayPro
	judge "Windows 客户端打包成功"

	rm -rf v2ray.zip
	rm -rf bat.zip
	rm -rf ./V2rayPro
}


#展示v2ray客户端配置信息
v2ray_information(){
	clear
	echo ""
	echo -e "${Info} ${GreenBG} 基于 Caddy+v2ray 的 VMESS+WS+TLS+Website(Use Path) 安装成功 ${Font}"
	echo -e "----------------------------------------------------------"
	echo ""
	echo -e "${Green} 地址（address）：${Font} ${getdomain}"
	echo -e "${Green} 端口（port）：${Font} ${getport2}"
	echo -e "${Green} 用户ID（id）：${Font} ${UUID}"
	echo -e "${Green} 额外ID（alterid）：${Font} ${alterId}"
	echo ""
	echo -e "${Green} 加密方式（security）：${Font} none"
	echo -e "${Green} 传输协议（network）：${Font} 选 ws 或 websocket"
	echo -e "${Green} 伪装类型（type）：${Font} none"
	echo ""
	echo -e "${Green} 伪装类型（ws host）：${Font} 留空"
	echo -e "${Green} 伪装路径（ws path）：${Font} /${getv2ray_path}"
	echo -e "${Green} 底层传输安全：${Font} tls"
	echo ""
	echo -e "${Green} 注意：伪装路径不要少写 [ / ] ${Font}"
	echo -e "${Green} Windows系统64位客户端下载：${Font} http:\\${getdomain}\V2rayPro.zip"
	echo -e "${Green} 解压密码（由函数随机生成）：${Font} ${unzip_password_v}"
	echo ""
	echo -e "----------------------------------------------------------"
}


#重启v2ray加载配置
restart_v2ray(){
	systemctl daemon-reload
	systemctl enable v2ray >/dev/null 2>&1
	systemctl restart v2ray >/dev/null 2>&1
	judge "V2ray 启动"
}


#安装v2ray主程序
v2ray_install(){
Default_dir
if [[ -e ${conf_dir} ]]; then
echo -e "${OK} ${GreenBG} 正在安装 V2Ray 请稍后 ... ${Font}"
	time_modify
	Default_v2ray

	UUID=$(cat /proc/sys/kernel/random/uuid)

	getdomain=$(cat ${conf_dir}/domain.txt)
	getport2=$(cat ${conf_dir}/port2.txt)
	getport3=$(cat ${conf_dir}/port3.txt)
	getv2ray_path=$(cat ${conf_dir}/v2ray_path.txt)

	unzip_password_v=`cat /dev/urandom | head -n 10 | md5sum | head -c 8`
	rm -rf ${v2ray_conf_dir}
	mkdir ${v2ray_conf_dir}

	bash <(curl -L -s https://install.direct/go.sh)
	judge "安装 V2ray"

	touch /etc/systemd/system/v2ray.service
	cat <<EOF > /etc/systemd/system/v2ray.service
[Unit]
Description=V2Ray Service
After=network.target
Wants=network.target

[Service]
Type=simple
PIDFile=/var/run/v2ray.pid
ExecStart=/usr/bin/v2ray/v2ray -config ${v2ray_conf}
RestartPreventExitStatus=23
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF

	v2ray_conf_add
	win64_v2ray
	v2ray_information
	restart_v2ray

else
	echo -e "${Error} ${RedBG} 请先执行以下命令安装环境 ${Font}"
	echo -e "${OK} ${GreenBG} wget -N --no-check-certificate git.io/c.sh && chmod +x c.sh && bash c.sh ${Font}"
	exit 1
fi
}


#安装bbr端口加速
rinetdbbr_install(){
Default_dir
if [[ -e ${conf_dir} ]]; then
echo -e "${OK} ${GreenBG} 正在安装 Rinetdbbr 请稍后 ... ${Font}"
	Default_rinetdbbr
	rm -rf ${rinetdbbr_conf_dir}
	mkdir ${rinetdbbr_conf_dir}

	getport2=$(cat ${conf_dir}/port2.txt)

	wget --no-check-certificate ${rinetdbbr_url} -O rinetdbbr
	mv rinetdbbr /usr/bin/rinetd-bbr
	chmod +x /usr/bin/rinetd-bbr
	judge "rinetd-bbr 安装"

	IFACE=$(ip -4 addr | awk '{if ($1 ~ /inet/ && $NF ~ /^[ve]/) {a=$NF}} END{print a}')

	touch ${rinetdbbr_conf}
	cat <<EOF >> ${rinetdbbr_conf}
0.0.0.0 ${getport2} 0.0.0.0 ${getport2}
EOF

	touch /etc/systemd/system/rinetd-bbr.service
	cat <<EOF > /etc/systemd/system/rinetd-bbr.service
[Unit]
Description=Rinetdbbr Service
After=network.target
Wants=network.target

[Service]
Type=simple
PIDFile=/var/run/rinetd-bbr.pid
ExecStart=/usr/bin/rinetd-bbr -f -c ${rinetdbbr_conf_dir} raw ${IFACE}
RestartPreventExitStatus=23
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF
	judge "rinetd-bbr 自启动配置"

	systemctl daemon-reload
	systemctl enable rinetd-bbr >/dev/null 2>&1
	systemctl start rinetd-bbr
	judge "加速端口：${getport2} 启动 rinetd-bbr"

else
	echo -e "${Error} ${RedBG} 请先执行以下命令安装环境 ${Font}"
	echo -e "${OK} ${GreenBG} wget -N --no-check-certificate git.io/c.sh && chmod +x c.sh && bash c.sh ${Font}"
	exit 1
fi
}


#命令块执行列表
main(){
	is_root
	check_system
	systemd_chack
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
	#check_ssl
	show_information
	restart_caddy
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
		-l|--laverna_install)
		laverna_install
		;;
		-a|--bak_wwwroot)
		bak_wwwroot
		;;
		-v|--v2ray_install)
		v2ray_install
		;;
		-b|--rinetdbbr_install)
		rinetdbbr_install
		;;
		-unc|--uninstall_caddy)
		uninstall_caddy
		;;
		-unp|--uninstall_php_sqlite)
		uninstall_php_sqlite
		;;
		-unv|--uninstall_v2ray)
		uninstall_v2ray
		;;
		-unb|--uninstall_bbr)
		uninstall_bbr
		;;
	esac
else
	main
fi
