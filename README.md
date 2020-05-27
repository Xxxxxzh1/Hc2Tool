如何获取该工具
===
- git clone git@git.zerozero.cn:zhengzhi/hc2tool.git

如何使用
===
Dialog模块安装
----
- Macos系统
    1. 安装homebrew：  
`/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"`
    2. 安装dialog：  
    `brew install dialog `
- Linux系统
    1. 安装dialog：  
`yum install dialog`

adb模块安装
----
- Macos系统
    1. 安装homebrew：  
`/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"`
    2. 安装adb：  
    `brew cask install android-platform-tools `
- Linux系统
    1. 安装adb：  
`sudo apt-get install android-tools-adb`

脚本使用
----
- 飞机开机状态下连接电脑
- 到脚本所在路径下运行./HC2tool.sh，选择需要的功能，当前已支持的功能：
    1. 查询飞机Wi-Fi名称及密码
    2. 查询飞机Ipk和镜像
    3. 查询飞机云台和声呐版本
    4. 拉取最近一次log
    5. 拉取上一次log
    6. 更改飞机Wi-Fi名称
    7. 更改飞机密码
    8. 打开避障Replay
  