Multi PHP environment:


In this setup there is a running EC2 instance with Docker installed.

I have set up a Docker container using 'phpfarm'

https://github.com/splitbrain/docker-phpfarm

[ec2-user ~]$ sudo usermod -a -G docker ec2-user

For the sake of simplicity I have used splitbrain's repo to pull a prebuilt image that runs multiple versions of PHP in parallel.

[ec2-user ~]$ 
[ec2-user ~]$ docker pull splitbrain/phpfarm:jessie
[ec2-user ~]$ echo "<?php echo 'Current PHP version: ' . phpversion(); ?>" > index.php
[ec2-user ~]$ docker run --rm -t -i -e APACHE_UID=$UID -v $PWD:/var/www:rw -p 8052:8052 -p 8053:8053 -p 8054:8054 -p 8055:8055 -p 8056:8056p 8070:8070 splitbrain/phpfarm:jessie

The above commands will map the current working forlder to /var/www on the container and maps localport according to the PHP version it serves.

Test #1

$ GET -Sse http://54.201.163.38:8070/
>
200 OK
Connection: close
Date: Mon, 05 Sep 2016 14:01:51 GMT
Server: Apache/2.4.10 (Debian)
Vary: Accept-Encoding
Content-Type: text/html; charset=UTF-8
Client-Date: Mon, 05 Sep 2016 02:14:41 GMT
Client-Peer: 54.201.163.38:8070
Client-Response-Num: 1
Client-Transfer-Encoding: chunked
X-Powered-By: PHP/7.0.4

Current PHP version: 7.0.4

Test #2
GET http://54.201.163.38:8055/
>
200 OK
Connection: close
Date: Mon, 05 Sep 2016 14:03:40 GMT
Server: Apache/2.4.10 (Debian)
Vary: Accept-Encoding
Content-Type: text/html
Client-Date: Mon, 05 Sep 2016 02:16:30 GMT
Client-Peer: 54.201.163.38:8055
Client-Response-Num: 1
Client-Transfer-Encoding: chunked
X-Powered-By: PHP/5.5.33

Current PHP version: 5.5.33
<<<


As you can see the last two digits of the destination port represents the PHP version.

Some test cases may need to use FQDN instead of IP addresses and default port 80 for real-like settings. 
The container could be modified to use different IPs for different PHP versions for example 172.0.1.55 for version 5.5 and .70 for version 7.0 and so on. 

The hostname can be sent to the webserver running on the container using "Host:" header in the HTTP request. (curl -H "Host: www.example.com" "http://54.186.247.112:8055/")

 Started with Amazon EC2 Container Service (ECS)

====== TESTING THE AMAZON ECS ======

I am now going to use Amazon ECS since I am already using EC2 instances and Amazon has its own service of managing multiple containers instead of relying on docker-compose.

What I have done so far on multi-container setup:


- created an Amazon Linux EC2 instance with IAM AmazonEC2ContainerServiceforEC2Role policy
- created a default Amazon ECS cluster called RobZ
- the EC2 instance automatically registered into the cluster
- the Docker containers start automatically and they recover if they crash
- setup two containers, one for Redis and the other one for php-farm
- compiled phpredis module for php-5.5 
- commited the changes to splitbrain/docker-phpfarm image, added an extra layer to it and pushed it to Docker Hub under xidam/phpfarm_phpunit:jessie
- created a new revision for AWS ECS task definition. See task_def.json
- installed Jenkins on a EC2 instance that should be able to control and access the container services.

Quick test with phpunit:

root@bded45080d0e:~# wget https://phar.phpunit.de/phpunit-old.phar -O phpunit

"User.php"
<?php
class User {
    protected $name;

    public function getName() {
        return $this->name;
    }

    public function setName($name) {
        $this->name = $name;
    }

    public function talk() {
        return "Hello world!";
    }
}

"UserTest.php"
<?php
require_once "User.php";

class UserTest extends PHPUnit_Framework_TestCase
{
    // test the talk method
    public function testTalk() {
        // make an instance of the user
        $user = new User();

        // use assertEquals to ensure the greeting is what you
        $expected = "Hello world!";
        $actual = $user->talk();
        $this->assertEquals($expected, $actual);
    }
}

root@bded45080d0e:/var/www# php-5.5 phpunit UserTest.php
PHPUnit 4.8.27 by Sebastian Bergmann and contributors.

.

Time: 196 ms, Memory: 18.00MB

OK (1 test, 1 assertion)

root@bded45080d0e:/var/www# php-7.0 phpunit UserTest.php
PHPUnit 4.8.27 by Sebastian Bergmann and contributors.

.

Time: 164 ms, Memory: 12.00MB

OK (1 test, 1 assertion)


All tests are fine both with 5.5 and 7.0 versions.