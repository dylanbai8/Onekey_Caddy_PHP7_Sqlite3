
## 脚本特性：
-----
-----
* 小内存VPS 一键安装 Caddy+PHP7+Sqlite3 环境 （支持VPS最小内存64M）
* 一键绑定域名自动生成SSL证书开启https（ssl自动续期）、支持IPv6
* 一键安装 typecho、wordpress、zblog、kodexplorer、一键整站备份
* 一键安装 v2ray、rinetdbbr
* 支持系统：Debian 8 （建议选择mini版）
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

