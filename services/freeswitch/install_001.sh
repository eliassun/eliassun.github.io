#! /bin/bash

sudo echo "progress 0% ... " > /home/ubuntu/install/progress.log

cd /home/ubuntu
mkdir install

sudo apt-get install -y libavformat-dev
sudo echo "progress 1% ... " > /home/ubuntu/install/progress.log
sudo apt-get install -y libswscale-dev
sudo echo "progress 2% ... " > /home/ubuntu/install/progress.log
sudo apt-get install -y libpq-dev
sudo echo "progress 3% ... " > /home/ubuntu/install/progress.log
sudo apt -y update
sudo echo "progress 10% ... " > /home/ubuntu/install/progress.log
sudo apt install -y git subversion build-essential autoconf automake libtool libncurses5 libncurses5-dev make libjpeg-dev libtool libtool-bin libsqlite3-dev libpcre3-dev libspeexdsp-dev libldns-dev libedit-dev yasm liblua5.2-dev libopus-dev cmake
sudo apt install -y libcurl4-openssl-dev libexpat1-dev libgnutls28-dev libtiff5-dev libx11-dev unixodbc-dev libssl-dev python-dev zlib1g-dev libasound2-dev libogg-dev libvorbis-dev libperl-dev libgdbm-dev libdb-dev uuid-dev libsndfile1-dev

sudo echo "progress 15% ... " > /home/ubuntu/install/progress.log

cd /usr/src
sudo git clone https://github.com/signalwire/libks.git
sudo echo "progress 18% ... " > /home/ubuntu/install/progress.log
cd libks
sudo cmake .
sudo make > /home/ubuntu/install/libks.make.log
sudo make install
sudo make clean
cd /usr/src
sudo rm -rf libks

sudo echo "progress 25% ... " > /home/ubuntu/install/progress.log
cd /usr/src
sudo git clone https://github.com/signalwire/signalwire-c.git
cd signalwire-c
sudo cmake .
sudo make > /home/ubuntu/install/signalwire-c.make.log
sudo make install
sudo make clean
cd /usr/src
sudo rm -rf signalwire-c

sudo echo "progress 30% ... " > /home/ubuntu/install/progress.log
sudo apt-get install -y libavformat-dev >> /home/ubuntu/install/libavformat.log
sudo apt-get install -y libswscale-dev >> /home/ubuntu/install/libavformat.log
sudo apt-get install -y libpq-dev >> /home/ubuntu/install/libavformat.log

sudo echo "progress 35% ... " > /home/ubuntu/install/progress.log
cd /usr/src
sudo wget https://launchpad.net/ubuntu/+archive/primary/+sourcefiles/ffmpeg/7:4.2.2-1ubuntu1/ffmpeg_4.2.2.orig.tar.xz
sudo tar -xf ffmpeg_4.2.2.orig.tar.xz
cd ffmpeg-4.2.2
sudo ./configure --enable-shared --enable-gpl  --enable-pic
sudo make > /home/ubuntu/install/ffmpeg_4.log
sudo make install >> /home/ubuntu/install/ffmpeg_4.log
cd /usr/src
sudo rm -rf ffmpeg_4.2.2.orig.tar.xz
sudo rm -rf ffmpeg-4.2.2


sudo echo "progress 40% ... " > /home/ubuntu/install/progress.log
cd /usr/src
sudo wget https://files.freeswitch.org/freeswitch-releases/freeswitch-1.10.3.-release.zip
sudo apt -y install unzip
sudo unzip freeswitch-1.10.3.-release.zip
sudo -rf freeswitch-1.10.3.-release.zip
cd freeswitch-1.10.3.-release/

sudo echo "progress 45% ... " > /home/ubuntu/install/progress.log
sudo ./configure -C > /home/ubuntu/install/freeswitch.configure-c.log
sudo make >  /home/ubuntu/install/freeswitch.make.log

sudo make install > /home/ubuntu/install/freeswitch.install.log

sudo echo "progress 50% ... " > /home/ubuntu/install/progress.log

sudo make mod_sofia-install > /home/ubuntu/install/freeswitch.mod_sofia.install.log

sudo echo "progress 60% ... " > /home/ubuntu/install/progress.log
sudo make all cd-sounds-install cd-moh-install >  /home/ubuntu/install/sound.make.log
sudo ln -s /usr/local/freeswitch/bin/freeswitch /usr/bin/
sudo ln -s /usr/local/freeswitch/bin/fs_cli /usr/bin
cd /usr/local

sudo groupadd freeswitch
sudo adduser --disabled-password  --quiet --system --home /usr/local/freeswitch --gecos "FreeSWITCH Voice/Video Service" --ingroup freeswitch freeswitch
sudo chown -R freeswitch:freeswitch /usr/local/freeswitch/
sudo chmod -R ug=rwX,o= /usr/local/freeswitch/
sudo chmod -R u=rwx,g=rx /usr/local/freeswitch/bin/

sudo echo "progress 65% ... " > /home/ubuntu/install/progress.log
cd  /home/ubuntu/install
sudo chmown -R
sudo wget https://eliassun.github.io/services/freeswitch/freeswitch.service
sudo cp freeswitch.service /etc/systemd/system/freeswitch.service
sudo chmod ugo+x /etc/systemd/system/freeswitch.service
sudo systemctl start freeswitch.service
sudo systemctl enable freeswitch.service
sudo systemctl status freeswitch.service > freeswitch.status

sudo echo "progress 70% ... " > /home/ubuntu/install/progress.log
sudo git clone https://github.com/eliassun/WebRTC.git
sudo cp ./WebRTC/conf/vars.xml /usr/local/freeswitch/conf/vars.xml
sudo cp ./WebRTC/conf/autoload_configs/verto.conf.xml /usr/local/freeswitch/conf/autoload_configs/verto.conf.xml
sudo cp ./WebRTC/conf/sip_profiles/internal.xml /usr/local/freeswitch/conf/sip_profiles/internal.xml
sudo cp ./WebRTC/conf/conf/sip_profiles/external.xml /usr/local/freeswitch/conf/sip_profiles/external.xml
sudo cp ./WebRTC/conf/autoload_configs/switch.conf.xml /usr/local/freeswitch/conf/autoload_configs/switch.conf.xml

sudo echo "progress 80% ... " > /home/ubuntu/install/progress.log
sudo systemctl restart freeswitch.service
sudo systemctl status freeswitch.service > freeswitch.status.2

sudo echo "progress 85% ... " > /home/ubuntu/install/progress.log
sudo apt-get install -y coturn
sudo cp /etc/turnserver.conf /etc/turnserver.conf.backup
echo listening-ip=0.0.0.0 >> /home/ubuntu/install/turnserver.conf
echo external-ip=$(curl -s http://checkip.amazonaws.com) >> /home/ubuntu/install/turnserver.conf
echo syslog >> /home/ubuntu/install/turnserver.conf
sudo cp /home/ubuntu/install/turnserver.conf /etc/turnserver.conf
sudo systemctl start coturn
sudo systemctl status coturn > /home/ubuntu/install/coturn.status
sudo lsof -n -P -i > /home/ubuntu/install/ports.log

sudo echo "progress 99% ... " > /home/ubuntu/install/progress.log
sudo -rf /usr/src/freeswitch-1.10.3.-release.zip
sudo -rf /usr/src/freeswitch-1.10.3*

sudo echo $(curl -s http://checkip.amazonaws.com) > /home/ubuntu/install/done.log
sudo echo "Done" >> /home/ubuntu/install/done.log

sudo echo "progress 100% . Done. " > /home/ubuntu/install/progress.log
