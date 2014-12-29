docker-nginx
============

nginx with lua module

# Usage

* git clone this repo
* docker build -t yourname/nginx .

# volumn

* /etc/nginx/sites : put nginx conf file with "server {...}" here
* /etc/nginx/certs : ssl pem file here
* /var/log/nginx : log files


# Run

`docker run -d -p=80:80 -v /etc/localtime:/etc/localtime  -v /somedir/sites:/etc/nginx/sites --name=nginx your/nginx`
