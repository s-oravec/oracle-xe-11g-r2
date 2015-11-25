# Instant Oracle XE server
A [Dockerfile](https://www.docker.com/) with [Oracle® Database Express Edition 11g Release 2 (11.2)](http://www.oracle.com/technetwork/database/database-technologies/express-edition/overview/index.html) running in [Oracle Linux 7](http://www.oracle.com/us/technologies/linux/overview/index.html)
- Default XE database on port 1521
- Web management console on port 8080

## Build image

Due to licensing issues you have to build the image by yourselves.

1. [Install Docker](https://docs.docker.com/installation/#installation) or Docker Toolbox on Mac or Windows
1. clone this repo
1. Edit `config/database/xe.rsp` to provide default port numbers & password
1. build image using 

````
docker build --tag=ora-11g-xe:latest .
````

## Run
Create and run a container named db:

````
$ docker run -dP --name db ora11gxe
````

## Connect
The default password for both the `sys` and the `system` user is `oracle`
The XE database port `1521` and APEX port `8080` are bound to the Docker host through `run -P`. 

To find the host's port:

````
$ docker port db
1521/tcp -> 0.0.0.0:32777
8080/tcp -> 0.0.0.0:32776
````

So from the host, you can connect with `system/oracle@localhost:32777`

If you are running [Docker Machine](https://github.com/boot2docker/boot2docker) (= your host OS is MacOS X or Windows), you need the actual ip address of VirtualBox VM instead of `localhost`:

````
$ docker-machine ip $DOCKER_MACHINE_NAME
192.168.99.100
````

If you're looking for a databse client, consider [sqlplus](http://www.oracle.com/technetwork/database/features/instant-client/index-100365.html) or Oracle's SQL Developer or SQLcl (http://www.oracle.com/technetwork/developer-tools/sql-developer/downloads/index.html) 

````
$ sqlplus system/oracle@192.168.99.100:32777:XE

SQL*Plus: Release 11.2.0.4.0 Production on Mon Sep 8 11:26:24 2014

Copyright (c) 1982, 2013, Oracle.  All rights reserved.


Connected to:
Oracle Database 11g Express Edition Release 11.2.0.2.0 - 64bit Production

SQL> |
````

## Manage
Find the host's port bound to the container's `8080` web console port:
```
$ docker port db 8080
0.0.0.0:32784
```
Point a web browser to the `/apex` resource there - `http://192.168.99.100:32784/apex` (cannot use localhost here)

Workspace=`INTERNAL`, Username=`ADMIN`, Password=`oracle` (must change password after first login)

![Web management console](https://github.com/wscherphof/oracle-xe-11g-r2/blob/master/apex.png)

## Monitor
The container runs a process that at the start sets the container's unique hostname in the Oracle configuration, starts up the database, and then continues to check each minute if the database is still running, and start it if it's not. To see the output of that process:
```
$ docker logs db
Tue Sep 9 14:54:42 UTC 2014
Starting Oracle Net Listener.
Starting Oracle Database 11g Express Edition instance.


LSNRCTL for Linux: Version 11.2.0.2.0 - Production on 09-SEP-2014 14:55:00

Copyright (c) 1991, 2011, Oracle.  All rights reserved.

Connecting to (DESCRIPTION=(ADDRESS=(PROTOCOL=IPC)(KEY=EXTPROC_FOR_XE)))
STATUS of the LISTENER
------------------------
Alias                     LISTENER
Version                   TNSLSNR for Linux: Version 11.2.0.2.0 - Production
Start Date                09-SEP-2014 14:54:45
Uptime                    0 days 0 hr. 0 min. 15 sec
Trace Level               off
Security                  ON: Local OS Authentication
SNMP                      OFF
Default Service           XE
Listener Parameter File   /u01/app/oracle/product/11.2.0/xe/network/admin/listener.ora
Listener Log File         /u01/app/oracle/diag/tnslsnr/0122e1df9772/listener/alert/log.xml
Listening Endpoints Summary...
  (DESCRIPTION=(ADDRESS=(PROTOCOL=ipc)(KEY=EXTPROC_FOR_XE)))
  (DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=0122e1df9772)(PORT=1521)))
Services Summary...
Service "PLSExtProc" has 1 instance(s).
  Instance "PLSExtProc", status UNKNOWN, has 1 handler(s) for this service...
Service "XE" has 1 instance(s).
  Instance "XE", status READY, has 1 handler(s) for this service...
The command completed successfully
```

## Enter
There's no ssh deamon or similar configured in the image. If you need a command prompt inside the container connect using `docker exec`

````
$ docker exec -it db /bin/bash
````

## License
[GNU Lesser General Public License (LGPL)](http://www.gnu.org/licenses/lgpl-3.0.txt)
