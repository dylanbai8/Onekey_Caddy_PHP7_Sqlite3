## 免费 VPS
```
Skysilk新主机商，最近正式上线，走下方AFF链接送10美元，官网普通注册送5美元。
官网最低价套餐为1美元/月 KVM VPS（512MB RAM/10GB SSD/单向各500G流量）按小时付费。
关注Facebook、Twitter、填写问卷后额外再送3美元，以上套餐一共可免费使用用13个月。需要信用卡验证。

邀请链接：https://www.skysilk.com/ref/r1UvdFewpb

貌似不支持QQ邮箱注册，Gmail和Aliyun邮箱测试正常
```


## 免费域名
```
http://www.freenom.com

建议更换ns服务器，默认ns服务器在国内很不稳定。
```


## 脚本特性：
-----
-----
* 小内存VPS 一键安装 Caddy+PHP7+Sqlite3 环境 （支持VPS最小内存64M）
* 一键绑定域名自动生成SSL证书开启https（ssl自动续期）、支持IPv6
* 一键安装 typecho、wordpress、zblog、kodexplorer、一键整站备份
* 一键安装 v2ray、rinetdbbr
* 支持系统：Debian 7、8、9 （建议选择mini版）
-----
-----

## 一键安装 Caddy+PHP7+Sqlite3 环境
#### 1.解析好域名 2.执行以下命令
#### 3.提示：支持IPv6（AAAA记录）如果本地网络不支持IPv6可以通过cloudflareCDN转换为IP4
```
wget -N --no-check-certificate git.io/c.sh && chmod +x c.sh && bash c.sh
```

## 一键安装 typecho 博客
```
bash c.sh -t
```

## 一键安装 wordpress 博客
```
bash c.sh -w
```

## 一键安装 zblog 博客
```
bash c.sh -z
```

## 一键安装 kodexplorer 可道云
```
bash c.sh -k
```

## 一键安装 laverna 印象笔记
```
bash c.sh -l
```

## 一键整站备份（一键打包/www目录 含数据库）
```
bash c.sh -a
```

## 一键安装 v2ray 翻墙
```
bash c.sh -v
```

## 一键安装 rinetd bbr 端口加速
```
bash c.sh -b
```

## 一键卸载命令：
```
卸载 caddy
bash c.sh -unc

卸载 php+sqlite
bash c.sh -unp

卸载 v2ray
bash c.sh -unv

卸载 rinetdbbr
bash c.sh -unb
```

## 小内存 vps 添加系统定时重启任务
```
(crontab -l ; echo "0 16 * * * /sbin/reboot") | crontab -
```
