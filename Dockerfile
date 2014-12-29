FROM ubuntu
MAINTAINER Ryan "shiymail@gmail.com"
RUN apt-get -qq update

RUN apt-get install -y build-essential
RUN apt-get install -y zip
RUN apt-get install -y wget
RUN apt-get install -y gcc
RUN apt-get install -y make
RUN apt-get install -y curl
RUN apt-get install -y libpcre3-dev
RUN apt-get install -y openssl
RUN apt-get install -y libssl-dev

RUN wget -O /tmp/nginx-1.6.2.tar.gz wget http://nginx.org/download/nginx-1.6.2.tar.gz
RUN wget -O /tmp/LuaJIT-2.0.3.tar.gz http://luajit.org/download/LuaJIT-2.0.3.tar.gz
RUN wget -O /tmp/lua-nginx-module-0.9.13.zip https://github.com/openresty/lua-nginx-module/archive/v0.9.13.zip
RUN wget -O /tmp/ngx_devel_kit-0.2.19.zip https://github.com/simpl/ngx_devel_kit/archive/v0.2.19.zip
RUN wget -O /tmp/ngx_cache_purge-2.3.tar.gz http://labs.frickle.com/files/ngx_cache_purge-2.3.tar.gz

#COPY ./nginx-1.6.2.tar.gz /tmp/nginx-1.6.2.tar.gz
#COPY ./LuaJIT-2.0.3.tar.gz /tmp/LuaJIT-2.0.3.tar.gz
#COPY ./lua-nginx-module-0.9.13.zip /tmp/lua-nginx-module-0.9.13.zip
#COPY ./ngx_devel_kit-0.2.19.zip /tmp/ngx_devel_kit-0.2.19.zip
#COPY ./ngx_cache_purge-2.3.tar.gz /tmp/ngx_cache_purge-2.3.tar.gz

RUN ( cd /tmp/ && tar zxf nginx-1.6.2.tar.gz )
RUN ( cd /tmp/ && tar zxf LuaJIT-2.0.3.tar.gz )
RUN ( cd /tmp/ && tar zxf ngx_cache_purge-2.3.tar.gz )
RUN ( cd /tmp/ && unzip lua-nginx-module-0.9.13.zip )
RUN ( cd /tmp/ && unzip ngx_devel_kit-0.2.19.zip )

RUN rm -f /tmp/*.tar.gz
RUN rm -f /tmp/*.zip

RUN ( bash && \ 
      cd /tmp/LuaJIT-2.0.3 && \
      make && \
      make install )

RUN ( cd /tmp/nginx-1.6.2 && \
      export LUAJIT_LIB=/usr/local/lib && \
      export LUAJIT_INC=/usr/local/include/luajit-2.0 && \
      ./configure --prefix=/etc/nginx --with-ld-opt=-Wl,-rpath,/usr/local/lib --sbin-path=/usr/sbin/nginx --conf-path=/etc/nginx/nginx.conf --error-log-path=/var/log/nginx/error.log --http-log-path=/var/log/nginx/access.log --pid-path=/var/run/nginx.pid --lock-path=/var/run/nginx.lock --http-client-body-temp-path=/var/cache/nginx/client_temp --http-proxy-temp-path=/var/cache/nginx/proxy_temp --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp --http-scgi-temp-path=/var/cache/nginx/scgi_temp --with-http_ssl_module --with-http_realip_module --with-http_addition_module --with-http_sub_module --with-http_dav_module --with-http_flv_module --with-http_mp4_module --with-http_gunzip_module --with-http_gzip_static_module --with-http_random_index_module --with-http_secure_link_module --with-http_stub_status_module --with-http_auth_request_module --with-mail --with-mail_ssl_module --with-file-aio --with-ipv6 --with-http_spdy_module --add-module=../ngx_devel_kit-0.2.19 --add-module=../lua-nginx-module-0.9.13 --add-module=../ngx_cache_purge-2.3 && \
            make -j2 && \
            make install )

RUN ln -s /usr/local/lib/libluajit-5.1.so.2 /lib64/libluajit-5.1.so.2

RUN mkdir -p /etc/nginx/sites
RUN mkdir -p /etc/nginx/certs
RUN mkdir -p /var/cache/nginx/client_temp

RUN rm -rf /etc/nginx/sites-enabled
COPY ./nginx.conf /etc/nginx/nginx.conf

RUN rm -rf /tmp/*

WORKDIR /etc/nginx
VOLUME ["/etc/nginx/sites-enabled", "/etc/nginx/certs", "/etc/nginx/conf.d", "/var/log/nginx"]
EXPOSE 80
EXPOSE 443
CMD ["nginx"]

