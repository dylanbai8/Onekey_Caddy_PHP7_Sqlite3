
## 严重声明：

此项目仅限于技术交流和探讨，在您测试完毕后必须在1秒钟内彻底删除项目副本。

此项目为bash一键脚本，其中涉及到的任何软件版权和责任归原作者所有。

## 友情提示：

在中国境内使用、传播、售卖、免费分享等任何翻墙服务，都是违法的。

如果你在中国境内使用、测试此项目脚本，或者使用此脚本搭建服务器发生以上违法行为，都有违作者意愿！

你必须立刻停止此行为！并删除脚本！


## 脚本特性：
-----
-----
* 小内存VPS 一键安装 Caddy+PHP7+Sqlite3 环境 （支持VPS最小内存64M）
* 一键绑定域名自动生成SSL证书开启https（ssl自动续期）、支持IPv6
* 一键安装 typecho、wordpress、zblog、kodexplorer、laverna、一键整站备份
* 一键安装 v2ray、rinetdbbr
* 经典组合 [Website(caddy+php7+sqlite3+tls)+V2ray(vmess+websocket)]use_path+Rinetdbbr
* 支持系统：Centos 7+  Debian 8+ （建议选择 Debian 8 mini版）
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
