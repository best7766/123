## Ubuntu 18.04 Multi User Remote Desktop Server Base KUBUNTU-DESKTOP+RDP+SSH+APACHE2+SSL+WEBMIN+SUPERVISOR

Base image for fully implemented Multi User rdp with ssh and 
apache2 with ssl and webmin Ubuntu 18.04.Copy/Paste working. 
Users can re-login in the same session and Supervisor: A Process Control System.

## Usage
rdp -p 3389:3389
ssh -p 22:22
apache2 -p 80:80
webmin 10000:10000
ssl 443:443
supervisor 9001:9001


## Entrypoint and Services

Docker can't work with the regular systemd for starting services.
For this supevisor was implemented. Supervisor reads seperate files
from /etc/supervisor/conf.d, the code inside the conf is supervisor.
The docker-entrypoint reads seperate files from /etc/entrypoint.d, 
the code inside the conf is "bash" and the filename sets the order.

## Building

You can use this base image to build any X application and
share it with RDP. 
You can add services in supervisor by adding a .conf file to
/etc/supervisor/conf.d/
The entrypoint needed for your service can be added to
/etc/entrypoint.d/

## Add new services

To make sure all processes are working supervisor is installed.
The location for services to start is /etc/supervisor/conf.d

Example: Add mysql as a service

```bash
apt-get -yy install mysql-server
echo "[program:mysqld] \
command= /usr/sbin/mysqld \
user=mysql \
autorestart=true \
priority=100" > /etc/supervisor/conf.d/mysql.conf
supervisorctl update
```
## Add new entrypoint

To make sure your service will run because all conditions are fixed.
In the docker-entrypoint is a loop to run the entrypoint configuration 
files. The are sorted by name to determine the order and the language
used is "bash".
