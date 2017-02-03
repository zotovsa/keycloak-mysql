FROM centos:7
RUN yum update -y && yum -y install xmlstarlet saxon augeas bsdtar unzip && yum clean all


RUN groupadd -r jboss -g 1000 && useradd -u 1000 -r -g jboss -m -d /opt/jboss -s /sbin/nologin -c "JBoss user" jboss && \
    chmod 755 /opt/jboss


WORKDIR /opt/jboss





USER root

#RUN yum -y install java-1.7.0-openjdk-devel && yum clean all
RUN yum -y install java-1.8.0-openjdk-devel && yum clean all
RUN yum install -y epel-release && yum install -y jq && yum clean all

USER jboss

ENV JAVA_HOME /usr/lib/jvm/java


#FROM jboss/keycloak:latest


ENV KEYCLOAK_VERSION 2.5.1.Final
ENV LAUNCH_JBOSS_IN_BACKGROUND 1


RUN cd /opt/jboss/ && curl -L https://downloads.jboss.org/keycloak/$KEYCLOAK_VERSION/keycloak-$KEYCLOAK_VERSION.tar.gz | tar zx && mv /opt/jboss/keycloak-$KEYCLOAK_VERSION /opt/jboss/keycloak

 
USER jboss 

COPY docker-entrypoint.sh /opt/jboss/docker-entrypoint.sh
#ADD setLogLevel.xsl /opt/jboss/keycloak/
#RUN java -jar /usr/share/java/saxon.jar -s:/opt/jboss/keycloak/standalone/configuration/standalone.xml -xsl:/opt/jboss/keycloak/setLogLevel.xsl -o:/opt/jboss/keycloak/standalone/configuration/standalone.xml
COPY standalone.xml /opt/jboss/keycloak/standalone/configuration/standalone.xml
COPY keycloak.jks /opt/jboss/keycloak/standalone/configuration/keycloak.jks


USER root
RUN chown jboss:jboss /opt/jboss/docker-entrypoint.sh /opt/jboss/keycloak/standalone/configuration/standalone.xml /opt/jboss/keycloak/standalone/configuration/keycloak.jks && \
    chmod +x /opt/jboss/docker-entrypoint.sh /opt/jboss/keycloak/standalone/configuration/standalone.xml /opt/jboss/keycloak/standalone/configuration/keycloak.jks

USER jboss
ENV JBOSS_HOME /opt/jboss/keycloak
EXPOSE 8080 8443

ENTRYPOINT [ "/opt/jboss/docker-entrypoint.sh" ]

CMD ["-b", "0.0.0.0"]


