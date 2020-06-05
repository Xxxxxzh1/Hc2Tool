#!/bin/bash

selectFunc(){
	dialog --title "Function list" --backtitle "### HC2Tool ### \nAny question please connect with zhengzhi@zeorzero.cn" --clear --menu \
	"Choose one function" 30 50 10 \
	1 "Show your drone's Wi-Fi_Ssid && Password" \
	2 "Show your drone's Ipk && mirror image" \
	3 "Show your drone's sensor_info" \
	4 "Pull log--latest time" \
	5 "Pull log--last time" \
	6 "Change your drone's Wi-Fi_Ssid" \
	7 "Change your drone's Password" \
	8 "Open path_planning replay" \
	9 "Exit" \
	2>menu
	num=`cat menu`
	echo "you choose function "$num" "
	case $num in 
		1) showSsid_Passwd
		;;
		2) showIpk_Mirror
		;;
		3) showSensorInfo
		;;
		4) pullLogLatest
		;;
		5) pullLogLast
		;;
		6) changeSsid
		;;
		7) changePasswd
		;;
		8) OAReplaySwitch
		;;
		9) exit
		;;
	esac
}


showSsid_Passwd(){
	ssid=$(adb wait-for-device shell cat data/misc/wifi/hostapd.conf | grep ^ssid)
	passwd=$(adb wait-for-device shell cat data/misc/wifi/hostapd.conf | grep ^wpa_passphrase)
	ssid=${ssid##*=}
	passwd=${passwd##*=}
	dialog --title "Wi-Fi_Ssid && Password" --backtitle "### HC2Tool ### Any question please connect with zhengzhi@zeorzero.cn" --clear --msgbox \
	"your drone's name: ${ssid} \nyour drone's Password: ${passwd}" 20 45
}

showIpk_Mirror(){
	ipk=$(adb wait-for-device shell opkg info | grep "Version")
	mirrorImage=$(adb wait-for-device shell getprop zz.product.version)
	ipk=${ipk##* }
	mirrorImage=${mirrorImage##*V}
	dialog --title "IPK && MirrorImage" --backtitle "### HC2Tool ### Any question please connect with zhengzhi@zeorzero.cn" --clear --msgbox \
	"your drone's IPK_Version: ${ipk} \nyour drone's MirrorImage: ${mirrorImage}" 20 45
}


showSensorInfo(){
	adb reboot
	sleep 20
	gimbalInfo=$(adb wait-for-device shell cat /hover/log/latest/fc_log/fc.1.log | grep -a "Gimbal")
	sonarInfo=$(adb wait-for-device shell cat /hover/log/latest/fc_log/fc.1.log | grep -a "Sonar")
	dialog --title "Sensor_info" --backtitle "### HC2Tool ### Any question please connect with zhengzhi@zeorzero.cn" --clear --msgbox \
	"your drone's ${gimbalInfo} \nyour drone's ${sonarInfo}" 20 45
}

pullLogLatest(){
	adb pull /hover/log/latest ~/Desktop/. && \
	dialog --title "Pull latest log" --backtitle "### HC2Tool ### Any question please connect with zhengzhi@zeorzero.cn" --clear --msgbox \
	"log saved in ~/Desktop" 20 45
}

pullLogLast(){
	# log_num=$(adb shell ls -lh /hover/log/ | grep "last")
	# log_num=${log_num##*/} 
	# adb pull /hover/log/remote/${log_num} ~/Desktop/. && \
	adb pull /hover/log/last ~/Desktop/. &&
	mv ~/Desktop/last ~/Desktop/last.zip &&
	dialog --title "Pull last log" --backtitle "### HC2Tool ### Any question please connect with zhengzhi@zeorzero.cn" --clear --msgbox \
	"log saved in ~/Desktop" 20 45
}

changeSsid(){
	dialog --title "Change Ssid" --backtitle "### HC2Tool ### Any question please connect with zhengzhi@zeorzero.cn" --clear --inputbox \
	"Please input your Ssid (default:hc2-xxxxxx)" 20 45 "hc2-xxxxxx" 2>newssid.txt
	newssid=$(cat newssid.txt)
	rm newssid.txt
	adb shell sed -i "s/^ssid=.*/ssid=${newssid}/g" data/misc/wifi/hostapd.conf && 
	dialog --title "Change Ssid" --backtitle "### HC2Tool ### Any question please connect with zhengzhi@zeorzero.cn" --clear --msgbox \
	"your drone's ssid changed as ${newssid}" 20 45
}

changePasswd(){
	dialog --title "Change Ssid" --backtitle "### HC2Tool ### Any question please connect with zhengzhi@zeorzero.cn" --clear --inputbox \
	"Please input your Password (default:1234567890)" 20 45 "1234567890" 2>newpasswd.txt
	newpasswd=$(cat newpasswd.txt)
	rm newpasswd.txt
	adb shell sed -i "s/wpa_passphrase=.*/wpa_passphrase=${newpasswd}/g" data/misc/wifi/hostapd.conf && 
	dialog --title "Change Ssid" --backtitle "### HC2Tool ### Any question please connect with zhengzhi@zeorzero.cn" --clear --msgbox \
	"your drone's Password changed as ${newpasswd}" 20 45
}

OAReplaySwitch(){
	dialog --title "OA-Replay Switch" --backtitle "### HC2Tool ### Any question please connect with zhengzhi@zeorzero.cn" --clear --yesno \
	"If you need to open OA-Replay, choose yes!" 10 50
	result=$?
	if [ $result -eq 0 ];then
		cat <<EOF > zz_pathplanning.service
[Unit]
Description=zerozero path planning neo service
After=zz_rovio_hc2.service
PartOf=qmmf-server.service

[Service]
CPUAffinity=2 3
Restart=always
## Discarded: use ">>" record the log
#ExecStartPre=-/bin/mkdir -p /home/root/application/latest/log/latest/path_planning
#ExecStart=/bin/bash -c 'sleep 3 && home/root/application/latest/path_planning/path_planning --config /hover/path_planning/path_planning.prototxt --calibration /persist/stereo.yaml -f /media/internal/DCIM/path_planning.replay >> /home/root/application/latest/log/latest/path_planning/path_planning.std.log'
#ExecStart=/bin/bash -c 'sleep 3 && home/root/application/latest/path_planning/path_planning --config /hover/path_planning/path_planning.prototxt --calibration /persist/stereo.yaml >> /home/root/application/latest/log/latest/path_planning/path_planning.std.log'

## Use ZZLOG to record the log
ExecStart=/bin/bash -c 'sleep 3 && home/root/application/latest/path_planning/path_planning --config /hover/path_planning/path_planning.prototxt --calibration /persist/stereo.yaml -f /media/internal/DCIM/path_planning.replay'

#ExecStart=/bin/bash -c 'sleep 3 && home/root/application/latest/path_planning/path_planning --config /hover/path_planning/path_planning.prototxt --calibration /persist/stereo.yaml'
CPUQuota=60%

[Install]
WantedBy=multi-user.target
EOF
		# cat zz_pathplanning.service
		adb push zz_pathplanning.service /etc/systemd/system/
		adb shell chmod 664 /etc/systemd/system/zz_pathplanning.service
		rm zz_pathplanning.service
	elif [ $result -eq 1 ]; then
		cat <<EOF > zz_pathplanning.service
[Unit]
Description=zerozero path planning neo service
After=zz_rovio_hc2.service
PartOf=qmmf-server.service

[Service]
CPUAffinity=2 3
Restart=always
## Discarded: use ">>" record the log
#ExecStartPre=-/bin/mkdir -p /home/root/application/latest/log/latest/path_planning
#ExecStart=/bin/bash -c 'sleep 3 && home/root/application/latest/path_planning/path_planning --config /hover/path_planning/path_planning.prototxt --calibration /persist/stereo.yaml -f /media/internal/DCIM/path_planning.replay >> /home/root/application/latest/log/latest/path_planning/path_planning.std.log'
#ExecStart=/bin/bash -c 'sleep 3 && home/root/application/latest/path_planning/path_planning --config /hover/path_planning/path_planning.prototxt --calibration /persist/stereo.yaml >> /home/root/application/latest/log/latest/path_planning/path_planning.std.log'

## Use ZZLOG to record the log
#ExecStart=/bin/bash -c 'sleep 3 && home/root/application/latest/path_planning/path_planning --config /hover/path_planning/path_planning.prototxt --calibration /persist/stereo.yaml -f /media/internal/DCIM/path_planning.replay'

ExecStart=/bin/bash -c 'sleep 3 && home/root/application/latest/path_planning/path_planning --config /hover/path_planning/path_planning.prototxt --calibration /persist/stereo.yaml'
CPUQuota=60%

[Install]
WantedBy=multi-user.target
EOF
		# cat zz_pathplanning.service
		adb push zz_pathplanning.service /etc/systemd/system/
		adb shell chmod 664 /etc/systemd/system/zz_pathplanning.service
		rm zz_pathplanning.service
	fi
}

while [ true ]; do
	selectFunc
done



