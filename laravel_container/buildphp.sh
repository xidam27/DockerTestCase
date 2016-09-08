PHP_TARGET_VERSION=$1
echo Target Version: $PHP_TARGET_VERSION
PHP_INSTALL_PREFIX=$HOME/.phps
mkdir -p /tmp/src/php-$PHP_TARGET_VERSION
cd /tmp/src/php-$PHP_TARGET_VERSION
curl -# -L http://docs.php.net/distributions/php-$PHP_TARGET_VERSION.tar.gz | tar -xz --strip 1
./configure \
            --prefix=$PHP_INSTALL_PREFIX/$PHP_TARGET_VERSION \
            --with-config-file-path=$PHP_INSTALL_PREFIX/$PHP_TARGET_VERSION/etc \
            --mandir=$PHP_INSTALL_PREFIX/$PHP_TARGET_VERSION/share/man \
            --disable-debug \
            --enable-bcmath \
            --enable-calendar \
            --enable-cli \
            --enable-exif \
            --enable-fpm \
            --enable-ftp \
            --enable-gd-native-ttf \
            --enable-libxml \
            --enable-mbstring \
            --enable-mbregex \
            --enable-pcntl \
            --enable-shmop \
            --enable-soap \
            --with-openssl \
            --enable-sockets \
            --enable-sysvmsg \
            --enable-sysvsem \
            --enable-sysvshm \
            --enable-wddx \
            --enable-zip \
            --with-bz2=/usr \
            --with-curl=/usr \
            --with-freetype-dir=/opt/local \
            --with-gd \
            --with-gettext \
            --with-iconv \
            --with-jpeg-dir=/usr \
            --with-libxml-dir=/usr/local \
            --with-mcrypt=/usr/local \
            --with-mysqli=mysqlnd \
