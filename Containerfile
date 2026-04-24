FROM debian:trixie-slim as install

ARG DEBIAN_FRONTEND=noninteractive

#SHELL ["/bin/bash", "-c"]
RUN rm /bin/sh \
  && ln -s /bin/bash /bin/sh

# install dependencies
RUN apt update && apt upgrade -y \
  && apt install -y --no-install-recommends --no-install-suggests openjdk-21-jdk-headless wget \
  && rm -rf "/var/lib/apt/lists/*" \
  && rm -rf /var/cache/apt/archives

ENV JBOSS_HOME=/opt/jboss/wildfly
ENV PATH=$JBOSS_HOME/bin:$PATH

RUN mkdir -p /opt/jboss \
  && cd /opt/jboss \
  && wget https://github.com/wildfly/wildfly/releases/download/39.0.1.Final/wildfly-preview-39.0.1.Final.tar.gz -O wildfly.tar.gz \
  && echo "8a204ebcba28267bd3603095334d4a02e7db83b4  wildfly.tar.gz" | sha1sum -c - \
  && tar xzf wildfly.tar.gz \
  && mv wildfly-preview-39.0.1.Final wildfly \
  && rm wildfly.tar.gz

RUN mkdir -p $JBOSS_HOME/standalone/deployments \
  && cat > $JBOSS_HOME/standalone/deployments/hello.war/index.jsp << 'EOF'
<%@ page language="java" %>
<%
    String name = request.getParameter("name");
    if (name == null || name.isEmpty()) {
        name = "World";
    }
%>
Hello <%= name %>
EOF

EXPOSE 8080 9990

CMD ["standalone.sh", "-b", "0.0.0.0", "-bmanagement", "0.0.0.0"]

HEALTHCHECK --interval=30s --timeout=5s --start-period=60s --retries=3 CMD jcmd wildfly.jar help || exit 1
