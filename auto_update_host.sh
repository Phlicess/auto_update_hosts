#!/bin/sh
#
# Create By WuTong
# At 2016/12/13
#
# 默认hosts地址: https://raw.githubusercontent.com/racaljk/hosts/master/hosts
#

# 默认地址
hostsUrl=""
localHostsUrl="/etc/hosts"
screenName="getHosts7758521"
hour=10

# 替换hosts的函数
function replaceHosts()
{
  echo "从${hostsUrl}拉取数据..\n"
  sudo cp "$localHostsUrl" "/etc/hosts`date +\"%H:%M:%S\"`"
  sudo curl $hostsUrl > $localHostsUrl
  sudo sed -i -n '/github/p' $localHostsUrl
  sudo sed -i -n '/github/d' $localHostsUrl
  echo "更新成功.. \n`date +\"%x %T\"`\n"
}



# 获取hosts地址
if [ $# -lt 1 ]; then
  hostsUrl="https://raw.githubusercontent.com/racaljk/hosts/master/hosts"
else
  while [ $# -ge 1 ]; do
    # echo $#
    # echo $1
    case $1 in
      "-u")
        hostsUrl=$2
        shift;shift
      ;;
      "-h")
        hour=$2
        shift;shift
      ;;
      "-v")
        echo "version 0.1.0"
        exit 0
      ;;
      *)
        echo "\n亲~ 参数不对~~\n"
        echo "背景运行程序采用Screen的形式, 默认的Screen名字为${screenName}, 如果想停止运行的话"
        echo "请执行 screen -r ${screenName}, 然后执行 exit\n"
        echo "Options:\n"
        echo "    -h                设置每天更新的时间(默认为早上10点)"
        echo "    -u                设置更新的hosts文件的url(默认为github上面的)"
        echo "    -v                查看版本号"
        exit 0
      ;;
    esac
  done
fi

# echo $hour
# echo $hostsUrl
# exit 0


result=`screen -ls | awk '{print $1}'`

echo "result: ${result}\n"
# exit 0

isContainer=`echo $result | grep $screenName`

echo "isContainer: ${isContainer}\n"

# 创建screen, 如果screen已经存在, 就继续运行否则创建
if [ "$isContainer" != "" ]; then
  # 进入创建的screen
  # screen -r $screenName
  echo "进入名字为${screenName}的窗口..\n"

  # 每天早上10点获取文件内容
  while [ 1 ]; do
    echo "如果到了${hour}点, 自动抓取hosts文件, 现在时间:\n--`date +\"%H:%M:%S\"`\n"
    if [ `date +%H` -eq $hour ]; then
      echo "更新 hosts..\n"
      if [ -e "$localHostsUrl" ]; then
        # 先拷贝一份hosts文件作为备份
        # sudo cp "$localHostsUrl" "/etc/hosts`date +\"%H:%M:%S\"`"
        # curl $hostsUrl > $localHostsUrl
        # sudo sed -i -n '/github/p' $localHostsUrl
        # sudo sed -i -n '/github/d' $localHostsUrl
        replaceHosts;
        echo "更新成功.. \n`date +\"%x %T\"`\n"
        # exit 0
      else
        echo "请确认 ${localHostsUrl} 存在并且有写入权限!\n"
        exit 0
      fi
    fi

    sleep 3600s;
  done
else
  echo "创建名字为 ${screenName} 的screen窗口..\n"
  screen -dmS $screenName
  screen -x $screenName -p 0 -X stuff "$0"
  screen -x $screenName -p 0 -X stuff $'\n'
  echo "创建成功..\n"

  replaceHosts;
fi
