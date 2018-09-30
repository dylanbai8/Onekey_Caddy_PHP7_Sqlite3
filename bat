@echo off
cd /d %~dp0
:: 请保留以下版权信息 谢谢
:: V2RAY 基于 NGINX 的 VMESS+WS+TLS+Website(Use Host)+Rinetd BBR 一键安装脚本
:: https://github.com/dylanbai8/V2Ray_ws-tls_Website_onekey

%1 start "" mshta vbscript:createobject("shell.application").shellexecute("""%~0""","::",,"runas",1)(window.close)&exit
:: 获取管理员权限，不需要可删除或注释掉

title -- v2ray便捷启动脚本 --
MODE con: COLS=60 lines=21
color 0a

:begin
cls
MODE con: COLS=60 lines=21
echo.
echo    ===== v2ray便捷启动脚本 =====
echo.
echo --[1]--启动/重启V2ray并隐藏窗口（wv2ray.exe）
echo --[2]--临时启动并显示进程窗口(v2ray.exe)
echo.
echo --[3]--安装开机自启动服务（管理员权限）
echo --[4]--一键开启系统代理
echo.
echo --[5]--卸载开机自启动服务（管理员权限）
echo --[6]--一键关闭系统代理
echo.
echo --[7]--关闭v2ray后台进程
echo --[8]--退出脚本
echo.
echo --注意--临时启动中测试正常后再安装为自启动服务
echo --注意--如需升级版本仅需要替换 \v2ray\ 目录
echo.
choice /c 12345678 /n /m "请选择【1-8】："
 
echo %errorlevel%
if %errorlevel% == 1 goto set_1
if %errorlevel% == 2 goto set_2
if %errorlevel% == 3 goto set_3
if %errorlevel% == 4 goto set_4
if %errorlevel% == 5 goto set_5
if %errorlevel% == 6 goto set_6
if %errorlevel% == 7 goto set_7
if %errorlevel% == 8 goto end 

:set_1
MODE con: COLS=80 lines=16
sc stop v2ray 1>nul 2>nul
taskkill /im wv2ray.exe /f 1>nul 2>nul
cls
echo.
echo.
echo 程序正在启动中....
echo.
echo.
echo --[正在启动后台进程]--
echo.
sc start v2ray 1>nul 2>nul
start "" /d "%cd%\v2ray\" "wv2ray.exe" -config=%cd%\v2ray\config.json
ping localhost -n 2 1>nul 2>nul
tasklist /fi "imagename eq wv2ray.exe"
echo.
echo 启动成功，按任意键隐藏窗口
ping localhost -n 3 1>nul 2>nul
exit

:set_2
sc stop v2ray 1>nul 2>nul
taskkill /im wv2ray.exe /f 1>nul 2>nul
cls
echo.
echo.
start "" /d "%cd%\v2ray\" "v2ray.exe" -config=%cd%\v2ray\config.json
goto begin

:set_3
MODE con: COLS=60 lines=20
sc stop v2ray 1>nul 2>nul
taskkill /im wv2ray.exe /f 1>nul 2>nul
cls
echo.
echo.
echo.
echo 正在获取【管理员权限】，请在弹出菜单中点【是】
echo.
echo.
echo --[正在安装服务]--
echo.
%cd%\v2ray\wv2ray-service.exe install v2ray "%cd%\v2ray\wv2ray.exe"
%cd%\v2ray\wv2ray-service.exe set v2ray Start SERVICE_AUTO_START
%cd%\v2ray\wv2ray-service.exe set v2ray DisplayName "V2ray Auto Start"
%cd%\v2ray\wv2ray-service.exe set v2ray Description "V2ray 开机自启动服务（守护进程）"
echo.
echo.
echo 服务安装成功。按【任意键】启动服务，请在弹出菜单中点【是】
pause>nul
MODE con: COLS=80 lines=16
echo.
echo.
echo V2ray服务正在启动中....
echo.
echo.
echo --[正在启动服务]--
sc start v2ray 1>nul 2>nul
echo.
ping localhost -n 2 1>nul 2>nul
tasklist /fi "imagename eq wv2ray.exe"
echo.
echo 服务启动成功。按任意键返回开始菜单
pause>nul
goto begin

:set_4
MODE con: COLS=60 lines=20
cls
echo.
echo.
echo.
echo 开始设置系统代理
echo Internet选项-连接-局域网设置-代理服务器
echo.
echo  --[现在程序将关闭您的ie浏览器]--
taskkill /f /im iexplore.exe 1>nul 2>nul
echo.
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyEnable /t REG_DWORD /d 1 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyServer /d "127.0.0.1:1087" /f
echo.
echo  --[已成功设置代理服务器上网]--
echo.
echo 注意：当您关闭v2ray进程时需同时关闭系统代理
echo       否则将导致系统无法联网
echo.
echo 按任意键返回开始菜单
pause>nul
goto begin

:set_5
MODE con: COLS=60 lines=14
sc stop v2ray 1>nul 2>nul
taskkill /im wv2ray.exe /f 1>nul 2>nul
cls
echo.
echo.
echo.
echo 正在获取【管理员权限】，请在弹出菜单中点【是】
echo.
echo --[正在卸载自启动服务]--
%cd%\v2ray\wv2ray-service.exe remove v2ray confirm
echo.
echo 卸载成功。按任意键返回开始菜单
pause>nul
goto begin

:set_6
MODE con: COLS=60 lines=17
cls
echo.
echo.
echo.
echo 开始设置取消系统代理
echo Internet选项-连接-局域网设置-代理服务器
echo.
echo  --[现在程序将关闭您的浏览器]--
taskkill /f /im iexplore.exe 1>nul 2>nul
echo.
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyEnable /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyServer /d "" /f
echo.
echo  --[已取消代理服务器上网]--
echo.
echo 按任意键返回开始菜单
pause>nul
goto begin

:set_7
MODE con: COLS=60 lines=11
cls
echo.
echo.
echo.
echo 关闭v2ray后台（服务）进程....
echo.
echo --[正在关闭v2ray进程]--
sc stop v2ray 1>nul 2>nul
taskkill /im wv2ray.exe /f 1>nul 2>nul
echo.
echo 关闭成功。按任意键返回开始菜单
pause>nul
goto begin

:end
exit
