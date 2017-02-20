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


#RUN cd /opt/jboss/ && curl -L https://downloads.jboss.org/keycloak/$KEYCLOAK_VERSION/keycloak-$KEYCLOAK_VERSION.tar.gz | tar zx && mv /opt/jboss/keycloak-$KEYCLOAK_VERSION /opt/jboss/keycloak
COPY keycloak-2.5.1.Final.tar.gz.parta /opt/jboss/
COPY keycloak-2.5.1.Final.tar.gz.partb /opt/jboss/

RUN cd /opt/jboss/ && cat keycloak-2.5.1.Final.tar.gz.part* > keycloak-2.5.1.Final.tar.gz && rm keycloak-2.5.1.Final.tar.gz.part* && tar zxf keycloak-2.5.1.Final.tar.gz && mv /opt/jboss/keycloak-2.5.1.Final /opt/jboss/keycloak

 
USER jboss 

COPY ad-integration-module-1.0.0.jar /opt/jboss/keycloak/providers/ad-integration-module.jar
COPY docker-entrypoint.sh /opt/jboss/docker-entrypoint.sh

#ADD setLogLevel.xsl /opt/jboss/keycloak/
#RUN java -jar /usr/share/java/saxon.jar -s:/opt/jboss/keycloak/standalone/configuration/standalone.xml -xsl:/opt/jboss/keycloak/setLogLevel.xsl -o:/opt/jboss/keycloak/standalone/configuration/standalone.xml

COPY standalone.xml /opt/jboss/keycloak/standalone/configuration/standalone.xml
COPY standalone-ha.xml /opt/jboss/keycloak/standalone/configuration/standalone-ha.xml
COPY keycloak.jks /opt/jboss/keycloak/standalone/configuration/keycloak.jks
COPY realm-identity-provider-ad-oidc.html /opt/jboss/keycloak/themes/base/admin/resources/partials/realm-identity-provider-ad-oidc.html
COPY realm-identity-provider-keycloak-ad-oidc.html /opt/jboss/keycloak/themes/base/admin/resources/partials/realm-identity-provider-keycloak-ad-oidc.html

RUN mkdir -p /opt/jboss/keycloak/modules/system/layers/base/com/mysql/jdbc/main; cd /opt/jboss/keycloak/modules/system/layers/base/com/mysql/jdbc/main && curl -O http://central.maven.org/maven2/mysql/mysql-connector-java/5.1.18/mysql-connector-java-5.1.18.jar
COPY module.xml /opt/jboss/keycloak/modules/system/layers/base/com/mysql/jdbc/main/module.xml

ADD jgroups-protocols.tar.gz /opt/jboss/keycloak/modules/system/layers/base/org/jgroups-protocols.tar.gz
ADD rootCA.crt /opt/jboss/keycloak/rootCA.crt

USER root
RUN chown jboss:jboss /opt/jboss/docker-entrypoint.sh /opt/jboss/keycloak/providers/ad-integration-module.jar /opt/jboss/keycloak/standalone/configuration/standalone.xml /opt/jboss/keycloak/standalone/configuration/standalone-ha.xml /opt/jboss/keycloak/standalone/configuration/keycloak.jks /opt/jboss/keycloak/themes/base/admin/resources/partials/realm-identity-provider-ad-oidc.html /opt/jboss/keycloak/themes/base/admin/resources/partials/realm-identity-provider-keycloak-ad-oidc.html /opt/jboss/keycloak/modules/system/layers/base/org/jgroups-protocols.tar.gz /opt/jboss/keycloak/modules/system/layers/base/com/mysql/jdbc/main/module.xml && \
    chmod +x /opt/jboss/docker-entrypoint.sh /opt/jboss/keycloak/standalone/configuration/standalone.xml /opt/jboss/keycloak/standalone/configuration/keycloak.jks

RUN /usr/lib/jvm/java/bin/keytool -importcert -noprompt -alias rootcert1 -keystore /usr/lib/jvm/java/jre/lib/security/cacerts -storepass changeit -file /opt/jboss/keycloak/rootCA.crt

#USER jboss
ENV JBOSS_HOME /opt/jboss/keycloak

# Important! Add root group permission to /opt folder according to openshift documentation
RUN chgrp -R 0 /opt \
  && chmod -R g+rwX /opt


EXPOSE 8080 8443

EXPOSE 57600 7600 8181 9990 9999 11211 11222

ENTRYPOINT [ "/opt/jboss/docker-entrypoint.sh" ]

CMD ["-b", "0.0.0.0"]



