FROM jenkins/jenkins:lts
USER root
RUN apt-get update && apt-get install -y tree nano curl sudo python3 python3-venv
RUN curl -LO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl" && chmod +x ./kubectl && sudo mv ./kubectl /usr/local/bin/kubectl
RUN curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip" && unzip awscli-bundle.zip
RUN sudo /usr/bin/python3 awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws && mkdir /root/.aws
RUN curl https://get.docker.com/builds/Linux/x86_64/docker-latest.tgz | tar xvz -C /tmp/ && mv /tmp/docker/docker /usr/bin/docker
RUN curl -L "https://github.com/docker/compose/releases/download/1.23.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
RUN chmod 755 /usr/local/bin/docker-compose
RUN curl "https://download.java.net/java/GA/jdk11/13/GPL/openjdk-11.0.1_linux-x64_bin.tar.gz" | tar xvz -C /tmp/ && mv /tmp/jdk-11.0.1 /opt/java/openjdk 
RUN usermod -a -G sudo jenkins
RUN echo "jenkins ALL=(ALL:ALL) NOPASSWD:ALL" >> /etc/sudoers
USER jenkins
RUN jenkins-plugin-cli --plugins scm-api:latest git-client:latest git:latest greenballs:latest docker-workflow:latest pipeline-maven:latest sonar:latest mailer pipeline-utility-steps 