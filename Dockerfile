FROM jenkins/jenkins

#WORKDIR /usr/src/app

#COPY . .
USER root

RUN apt update -y && apt -y install software-properties-common apt-transport-https ca-certificates gnupg-agent

RUN /usr/bin/curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add - && echo "deb http://ppa.launchpad.net/ansible/ansible/ubuntu trusty main" >> /etc/apt/sources.list && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 93C4A3FD7BB9C367 && apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main" && curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add - && add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"

RUN  apt update && apt install -y python3 python3-pip software-properties-common ansible terraform docker-ce docker-ce-cli containerd.io

RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && unzip awscliv2.zip && ./aws/install

RUN curl -o kubectl curl -o kubectl https://amazon-eks.s3.us-west-2.amazonaws.com/1.18.9/2020-11-02/bin/linux/amd64/kubectl &&  cp kubectl /bin/kubectl &&  chmod +x /bin/kubectl

RUN curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 && chmod +x get_helm.sh

RUN bash get_helm.sh

COPY ./plugins/* /var/jenkins_home/plugins/

#RUN cd /var/jenkins_home/plugins/ && tar -xvf plugins.tar.gz

COPY ./auth-config/config.xml /var/jenkins_home/

RUN mkdir -p /var/jenkins_home/jobs/app-deploy-pipeline

RUN mkdir -p /var/jenkins_home/jobs/app-destroy-pipeline

COPY ./pipeline-config/deploy/config.xml /var/jenkins_home/jobs/app-deploy-pipeline/

COPY ./pipeline-config/destroy/config.xml /var/jenkins_home/jobs/app-destroy-pipeline/

#docker run -v /var/run/docker.sock:/var/run/docker.sock -ti docker-image