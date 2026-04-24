FROM debian:trixie-slim as install

ARG DEBIAN_FRONTEND=noninteractive

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

RUN mkdir -p $JBOSS_HOME/standalone/deployments/hello.war/WEB-INF
COPY <<'EOF' $JBOSS_HOME/standalone/deployments/hello.war/WEB-INF/web.xml << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<web-app xmlns="http://xmlns.jcp.org/xml/ns/javaee" version="4.0">
</web-app>
EOF
COPY <<'EOF' $JBOSS_HOME/standalone/deployments/hello.war/index.jsp
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
