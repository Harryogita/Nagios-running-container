#create 3 ec2-instances on AWS and ssh to any One of it via. Converting .pem to .ppk key using Public IP or DNS. 
#username=ubuntu then switch to root

#create your dockerfile working dir
#mkdir dockerfile

#Lets start with real task here onwards.

#create Dockerfile ,note name is case sensitive on your host-OS
#vim Dockerfile

#Download the base image with latest tag and Update your repo with latest pkgs
FROM centos:latest
RUN yum update -y

# Install prerequisites for nagios configuration. 
RUN yum install -y net-snmp net-snmp-utils epel-release gcc glibc glibc-common wget unzip httpd php gd gd-devel perl postfix make perl-Net-SNMP


# Create nagios user,nagcmd group,then add both nagios & apache user to nagcmd group
RUN useradd -m -s /bin/nologin nagios
#RUN grep -i 'apache|nagios' /etc/groups
RUN usermod -a -G nagios 
RUN usermod -a -G apache


# Download source code of nagios-core and untar it
RUN wget https://assets.nagios.com/downloads/nagioscore/releases/nagios-4.4.5.tar.gz
RUN tar xzf nagioscore-4.4.3.tar.gz

# Download source code of nagios-core and untar it 
RUN wget https://nagios-plugins.org/download/nagios-plugins-2.3.1.tar.gz 
RUN tar xzf nagios-plugin-2.3.1.tar.gz


# Set the working directory(inside container) 
WORKDIR /nagios/
# Copy into /nagios,whatever you have downloaded-nagios core and nagios plugin conf files
COPY . /nagios/

# Set the working directory to workaround nagios core 
WORKDIR /nagios/nagioscore-nagios-4.4.3/

# Compile & Install Binaries
RUN ./configure --with-command-group=nagcmd
RUN make all
RUN make install
# Install Command-Mode & conf files 
RUN make install-init
RUN make install-commandmode
RUN make install-config


# Install apache Conf. files
RUN make install-webconf

# Create nagiosadmin User Account
RUN htpasswd -s -c /usr/local/nagios/etc/htpasswd.users nagiosadmin



# Set working directory for nagios plugin
WORKDIR /nagios/nagios-plugins-release-2.2.3/

# Install Nagios plugins
RUN ./configure --with-nagios-user=nagios --with-nagios-group=nagcmd

RUN make all
RUN make install

RUN /usr/local/nagios/bin/nagios -v /usr/local/nagios/etc/nagios.cfg

RUN systemctl restart htppd.service
RUN systemctl enable httpd.service
RUN systemctl restart nagios.service
RUN systemctl enable nagios.service



# Install service-daemon
#RUN make install-daemoninit
#RUN systemctl enable httpd.service


# Start Apache and Nagios
CMD ["/bin/bash", "/nagios/start.sh"]
