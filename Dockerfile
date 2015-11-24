FROM wscherphof/oracle-linux-7
MAINTAINER Wouter Scherphof <wouter.scherphof@gmail.com>

# Install prerequisites
RUN yum install -y make libaio bc net-tools vte3 unzip

# Add current to temp
ADD . /tmp/oracle-xe-11g-r2
WORKDIR /tmp/oracle-xe-11g-r2

# Unzip files
RUN mkdir files/oracle-xe-11.2 && \
    unzip files/oracle-xe-11.2.0-1.0.x86_64.rpm.zip -d files/oracle-xe-11.2

# Install Database
RUN yum localinstall -y files/oracle-xe-11.2/Disk1/oracle-xe-11.2.0-1.0.x86_64.rpm && \
    rm -f files/oracle-xe-11.2/Disk1/oracle-xe-11.2.0-1.0.x86_64.rpm

# Configure ENV
ENV ORACLE_HOME /u01/app/oracle/product/11.2.0/xe
ENV PATH        $ORACLE_HOME/bin:$PATH
ENV ORACLE_SID  XE

RUN echo 'export ORACLE_HOME=/u01/app/oracle/product/11.2.0/xe' >> /etc/bashrc && \
    echo 'export PATH=$ORACLE_HOME/bin:$PATH' >> /etc/bashrc && \
    echo 'export ORACLE_SID=XE' >> /etc/bashrc

# Replace config files
ADD config/database/xe.rsp /u01/app/oracle/product/11.2.0/xe/config/scripts/xe.rsp
ADD config/database/initXETemp.ora /u01/app/oracle/product/11.2.0/xe/config/scripts/initXETemp.ora
ADD config/database/init.ora /u01/app/oracle/product/11.2.0/xe/config/scripts/init.ora

# Configure Database
RUN service oracle-xe configure responseFile=/u01/app/oracle/product/11.2.0/xe/config/scripts/xe.rsp

# Cleanup installation files
RUN rm -rf files

# Expose ports
EXPOSE 1521 8080

# Run Database
CMD /tmp/oracle-xe-11g-r2/start
