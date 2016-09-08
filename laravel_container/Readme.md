Hello Abdul,

First of all, I am sorry over the confusion. I did not realize your refer to https://github.com/laravel/framework/tree/5.3/tests folder until I discovered it. I did not know I was missing something.

I managed to build a docker image with multiple php versions and with php-version tool to switch between them.
Unfortunately the current version of phpunit is only compatible with PHP version >5.6, so I could only run the tests using version 7.0.10.

I decided to build a new image based on Ubuntu since the compilation of the PHP takes too long to run it each time you start a container.
It would be even better to map a local folder that contains the compiled versions of the PHP to the container to keep the image size maintainable.


RUN UBUNTU AND REDIS CONTAINER
'''
# docker run -d ubuntu
# docker run -p 6379:6379 redis
# docker exec -it ubuntu_cont_id bash
'''

ALL WORKED IS DONE ON THE UBUNTU CONTAINER

INSTALL REQUIRED PACKAGES FOR BUILDING PHP WITH MOST OF THE OPTIONS
# apt update && apt install -y gcc libxml2-dev libssl-dev libsslcommon2-dev pkg-config libbz2-dev libjpeg-dev libpng12-dev libfreetype6-dev libmcrypt-dev libcurl3 libcurl4-openssl-dev libtidy-dev libldb-dev libxslt1-dev git curl vim autoconf libmemcached 

# ver=5.5.6; sh ./buildphp.sh $ver && cd /tmp/src/php-${ver}/ && make install
# ver=7.0.10; sh ./buildphp.sh $ver && cd /tmp/src/php-${ver}/ && make install

CHECKING IF EVERYTHING IS IN PLACE
'''
# ls -la $HOME/.phps/
total 16
drwxr-xr-x  4 root root 4096 Sep  7 17:03 .
drwx------  5 root root 4096 Sep  7 16:58 ..
drwxr-xr-x 10 root root 4096 Sep  7 16:25 5.5.6
drwxr-xr-x  9 root root 4096 Sep  7 17:03 7.0.10
'''

INSTALL PHP-VERSION
'''
# mkdir -p $HOME/local/php-version # or your place of choice
# cd !$
# curl -# -L https://github.com/wilmoore/php-version/tarball/master | tar -xz --strip 1
source $HOME/local/php-version/php-version.sh && php-version 5
# php-version
* 5.5.6
  7.0.10
'''
INSTALL MEMCACHED FOR PHP 5.5
'''
# php-version 5
# pecl install memcache
'''

INSTALL MEMCACHED FOR PHP 7.0
'''
# php-version 7
# git clone https://github.com/php-memcached-dev/php-memcached.git
# git checkout php7
# cd php-memcached/
# phpize
# ./configure --disable-memcached-sasl
# cd .. && rm -rf memcached 


for i in `ls $HOME/.phps/ `; do echo "extension=memcached.so" >> $HOME/.phps/${i}/etc/php.ini; done;
'''

INSTALLING PHPREDIS FOR PHP 5.5
'''
# ver=5.5.6; 
# php-version $ver 
# git clone https://github.com/phpredis/phpredis.git 
# cd phpredis 
# phpize 
# ./configure 
# make && make install 
# echo "extension=redis.so" >> $HOME/.phps/${ver}/etc/php.ini 
# cd .. && rm -rf phpredis 
'''

INSTALLING PHPREDIS FOR PHP 7.0.10
'''
# ver=7.0.10; 
# php-version $ver
# pecl install redis
# echo "extension=redis.so" >> $HOME/.phps/${ver}/etc/php.ini 
'''
INSTALLING COMPOSER
'''
# curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
'''

INSTALLING LARAVEL
'''
# composer global require "laravel/installer"
'''
INSTALLING PHPUNIT (NOT NEEDED IT)
'''
# wget https://phar.phpunit.de/phpunit.phar
# chmod +x phpunit.phar
# mv phpunit.phar /usr/local/bin/phpunit
# phpunit --version
'''
CREATING NEW PROJECT
'''
# cd /var/www/
# git clone https://github.com/laravel/framework.git # downloads the tests folder, but need vendor folder. I will get it from a new project
# mkdir laratemp && cd $_
# composer create-project --prefer-dist laravel/framework
# mv framework/vendor ../framework/ && cd $_
'''
need to uncomment redis env variables in phpunit.xml to set the IP of redis container, later I will TODO

DEBUG #1
'''
rob@c7a9a7746d7e:/var/www/framework/framework$ phpunit
PHPUnit 5.5.4 by Sebastian Bergmann and contributors.

Runtime:       PHP 7.0.10
Configuration: /var/www/framework/framework/phpunit.xml

.............................................................   61 / 2426 (  2%)
.............................................................  122 / 2426 (  5%)
.............................................................  183 / 2426 (  7%)
...............................................               2426 / 2426 (100%)


Time: 2.23 seconds, Memory: 76.00MB
There were 2 failures:

1) SupportCollectionTest::testArrayAccessOffsetGetOnNonExist
Failed asserting that exception of type "PHPUnit_Framework_Error_Notice" is thrown.

2) SupportCollectionTest::testArrayAccessOffsetUnset
Failed asserting that exception of type "PHPUnit_Framework_Error_Notice" is thrown.

'''
TROUBLESHOOT #1
'''
# for i in `ls $HOME/.phps/ `; do echo "error_reporting = E_ALL" >> $HOME/.phps/${ver}/etc/php.ini; done;
'''
(It worked)

DEBUG #2
'''
rob@c7a9a7746d7e:/var/www/framework/framework$ phpunit
PHPUnit 5.5.4 by Sebastian Bergmann and contributors.

Runtime:       PHP 7.0.10
Configuration: /var/www/framework/framework/phpunit.xml

.............................................................   61 / 2426 (  2%)
.............................................................  122 / 2426 (  5%)
.............................................................  183 / 2426 (  7%)
.............................................................  244 / 2426 ( 10%)
.............................................................  305 / 2426 ( 12%)
.............................................................  366 / 2426 ( 15%)
.............................................................  427 / 2426 ( 17%)
.............................................................  488 / 2426 ( 20%)
.............................................................  549 / 2426 ( 22%)
.............................................................  610 / 2426 ( 25%)
.............................................................  671 / 2426 ( 27%)
.............................................................  732 / 2426 ( 30%)
.............................................................  793 / 2426 ( 32%)
.............................................................  854 / 2426 ( 35%)
.............................................................  915 / 2426 ( 37%)
.............................................................  976 / 2426 ( 40%)
............................................................. 1037 / 2426 ( 42%)
............................................................. 1098 / 2426 ( 45%)
............................................................. 1159 / 2426 ( 47%)
............................................................. 1220 / 2426 ( 50%)
............................................................. 1281 / 2426 ( 52%)
............................................................. 1342 / 2426 ( 55%)
............................................................. 1403 / 2426 ( 57%)
............................................................. 1464 / 2426 ( 60%)
............................................................. 1525 / 2426 ( 62%)
............................................................. 1586 / 2426 ( 65%)
............................................................. 1647 / 2426 ( 67%)
............................................................. 1708 / 2426 ( 70%)
............................................................. 1769 / 2426 ( 72%)
............................................................. 1830 / 2426 ( 75%)
............................................................. 1891 / 2426 ( 77%)
............................................................. 1952 / 2426 ( 80%)
............................................................. 2013 / 2426 ( 82%)
............................................................. 2074 / 2426 ( 85%)
............................................................. 2135 / 2426 ( 88%)
............................................................. 2196 / 2426 ( 90%)
............................................................. 2257 / 2426 ( 93%)
............................................................. 2318 / 2426 ( 95%)
............................................................. 2379 / 2426 ( 98%)
...............................................               2426 / 2426 (100%)

Time: 2.25 seconds, Memory: 76.00MB

OK (2426 tests, 5470 assertions)
rob@c7a9a7746d7e:/var/www/framework/framework$


'''
INSTALLING COMPOSE
'''
# curl -L https://github.com/docker/compose/releases/download/1.8.0/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
'''

HOST CONFIGS:
'''
robert@ubuntu:~$ cat docker-compose.yml
version: '2'
services:
  php:
    build: .
    ports:
    - "80:8000"
    depends_on:
    - red
    links:
    - red:redis
    container_name: php
  red:
    image: redis
    container_name: redis
'''

robert@ubuntu:~$ cat Dockerfile

'''
FROM xidam/laratest:1.1
WORKDIR /var/www/framework
USER rob
RUN bash -c 'source $HOME/local/php-version/php-version.sh; php-version 7 && phpunit'
'''

TEST RESULTS WITH DOCKER-COMPOSE

'''
robert@ubuntu:~$ sudo docker-compose up
Building php
Step 1 : FROM xidam/laratest:1.1
 ---> ac829d18bb09
Step 2 : WORKDIR /var/www/framework
 ---> Running in 82bce7dee7d9
 ---> 077c23a0e545
Removing intermediate container 82bce7dee7d9
Step 3 : USER rob
 ---> Running in d4e451155ebc
 ---> a55198875ab7
Removing intermediate container d4e451155ebc
Step 4 : RUN bash -c 'source $HOME/local/php-version/php-version.sh; php-version 7 && phpunit'
 ---> Running in fc4712de223d
tput: No value for $TERM and no -T specified
tput: No value for $TERM and no -T specified
PHPUnit 5.5.4 by Sebastian Bergmann and contributors.

Runtime:       PHP 7.0.10
Configuration: /var/www/framework/phpunit.xml
'''

```
.............................................................   61 / 2426 (  2%)
.............................................................  122 / 2426 (  5%)
.............................................................  183 / 2426 (  7%)
.............................................................  244 / 2426 ( 10%)
.............................................................  305 / 2426 ( 12%)
.............................................................  366 / 2426 ( 15%)
.............................................................  427 / 2426 ( 17%)
.............................................................  488 / 2426 ( 20%)
.............................................................  549 / 2426 ( 22%)
.............................................................  610 / 2426 ( 25%)
.............................................................  671 / 2426 ( 27%)
.............................................................  732 / 2426 ( 30%)
.............................................................  793 / 2426 ( 32%)
.............................................................  854 / 2426 ( 35%)
.............................................................  915 / 2426 ( 37%)
.............................................................  976 / 2426 ( 40%)
............................................................. 1037 / 2426 ( 42%)
............................................................. 1098 / 2426 ( 45%)
............................................................. 1159 / 2426 ( 47%)
............................................................. 1220 / 2426 ( 50%)
............................................................. 1281 / 2426 ( 52%)
............................................................. 1342 / 2426 ( 55%)
............................................................. 1403 / 2426 ( 57%)
............................................................. 1464 / 2426 ( 60%)
....................EEEEEEEEEE............................... 1525 / 2426 ( 62%)
............................................................. 1586 / 2426 ( 65%)
............................................................. 1647 / 2426 ( 67%)
............................................................. 1708 / 2426 ( 70%)
............................................................. 1769 / 2426 ( 72%)
............................................................. 1830 / 2426 ( 75%)
............................................................. 1891 / 2426 ( 77%)
............................................................. 1952 / 2426 ( 80%)
............................................................. 2013 / 2426 ( 82%)
............................................................. 2074 / 2426 ( 85%)
............................................................. 2135 / 2426 ( 88%)
............................................................. 2196 / 2426 ( 90%)
............................................................. 2257 / 2426 ( 93%)
............................................................. 2318 / 2426 ( 95%)
............................................................. 2379 / 2426 ( 98%)
...............................................               2426 / 2426 (100%)

Time: 17.41 seconds, Memory: 76.00MB
```
'''

There were 10 errors:

1) RedisQueueIntegrationTest::testExpiredJobsArePopped
Predis\Connection\ConnectionException: Connection timed out [tcp://172.17.0.50:6379]

/var/www/framework/vendor/predis/predis/src/Connection/AbstractConnection.php:155
/var/www/framework/vendor/predis/predis/src/Connection/StreamConnection.php:128
/var/www/framework/vendor/predis/predis/src/Connection/StreamConnection.php:178
/var/www/framework/vendor/predis/predis/src/Connection/StreamConnection.php:100
/var/www/framework/vendor/predis/predis/src/Connection/AbstractConnection.php:81
/var/www/framework/vendor/predis/predis/src/Connection/StreamConnection.php:258
/var/www/framework/vendor/predis/predis/src/Connection/AbstractConnection.php:180
/var/www/framework/vendor/predis/predis/src/Connection/StreamConnection.php:288
/var/www/framework/vendor/predis/predis/src/Connection/StreamConnection.php:394
/var/www/framework/vendor/predis/predis/src/Connection/AbstractConnection.php:110
/var/www/framework/vendor/predis/predis/src/Client.php:331
/var/www/framework/vendor/predis/predis/src/Client.php:314
/var/www/framework/src/Illuminate/Queue/RedisQueue.php:114
/var/www/framework/tests/Queue/RedisQueueIntegrationTest.php:82

2) RedisQueueIntegrationTest::testPopProperlyPopsJobOffOfRedis
Predis\Connection\ConnectionException: Connection timed out [tcp://172.17.0.50:6379]

/var/www/framework/vendor/predis/predis/src/Connection/AbstractConnection.php:155
/var/www/framework/vendor/predis/predis/src/Connection/StreamConnection.php:128
/var/www/framework/vendor/predis/predis/src/Connection/StreamConnection.php:178
/var/www/framework/vendor/predis/predis/src/Connection/StreamConnection.php:100
/var/www/framework/vendor/predis/predis/src/Connection/AbstractConnection.php:81
/var/www/framework/vendor/predis/predis/src/Connection/StreamConnection.php:258
/var/www/framework/vendor/predis/predis/src/Connection/AbstractConnection.php:180
/var/www/framework/vendor/predis/predis/src/Connection/StreamConnection.php:288
/var/www/framework/vendor/predis/predis/src/Connection/StreamConnection.php:394
/var/www/framework/vendor/predis/predis/src/Connection/AbstractConnection.php:110
/var/www/framework/vendor/predis/predis/src/Client.php:331
/var/www/framework/vendor/predis/predis/src/Client.php:314
/var/www/framework/src/Illuminate/Queue/RedisQueue.php:95
/var/www/framework/src/Illuminate/Queue/RedisQueue.php:82
/var/www/framework/tests/Queue/RedisQueueIntegrationTest.php:100

3) RedisQueueIntegrationTest::testPopProperlyPopsDelayedJobOffOfRedis
Predis\Connection\ConnectionException: Connection timed out [tcp://172.17.0.50:6379]

/var/www/framework/vendor/predis/predis/src/Connection/AbstractConnection.php:155
/var/www/framework/vendor/predis/predis/src/Connection/StreamConnection.php:128
/var/www/framework/vendor/predis/predis/src/Connection/StreamConnection.php:178
/var/www/framework/vendor/predis/predis/src/Connection/StreamConnection.php:100
/var/www/framework/vendor/predis/predis/src/Connection/AbstractConnection.php:81
/var/www/framework/vendor/predis/predis/src/Connection/StreamConnection.php:258
/var/www/framework/vendor/predis/predis/src/Connection/AbstractConnection.php:180
/var/www/framework/vendor/predis/predis/src/Connection/StreamConnection.php:288
/var/www/framework/vendor/predis/predis/src/Connection/StreamConnection.php:394
/var/www/framework/vendor/predis/predis/src/Connection/AbstractConnection.php:110
/var/www/framework/vendor/predis/predis/src/Client.php:331
/var/www/framework/vendor/predis/predis/src/Client.php:314
/var/www/framework/src/Illuminate/Queue/RedisQueue.php:114
/var/www/framework/tests/Queue/RedisQueueIntegrationTest.php:128

4) RedisQueueIntegrationTest::testPopPopsDelayedJobOffOfRedisWhenExpireNull
Predis\Connection\ConnectionException: Connection timed out [tcp://172.17.0.50:6379]

/var/www/framework/vendor/predis/predis/src/Connection/AbstractConnection.php:155
/var/www/framework/vendor/predis/predis/src/Connection/StreamConnection.php:128
/var/www/framework/vendor/predis/predis/src/Connection/StreamConnection.php:178
/var/www/framework/vendor/predis/predis/src/Connection/StreamConnection.php:100
/var/www/framework/vendor/predis/predis/src/Connection/AbstractConnection.php:81
/var/www/framework/vendor/predis/predis/src/Connection/StreamConnection.php:258
/var/www/framework/vendor/predis/predis/src/Connection/AbstractConnection.php:180
/var/www/framework/vendor/predis/predis/src/Connection/StreamConnection.php:288
/var/www/framework/vendor/predis/predis/src/Connection/StreamConnection.php:394
/var/www/framework/vendor/predis/predis/src/Connection/AbstractConnection.php:110
/var/www/framework/vendor/predis/predis/src/Client.php:331
/var/www/framework/vendor/predis/predis/src/Client.php:314
/var/www/framework/src/Illuminate/Queue/RedisQueue.php:114
/var/www/framework/tests/Queue/RedisQueueIntegrationTest.php:152

5) RedisQueueIntegrationTest::testNotExpireJobsWhenExpireNull
Predis\Connection\ConnectionException: Connection timed out [tcp://172.17.0.50:6379]

/var/www/framework/vendor/predis/predis/src/Connection/AbstractConnection.php:155
/var/www/framework/vendor/predis/predis/src/Connection/StreamConnection.php:128
/var/www/framework/vendor/predis/predis/src/Connection/StreamConnection.php:178
/var/www/framework/vendor/predis/predis/src/Connection/StreamConnection.php:100
/var/www/framework/vendor/predis/predis/src/Connection/AbstractConnection.php:81
/var/www/framework/vendor/predis/predis/src/Connection/StreamConnection.php:258
/var/www/framework/vendor/predis/predis/src/Connection/AbstractConnection.php:180
/var/www/framework/vendor/predis/predis/src/Connection/StreamConnection.php:288
/var/www/framework/vendor/predis/predis/src/Connection/StreamConnection.php:394
/var/www/framework/vendor/predis/predis/src/Connection/AbstractConnection.php:110
/var/www/framework/vendor/predis/predis/src/Client.php:331
/var/www/framework/vendor/predis/predis/src/Client.php:314
/var/www/framework/src/Illuminate/Queue/RedisQueue.php:95
/var/www/framework/src/Illuminate/Queue/RedisQueue.php:82
/var/www/framework/tests/Queue/RedisQueueIntegrationTest.php:176

6) RedisQueueIntegrationTest::testExpireJobsWhenExpireSet
Predis\Connection\ConnectionException: Connection timed out [tcp://172.17.0.50:6379]

/var/www/framework/vendor/predis/predis/src/Connection/AbstractConnection.php:155
/var/www/framework/vendor/predis/predis/src/Connection/StreamConnection.php:128
/var/www/framework/vendor/predis/predis/src/Connection/StreamConnection.php:178
/var/www/framework/vendor/predis/predis/src/Connection/StreamConnection.php:100
/var/www/framework/vendor/predis/predis/src/Connection/AbstractConnection.php:81
/var/www/framework/vendor/predis/predis/src/Connection/StreamConnection.php:258
/var/www/framework/vendor/predis/predis/src/Connection/AbstractConnection.php:180
/var/www/framework/vendor/predis/predis/src/Connection/StreamConnection.php:288
/var/www/framework/vendor/predis/predis/src/Connection/StreamConnection.php:394
/var/www/framework/vendor/predis/predis/src/Connection/AbstractConnection.php:110
/var/www/framework/vendor/predis/predis/src/Client.php:331
/var/www/framework/vendor/predis/predis/src/Client.php:314
/var/www/framework/src/Illuminate/Queue/RedisQueue.php:95
/var/www/framework/src/Illuminate/Queue/RedisQueue.php:82
/var/www/framework/tests/Queue/RedisQueueIntegrationTest.php:215

7) RedisQueueIntegrationTest::testRelease
Predis\Connection\ConnectionException: Connection timed out [tcp://172.17.0.50:6379]

/var/www/framework/vendor/predis/predis/src/Connection/AbstractConnection.php:155
/var/www/framework/vendor/predis/predis/src/Connection/StreamConnection.php:128
/var/www/framework/vendor/predis/predis/src/Connection/StreamConnection.php:178
/var/www/framework/vendor/predis/predis/src/Connection/StreamConnection.php:100
/var/www/framework/vendor/predis/predis/src/Connection/AbstractConnection.php:81
/var/www/framework/vendor/predis/predis/src/Connection/StreamConnection.php:258
/var/www/framework/vendor/predis/predis/src/Connection/AbstractConnection.php:180
/var/www/framework/vendor/predis/predis/src/Connection/StreamConnection.php:288
/var/www/framework/vendor/predis/predis/src/Connection/StreamConnection.php:394
/var/www/framework/vendor/predis/predis/src/Connection/AbstractConnection.php:110
/var/www/framework/vendor/predis/predis/src/Client.php:331
/var/www/framework/vendor/predis/predis/src/Client.php:314
/var/www/framework/src/Illuminate/Queue/RedisQueue.php:95
/var/www/framework/src/Illuminate/Queue/RedisQueue.php:82
/var/www/framework/tests/Queue/RedisQueueIntegrationTest.php:236

8) RedisQueueIntegrationTest::testReleaseInThePast
Predis\Connection\ConnectionException: Connection timed out [tcp://172.17.0.50:6379]

/var/www/framework/vendor/predis/predis/src/Connection/AbstractConnection.php:155
/var/www/framework/vendor/predis/predis/src/Connection/StreamConnection.php:128
/var/www/framework/vendor/predis/predis/src/Connection/StreamConnection.php:178
/var/www/framework/vendor/predis/predis/src/Connection/StreamConnection.php:100
/var/www/framework/vendor/predis/predis/src/Connection/AbstractConnection.php:81
/var/www/framework/vendor/predis/predis/src/Connection/StreamConnection.php:258
/var/www/framework/vendor/predis/predis/src/Connection/AbstractConnection.php:180
/var/www/framework/vendor/predis/predis/src/Connection/StreamConnection.php:288
/var/www/framework/vendor/predis/predis/src/Connection/StreamConnection.php:394
/var/www/framework/vendor/predis/predis/src/Connection/AbstractConnection.php:110
/var/www/framework/vendor/predis/predis/src/Client.php:331
/var/www/framework/vendor/predis/predis/src/Client.php:314
/var/www/framework/src/Illuminate/Queue/RedisQueue.php:95
/var/www/framework/src/Illuminate/Queue/RedisQueue.php:82
/var/www/framework/tests/Queue/RedisQueueIntegrationTest.php:269

9) RedisQueueIntegrationTest::testDelete
Predis\Connection\ConnectionException: Connection timed out [tcp://172.17.0.50:6379]

/var/www/framework/vendor/predis/predis/src/Connection/AbstractConnection.php:155
/var/www/framework/vendor/predis/predis/src/Connection/StreamConnection.php:128
/var/www/framework/vendor/predis/predis/src/Connection/StreamConnection.php:178
/var/www/framework/vendor/predis/predis/src/Connection/StreamConnection.php:100
/var/www/framework/vendor/predis/predis/src/Connection/AbstractConnection.php:81
/var/www/framework/vendor/predis/predis/src/Connection/StreamConnection.php:258
/var/www/framework/vendor/predis/predis/src/Connection/AbstractConnection.php:180
/var/www/framework/vendor/predis/predis/src/Connection/StreamConnection.php:288
/var/www/framework/vendor/predis/predis/src/Connection/StreamConnection.php:394
/var/www/framework/vendor/predis/predis/src/Connection/AbstractConnection.php:110
/var/www/framework/vendor/predis/predis/src/Client.php:331
/var/www/framework/vendor/predis/predis/src/Client.php:314
/var/www/framework/src/Illuminate/Queue/RedisQueue.php:95
/var/www/framework/src/Illuminate/Queue/RedisQueue.php:82
/var/www/framework/tests/Queue/RedisQueueIntegrationTest.php:281

10) RedisQueueIntegrationTest::testSize
Predis\Connection\ConnectionException: Connection timed out [tcp://172.17.0.50:6379]

/var/www/framework/vendor/predis/predis/src/Connection/AbstractConnection.php:155
/var/www/framework/vendor/predis/predis/src/Connection/StreamConnection.php:128
/var/www/framework/vendor/predis/predis/src/Connection/StreamConnection.php:178
/var/www/framework/vendor/predis/predis/src/Connection/StreamConnection.php:100
/var/www/framework/vendor/predis/predis/src/Connection/AbstractConnection.php:81
/var/www/framework/vendor/predis/predis/src/Connection/StreamConnection.php:258
/var/www/framework/vendor/predis/predis/src/Connection/AbstractConnection.php:180
/var/www/framework/vendor/predis/predis/src/Connection/StreamConnection.php:288
/var/www/framework/vendor/predis/predis/src/Connection/StreamConnection.php:394
/var/www/framework/vendor/predis/predis/src/Connection/AbstractConnection.php:110
/var/www/framework/vendor/predis/predis/src/Client.php:331
/var/www/framework/vendor/predis/predis/src/Client.php:314
/var/www/framework/src/Illuminate/Queue/RedisQueue.php:69
/var/www/framework/tests/Queue/RedisQueueIntegrationTest.php:297

ERRORS!
Tests: 2426, Assertions: 5399, Errors: 10.
ERROR: Service 'php' failed to build: The command '/bin/sh -c bash -c 'source $HOME/local/php-version/php-version.sh; php-version 7 && phpunit'' returned a non-zero code: 2
'''