FROM centos:latest
RUN yum clean all
RUN yum remove -y fakesystemd
RUN yum install -y systemd sudo openssh-server openssh-clients curl 
RUN ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key
RUN ssh-keygen -t dsa -f /etc/ssh/ssh_host_dsa_key
RUN mkdir -p /var/run/sshd
RUN useradd -d /home/<%= @username %> -m -s /bin/bash <%= @username %>
RUN echo <%= "#{@username}:#{@password}" %> | chpasswd
RUN echo '<%= @username %> ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
RUN systemctl enable sshd
CMD [ "/usr/sbin/init"]
