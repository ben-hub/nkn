#!/bin/bash
initEnv(){
PSWD=$RANDOM
ARCHcase=$(uname -m)
case $ARCHcase in
armv5*) ARCH="arm";;
armv6*) ARCH="arm";;
armv7*) ARCH="arm";;
aarch64) ARCH="arm64";;
x86) ARCH="386";;
x86_64) ARCH="amd64";;
i686) ARCH="386";;
i386) ARCH="386";;
*) echo -e "\033[31mThis system is not supported, script exits！\033[0m"&&exit 1;;
esac
if which apt >>/dev/null 2>&1
then
 PG="apt"
elif which yum >>/dev/null 2>&1
then
 PG="yum"
else
 echo -e "\033[31mThis system is not supported, script exits！\033[0m"
 exit 1
fi
}
choose(){
echo -e "\t1) run as base ,only one(直接运行安装，只能单开)"
echo -e "\t2) run nkn in docker,more(基于docker多开，需要多拨路由进行源IP分流)"
read -p "choose [1|2]:" CHOOSE
case $CHOOSE in
1 ) initNKNMing;;
2 ) inDocker ;;
* ) echo -e "\033[31mNO Choose(未选择)\033[0m";;
esac
}
inDocker(){
clear
echo
echo "==============================================================================================================="
echo "                                            Welcome to this script!"
echo "==============================================================================================================="
echo
echo "This script will automatically continuously deploy containers from the first IP address to the last IP address."
echo "So please reserve IP address, and port mapping."
echo "==============================================================================================================="
echo "                                                                                                         By Ben"
read -p "First IP address(1-254)第一个IP地址:" IP_ONE
read -p "End IP Address(1-254)最后一个IP地址:" IP_END
read -p "Input Gateway Address(1-254)输入网关地址:" IP_GW
echo
echo "Initialize the system..."
echo "------------------------"
initEnv
case $ARCHcase in
armv6*) IMG="nknorg/nkn:latest-arm32v6";;
armv7*) IMG="nknorg/nkn:latest-arm32v6";;
aarch64) IMG="nknorg/nkn:latest-arm64v8";;
x86) IMG="nknorg/nkn:latest ";;
x86_64) IMG="nknorg/nkn:latest-amd64";;
i686) IMG="nknorg/nkn:latest ";;
i386) IMG="nknorg/nkn:latest ";;
*) echo -e "\033[31mThis system is not supported, script exits！\033[0m"&&exit 1;;
esac
$PG update -y >>/dev/null 2>&1 && $PG install net-tools wget curl unzip psmisc git -y >>/dev/null 2>&1
echo "system arch is $ARCH"
echo "Find $PG"
echo -e "\033[32mInitialization complete\033[0m"
installDocker
ETH=$(route | grep default | awk '{print $8}')
NET=$(route | grep $ETH |grep -v default |awk '{print $1}')
GW=$(echo ${NET%.*}.$IP_GW)
SUBNET=$(echo ${NET%.*}.0/24)
rm -rf /opt/nknorg/ >>/dev/null 2>&1
rm -rf /usr/bin/nkn* >>/dev/null 2>&1
mkdir -p /opt/nknorg >>/dev/null 2>&1
ifconfig $ETH promisc
getVER
checkdown
echo
echo "Download docker image..."
echo "------------------------"
docker pull $IMG >>/dev/null 2>&1
if [[ `docker image ls | grep nknorg` ]]
then
echo -e "\033[32mSuccessful download of Docker image. \033[0m"
else
echo -e "\033[31mDownload failed, please check the network! \033[0m"
exit 1
fi
echo
echo "Installing NKN..."
echo "------------------------"
docker network rm nkn-macvlan >>/dev/null 2>&1
docker network create -d macvlan --subnet=$SUBNET --gateway=$GW -o parent=$ETH nkn-macvlan >>/dev/null 2>&1
for(( i="$IP_ONE";i<="$IP_END";i=i+1))
do
MAC_ADDR=$(echo "88$(dd bs=1 count=5 if=/dev/random 2>/dev/null  |hexdump -v -e '/1 ":%02X"')")
IP=${SUBNET%.*}.$i
mkdir -p /opt/nknorg/docker/nkn$i/data >>/dev/null 2>&1
cp -rf /opt/nknorg/nknc /opt/nknorg/docker/nkn$i/. >>/dev/null 2>&1
cp -rf /opt/nknorg/nknd /opt/nknorg/docker/nkn$i/. >>/dev/null 2>&1
cp -rf /opt/nknorg/web /opt/nknorg/docker/nkn$i/. >>/dev/null 2>&1
cat <<EOF > /opt/nknorg/docker/nkn$i/data/config.json
{
"BeneficiaryAddr": "$addr",
"TxPoolTotalTxCap": 1000,
"TxPoolMaxMemorySize": 8,
"SeedList": [
 "http://mainnet-seed-0001.nkn.org:30003",
 "http://mainnet-seed-0002.nkn.org:30003",
 "http://mainnet-seed-0003.nkn.org:30003",
 "http://mainnet-seed-0004.nkn.org:30003",
 "http://mainnet-seed-0005.nkn.org:30003",
 "http://mainnet-seed-0006.nkn.org:30003",
 "http://mainnet-seed-0007.nkn.org:30003",
 "http://mainnet-seed-0008.nkn.org:30003",
 "http://mainnet-seed-0009.nkn.org:30003",
 "http://mainnet-seed-0010.nkn.org:30003",
 "http://mainnet-seed-0011.nkn.org:30003",
 "http://mainnet-seed-0012.nkn.org:30003",
 "http://mainnet-seed-0013.nkn.org:30003",
 "http://mainnet-seed-0014.nkn.org:30003",
 "http://mainnet-seed-0015.nkn.org:30003",
 "http://mainnet-seed-0016.nkn.org:30003",
 "http://mainnet-seed-0017.nkn.org:30003",
 "http://mainnet-seed-0018.nkn.org:30003",
 "http://mainnet-seed-0019.nkn.org:30003",
 "http://mainnet-seed-0020.nkn.org:30003",
 "http://mainnet-seed-0021.nkn.org:30003",
 "http://mainnet-seed-0022.nkn.org:30003",
 "http://mainnet-seed-0023.nkn.org:30003",
 "http://mainnet-seed-0024.nkn.org:30003",
 "http://mainnet-seed-0025.nkn.org:30003",
 "http://mainnet-seed-0026.nkn.org:30003",
 "http://mainnet-seed-0027.nkn.org:30003",
 "http://mainnet-seed-0028.nkn.org:30003",
 "http://mainnet-seed-0030.nkn.org:30003",
 "http://mainnet-seed-0031.nkn.org:30003",
 "http://mainnet-seed-0032.nkn.org:30003",
 "http://mainnet-seed-0033.nkn.org:30003",
 "http://mainnet-seed-0034.nkn.org:30003",
 "http://mainnet-seed-0035.nkn.org:30003",
 "http://mainnet-seed-0036.nkn.org:30003",
 "http://mainnet-seed-0037.nkn.org:30003",
 "http://mainnet-seed-0038.nkn.org:30003",
 "http://mainnet-seed-0039.nkn.org:30003",
 "http://mainnet-seed-0040.nkn.org:30003",
 "http://mainnet-seed-0041.nkn.org:30003",
 "http://mainnet-seed-0042.nkn.org:30003",
 "http://mainnet-seed-0043.nkn.org:30003",
 "http://mainnet-seed-0044.nkn.org:30003"
],
"GenesisBlockProposer": "a0309f8280ca86687a30ca86556113a253762e40eb884fc6063cad2b1ebd7de5"
}
EOF
chmod +x /opt/nknorg/docker/nkn$i/*
docker run -i -v /opt/nknorg/docker/nkn$i/:/nkn/ $IMG nknc wallet -c <<EOF >>/dev/null 2>&1
$PSWD
$PSWD
EOF
docker run -i -d --net=nkn-macvlan -v /opt/nknorg/docker/nkn$i/:/nkn/ --restart=always --ip=$IP --mac-address=$MAC_ADDR --name nkn$i $IMG nknd --no-nat -p $PSWD >>/dev/null 2>&1
sleep 3
if [[ `docker container inspect nkn$i --format "{{.State.Status}}"` == "created" ]]
then
echo -e "\033[31mCurrent environment may not support running multiple NKNs, script exit.\033[0m"
exit 1
else
echo "$IP Deployment completed"
fi
done
docker rm `docker ps -a | grep wallet |awk '{print $1}'` >> /dev/null 2>&1
echo -e "\033[32mAll containers have been successfully created. \033[0m"
echo
echo "Install Automatic Update Service..."
echo "------------------------"
cat <<\EOF > /opt/nknorg/update.sh
#!/bin/bash
initEnv(){
 ARCHcase=$(uname -m)
 case $ARCHcase in
 armv5*) ARCH="arm";;
 armv6*) ARCH="arm";;
 armv7*) ARCH="arm";;
 aarch64) ARCH="arm64";;
 x86) ARCH="386";;
 x86_64) ARCH="amd64";;
 i686) ARCH="386";;
 i386) ARCH="386";;
 *) echo -e "\033[31mThis system is not supported, script exits！\033[0m"&&exit 1;;
 esac
}
check(){
 initEnv
 NEWVER=$(curl -sL https://github.com/nknorg/nkn/releases | grep linux-$ARCH | head -1 | awk -F "/" '{print $6}')
 OLDVER=$(nknd -v | awk '{print $3}')
 if [ $NEWVER ]
 then
  if [ "$OLDVER" = "$NEWVER" ]
  then
   echo $(date +%F-%T) No updates found.
   exit 0
  else
   echo $(date +%F-%T) Discover the new version and update it automatically.
   downNkn
  fi
 else
  echo -e "\033[31m$(date +%F-%T) Failed to get new version.\033[0m"
  exit 1
 fi
}
downNkn(){
 rm -rf /tmp/linux*
 wget -t1 -T120 -P /tmp https://github.com/nknorg/nkn/releases/download/$NEWVER/linux-$ARCH.zip
 unzip /tmp/linux-$ARCH.zip -d /tmp
 initNKN
}
initNKN(){
 if [ ! -d "/tmp/linux-$ARCH/" ]
 then
  echo -e "\033[31m$(date +%F-%T)Update failed, try again\033[0m"
  downNkn
 else
  rm -rf /opt/nknorg/nknc
  rm -rf /opt/nknorg/nknd
  rm -rf /opt/nknorg/web
  cp -rf /tmp/linux-$ARCH/* /opt/nknorg
  rm -rf /tmp/linux*
  chmod +x /opt/nknorg/*
  restartDocker
  echo -e "\033[32m$(date +%F-%T) Nknd Update Successful.\033[0m"
 fi
}
restartDocker(){
 for line in $(ls -l /opt/nknorg/docker/ | grep nkn | awk -F " " '{print $9}')
 do
  rm -rf /opt/nknorg/docker/$line/nknc
  rm -rf /opt/nknorg/docker/$line/nknd
  rm -rf /opt/nknorg/docker/$line/web
  cp -rf /opt/nknorg/nknc /opt/nknorg/docker/$line/
  cp -rf /opt/nknorg/nknd /opt/nknorg/docker/$line/
  cp -rf /opt/nknorg/web /opt/nknorg/docker/$line/
  docker restart $line
 done
}
check
exit 0
EOF
cat <<EOF > /opt/nknorg/nkn-update.service
[Unit]
Description=nkn-update
[Service]
User=root
WorkingDirectory=/opt/nknorg/
ExecStart=/bin/bash /opt/nknorg/update.sh
Restart=always
RestartSec=60
LimitNOFILE=500000
[Install]
WantedBy=default.target
EOF
mv /opt/nknorg/nkn-update.service /etc/systemd/system/nkn-update.service
systemctl enable nkn-update.service >>/dev/null 2>&1
systemctl start nkn-update.service
sleep 3
if [[ `systemctl status nkn-update | grep running` ]] >> /dev/null 2>&1
then
echo -e "\033[32mNKN Update Service Created Successfully\033[0m"
else
echo -e "\033[31mNKN update service did not run successfully\033[0m"
fi
echo "Done."
}
installDocker(){
echo
echo "Installing docker..."
echo "------------------------"
if which docker >>/dev/null 2>&1
then
 echo -e "\033[32mDocker installed, skip\033[0m"
else
    OS=$(cat /etc/*release | grep PRETTY_NAME |awk -F '"' '{print $2}' |awk '{print $1}')
 case $OS in
 Ubuntu*) OS="ubuntu";;
 CentOS*) OS="centos";;
 Debian*) OS="debian";;
 *) echo -e "\033[31mRun the script again after installing docker manually\033[0m"&&exit 1;;
    esac
 if [[ "$PG" == "apt" ]]
 then
  apt install apt-transport-https ca-certificates curl gnupg2 irqbalance software-properties-common -y >>/dev/null 2>&1
  curl -fsSL http://mirrors.ustc.edu.cn/docker-ce/linux/$OS/gpg | apt-key add - >>/dev/null 2>&1
  add-apt-repository "deb [arch=$ARCH] http://mirrors.ustc.edu.cn/docker-ce/linux/$OS $(lsb_release -cs) stable" >>/dev/null 2>&1
  apt update -y >>/dev/null 2>&1
  apt install docker-ce -y >>/dev/null 2>&1
 elif [[ "$PG" == "yum" ]]
 then
  yum install -y yum-utils >>/dev/null 2>&1
  yum-config-manager --add-repo http://mirrors.ustc.edu.cn/docker-ce/linux/$OS/docker-ce.repo >>/dev/null 2>&1
  yum makecache >>/dev/null 2>&1
  yum install -y docker-ce >>/dev/null 2>&1
 fi
 systemctl enable docker.service >>/dev/null 2>&1
 systemctl start docker.service
 systemctl enable irqbalance >>/dev/null 2>&1
 systemctl start irqbalance
 if which docker >>/dev/null 2>&1
 then
   echo 'Docker Successful Installation'
 else
   echo -e "\033[31mDocker installation failed,Manual installation of docker and run the script again！（手动安装Docker，再次运行脚本）\033[0m"
   exit 1
 fi
fi
}
initNKNMing(){
clear
echo
echo "============================================================================================"
echo "                                   Welcome to this script!                                  "
echo "============================================================================================"
echo
echo "After the script is deployed, NKN nodes and NKN update services are automatically generated."
echo "============================================================================================"
echo "                                                                                      By Ben"
echo "Initialize the system..."
echo "------------------------"
initEnv
$PG update -y >>/dev/null 2>&1 && $PG install net-tools wget curl unzip psmisc -y >>/dev/null 2>&1
rm -rf /opt/nknorg >>/dev/null 2>&1
rm -rf /usr/bin/nkn* >>/dev/null 2>&1
mkdir -p /opt/nknorg >>/dev/null 2>&1
echo "system arch is $ARCH"
echo "Find $PG"
echo -e "\033[32mInitialization complete\033[0m"
getVER
checkdown
echo
echo "Installing NKN..."
echo "------------------------"
cat <<EOF > /opt/nknorg/config.json
{
"BeneficiaryAddr": "$addr",
"TxPoolTotalTxCap": 1000,
"TxPoolMaxMemorySize": 8,
"SeedList": [
 "http://mainnet-seed-0001.nkn.org:30003",
 "http://mainnet-seed-0002.nkn.org:30003",
 "http://mainnet-seed-0003.nkn.org:30003",
 "http://mainnet-seed-0004.nkn.org:30003",
 "http://mainnet-seed-0005.nkn.org:30003",
 "http://mainnet-seed-0006.nkn.org:30003",
 "http://mainnet-seed-0007.nkn.org:30003",
 "http://mainnet-seed-0008.nkn.org:30003",
 "http://mainnet-seed-0009.nkn.org:30003",
 "http://mainnet-seed-0010.nkn.org:30003",
 "http://mainnet-seed-0011.nkn.org:30003",
 "http://mainnet-seed-0012.nkn.org:30003",
 "http://mainnet-seed-0013.nkn.org:30003",
 "http://mainnet-seed-0014.nkn.org:30003",
 "http://mainnet-seed-0015.nkn.org:30003",
 "http://mainnet-seed-0016.nkn.org:30003",
 "http://mainnet-seed-0017.nkn.org:30003",
 "http://mainnet-seed-0018.nkn.org:30003",
 "http://mainnet-seed-0019.nkn.org:30003",
 "http://mainnet-seed-0020.nkn.org:30003",
 "http://mainnet-seed-0021.nkn.org:30003",
 "http://mainnet-seed-0022.nkn.org:30003",
 "http://mainnet-seed-0023.nkn.org:30003",
 "http://mainnet-seed-0024.nkn.org:30003",
 "http://mainnet-seed-0025.nkn.org:30003",
 "http://mainnet-seed-0026.nkn.org:30003",
 "http://mainnet-seed-0027.nkn.org:30003",
 "http://mainnet-seed-0028.nkn.org:30003",
 "http://mainnet-seed-0029.nkn.org:30003",
 "http://mainnet-seed-0030.nkn.org:30003",
 "http://mainnet-seed-0031.nkn.org:30003",
 "http://mainnet-seed-0032.nkn.org:30003",
 "http://mainnet-seed-0033.nkn.org:30003",
 "http://mainnet-seed-0034.nkn.org:30003",
 "http://mainnet-seed-0035.nkn.org:30003",
 "http://mainnet-seed-0036.nkn.org:30003",
 "http://mainnet-seed-0037.nkn.org:30003",
 "http://mainnet-seed-0038.nkn.org:30003",
 "http://mainnet-seed-0039.nkn.org:30003",
 "http://mainnet-seed-0040.nkn.org:30003",
 "http://mainnet-seed-0041.nkn.org:30003",
 "http://mainnet-seed-0042.nkn.org:30003",
 "http://mainnet-seed-0043.nkn.org:30003",
 "http://mainnet-seed-0044.nkn.org:30003"
 ],
"GenesisBlockProposer": "a0309f8280ca86687a30ca86556113a253762e40eb884fc6063cad2b1ebd7de5"
}
EOF
rm -rf /usr/bin/nkn* >>/dev/null 2>&1
ln -s /opt/nknorg/nknd /usr/bin/ >>/dev/null 2>&1
ln -s /opt/nknorg/nknc /usr/bin/ >>/dev/null 2>&1
nknc wallet -n /opt/nknorg/wallet.json -c <<EOF >>/dev/null 2>&1
$PSWD
$PSWD
EOF
initMonitor
checkinstall
}
initMonitor(){
cat <<\EOF > /opt/nknorg/update.sh
#!/bin/bash
initEnv(){
 ARCHcase=$(uname -m)
 case $ARCHcase in
 armv5*) ARCH="arm";;
 armv6*) ARCH="arm";;
 armv7*) ARCH="arm";;
 aarch64) ARCH="arm64";;
 x86) ARCH="386";;
 x86_64) ARCH="amd64";;
 i686) ARCH="386";;
 i386) ARCH="386";;
 *) echo -e "\033[31mThis system is not supported, script exits！\033[0m"&&exit 1;;
 esac
}
check(){
 initEnv
 OLDVER=$(nknd -v | awk -F " " '{print $3}')
 NEWVER=$(curl -sL https://github.com/nknorg/nkn/releases | grep linux-$ARCH | head -1 | awk -F "/" '{print $6}')
 if [ $NEWVER ]
 then
  if [ "$OLDVER" = "$NEWVER" ]
  then
   echo $(date +%F-%T) No updates found.
   exit 0
  else
   echo $(date +%F-%T) Discover the new version and update it automatically.
   downNkn
  fi
 else
  echo -e "\033[31m$(date +%F-%T) Failed to get new version.\033[0m"
  exit 1
 fi
}
downNkn(){
 rm -rf /tmp/linux*
 wget -t1 -T120 -P /tmp https://github.com/nknorg/nkn/releases/download/$NEWVER/linux-$ARCH.zip
 unzip /tmp/linux-$ARCH.zip -d /tmp
 initNKN
}
initNKN(){
 if [ ! -d "/tmp/linux-$ARCH/" ]
 then
  echo -e "\033[31m$(date +%F" "%T) Update failed, try again\033[0m"
  downNkn
 else
  systemctl stop nkn-node.service
  rm -rf /opt/nknorg/nknc
  rm -rf /opt/nknorg/nknd
  rm -rf /opt/nknorg/web
  cp -rf /tmp/linux-$ARCH/* /opt/nknorg
  chmod +x /opt/nknorg/*
  checkupdate
 fi
}
checkupdate(){
 VER=$(nknd -v | awk -F " " '{print $3}')
 if [ "$VER" = "$NEWVER" ]
 then
  systemctl start nkn-node.service
  echo -e "\033[32m$(date +%F" "%T) Nknd Update Successful.\033[0m"
 else
  echo -e "\033[31m$(date +%F" "%T) Update failed, try again\033[0m"
  check
 fi
}
check
exit 0
EOF
cat <<EOF > /opt/nknorg/nkn-node.service
[Unit]
Description=nkn-node
[Service]
User=root
WorkingDirectory=/opt/nknorg/
ExecStart=/opt/nknorg/nknd --no-nat -p $PSWD
Restart=always
RestartSec=3
LimitNOFILE=500000
[Install]
WantedBy=default.target
EOF
cat <<EOF > /opt/nknorg/nkn-update.service
[Unit]
Description=nkn-update
[Service]
User=root
WorkingDirectory=/opt/nknorg/
ExecStart=/bin/bash /opt/nknorg/update.sh
Restart=always
RestartSec=60
LimitNOFILE=500000
[Install]
WantedBy=default.target
EOF
mv /opt/nknorg/nkn-node.service /etc/systemd/system/nkn-node.service
mv /opt/nknorg/nkn-update.service /etc/systemd/system/nkn-update.service
systemctl enable nkn-node.service >>/dev/null 2>&1
systemctl enable nkn-update.service >>/dev/null 2>&1
systemctl start nkn-node.service >>/dev/null 2>&1
systemctl start nkn-update.service >>/dev/null 2>&1
}
getVER(){
echo
echo "Get to NKN version..."
echo "------------------------"
VERSION=$(curl -sL https://github.com/nknorg/nkn/releases | grep linux-$ARCH | head -1 | awk -F "/" '{print $6}')
if [ $VERSION ]
then
 echo -e "\033[32mSuccessful get to NKN version $VERSION.\033[0m"
else
 echo -e "\033[31mFailed to obtain version, please check whether the network is smooth.\033[0m"
 exit 1
fi
}
downNkn(){
echo
echo "Download NKN program..."
echo "------------------------"
rm -rf /tmp/linux*
wget -t1 -T120 -P /tmp https://github.com/nknorg/nkn/releases/download/$VERSION/linux-$ARCH.zip >>/dev/null 2>&1
unzip /tmp/linux-$ARCH.zip -d /tmp >>/dev/null 2>&1
checkdown
}
checkdown(){
if [ ! -d "/tmp/linux-$ARCH/" ]
then
 echo -e "\033[31mDownload failed, try again.\033[0m"
 downNkn
else
 cp -rf /tmp/linux-$ARCH/* /opt/nknorg >>/dev/null 2>&1
 chmod +x /opt/nknorg/* >>/dev/null 2>&1
 ln -s /opt/nknorg/nknd /usr/bin/nknd >>/dev/null 2>&1
 ln -s /opt/nknorg/nknc /usr/bin/nknc >>/dev/null 2>&1
 echo -e "\033[32mNKN Download Successful.\033[0m"
fi
}
checkinstall(){
sleep 5
status=$(systemctl status nkn-node.service | grep running)
if [[ "$status" = "" ]]
then
 echo "Install failed(安装失败)"
 exit 1
else
 echo -e "\033[32mInstalled successfully\033[0m"
 echo -e "\033[32mWait about 10 minutes,Run 'nknc info -s' command to view node status.\033[0m"
 exit 0
fi
}
read -p "Wallet address(受益人地址):" addr
if [[ "$addr" = "" ]]
then
 echo -e "\033[31mWallet Address error\033[0m"
 exit 1
else
 head=$(echo $addr | cut -b 1-3)
 if [[ "$head" = "NKN" ]]
 then
  choose
 else
  echo -e "\033[31mWallet Address error\033[0m"
  exit 1
 fi
fi

sync
