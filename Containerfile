FROM debian:trixie

RUN apt-get update && apt-get install -y \
    openjdk-21-jdk-headless \
    wget \
    && rm -rf /var/lib/apt/lists/*

ENV JBOSS_HOME=/opt/jboss/wildfly
ENV PATH=$JBOSS_HOME/bin:$PATH

RUN mkdir -p /opt/jboss && \
    cd /opt/jboss && \
    wget https://github.com/wildfly/wildfly/releases/download/33.0.0.Final/wildfly-33.0.0.Final.tar.gz && \
    tar xzf wildfly-33.0.0.Final.tar.gz && \
    mv wildfly-33.0.0.Final wildfly && \
    rm wildfly-33.0.0.Final.tar.gz

EXPOSE 8080 9990

CMD ["standalone.sh", "-b", "0.0.0.0", "-bmanagement", "0.0.0.0"]
