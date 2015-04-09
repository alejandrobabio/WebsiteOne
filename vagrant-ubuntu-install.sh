#!/usr/bin/env bash

# enable console colors
sed -i '1iforce_color_prompt=yes' ~/.bashrc

# disable docs during gem install
echo 'gem: --no-rdoc --no-ri' >> ~/.gemrc

# set locales
export LANGUAGE="en_US.UTF-8"
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

# essentials
sudo apt-get -y update
sudo apt-get install -y autoconf bison build-essential libssl-dev libyaml-dev libreadline6 libreadline6-dev zlib1g zlib1g-dev libcurl4-openssl-dev curl wget

# SQLite, Git and Node.js
sudo apt-get install -y libsqlite3-dev git nodejs

# Qt and xvfb-run for Capybara Webkit
sudo apt-get install -y libqtwebkit-dev xvfb

# ImageMagick and Rmagick
sudo apt-get install -y imagemagick libmagickwand-dev

# Postgres
#sudo apt-get install -y postgresql-9.3 postgresql-server-dev-9.3 postgresql-contrib-9.3 libpq-dev postgresql
sudo apt-get install -y libpq-dev postgresql
# need to edit /etc/postgresql/9.1/main/pg_hba.conf
# needs work to handle variable white space
#
sudo sed -i -e 's/local\s\+all\s\+postgres\s\+peer/local all postgres peer map=basic/g' /etc/postgresql/9.1/main/pg_hba.conf

# need to edit /etc/postgresql/9.1/main/pg_ident.conf
echo "basic vagrant postgres" | sudo tee -a /etc/postgresql/9.1/main/pg_ident.conf

sudo /etc/init.d/postgresql restart

# this needs to run in psql
psql postgres postgres << EOF
    UPDATE pg_database SET datallowconn = TRUE where datname = 'template0';
    \c template0
    UPDATE pg_database SET datistemplate = FALSE where datname = 'template1';
    drop database template1;
    create database template1 with template = template0 encoding = 'UNICODE'  LC_CTYPE = 'en_US.UTF-8' LC_COLLATE = 'C';
    UPDATE pg_database SET datistemplate = TRUE where datname = 'template1';
    \c template1
    UPDATE pg_database SET datallowconn = FALSE where datname = 'template0';
EOF

# Memcached
sudo apt-get install -y memcached

# Redis
sudo apt-get install -y redis-server

# rvm
gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
\curl -sSL https://get.rvm.io | bash
source ~/.rvm/scripts/rvm
rvm requirements
rvm install ruby-2.1.5
rvm use ruby-2.1.5 --default
ruby -v

# Phantomjs
sudo wget https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-1.9.7-linux-x86_64.tar.bz2 -P /usr/local/share --quiet
sudo tar xjf /usr/local/share/phantomjs-1.9.7-linux-x86_64.tar.bz2 -C /usr/local/share
sudo ln -s /usr/local/share/phantomjs-1.9.7-linux-x86_64/bin/phantomjs /usr/local/share/phantomjs
sudo ln -s /usr/local/share/phantomjs-1.9.7-linux-x86_64/bin/phantomjs /usr/local/bin/phantomjs
sudo ln -s /usr/local/share/phantomjs-1.9.7-linux-x86_64/bin/phantomjs /usr/bin/phantomjs

# cleanup
sudo apt-get clean

cd /WebsiteOne
gem install bundler
bundle install
bundle exec rake db:setup

# Cool Bash Prompt
echo 'export PS1="\[\033[32m\]\t\[\033[m\]-\[\033[31m\]\u\[\033[m\]@\[\033[36m\]\h\[\033[m\]:\[\033[33;1m\]\w\[\033[35m\]\$(__git_ps1)\[\033[37;0m\]\$ "' >> ~/.bashrc
