FROM ubuntu:14.04
MAINTAINER Morgan Rich

ENV DEBIAN_FRONTEND noninteractive

RUN sudo apt-get update
RUN sudo apt-get -y install curl libnotify-bin ruby software-properties-common build-essential
RUN sudo LC_ALL=C.UTF-8 add-apt-repository -y ppa:ondrej/php
RUN sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927
RUN echo "deb http://repo.mongodb.org/apt/ubuntu "$(lsb_release -sc)"/mongodb-org/3.2 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.2.list
RUN sudo apt-get update

RUN curl -sL https://deb.nodesource.com/setup_4.x | sudo bash -
RUN sudo apt-get install -y nodejs

RUN npm install -g bower gulp gulp-imagemin
RUN gem install bundler

RUN sudo DEBIAN_FRONTEND=noninteractive apt-get install -y php7.0 mongodb-org php7.0-mongo php7.0-common php7.0-gd php7.0-mysql php7.0-curl php7.0-json php7.0-readline php7.0-cli php7.0-mbstring php7.0-mcrypt php7.0-mongodb php7.0-mysql php7.0-xml php7.0-zip

RUN sudo curl -sS https://getcomposer.org/installer | php
RUN sudo mv composer.phar /usr/local/bin/composer

RUN { \
    echo mysql-community-server mysql-community-server/data-dir select ''; \
    echo mysql-community-server mysql-community-server/root-pass password ''; \
    echo mysql-community-server mysql-community-server/re-root-pass password ''; \
    echo mysql-community-server mysql-community-server/remove-test-db select false; \
  } | debconf-set-selections \
  && apt-get update && apt-get install -y mysql-server && sudo service mysql start && mysql -u root -e "CREATE USER 'homestead'@'localhost' IDENTIFIED BY 'secret';" \
  && mysql -u root -e "GRANT ALL PRIVILEGES ON *.* TO 'homestead'@'localhost' WITH GRANT OPTION;"

EXPOSE 3306
ENV DEBIAN_FRONTEND teletype

CMD ["/usr/bin/mongod", "--config", "/etc/mongod.conf", "--fork", "--logpath", "/var/log/mongod.log"]

ENTRYPOINT "/bin/bash"
