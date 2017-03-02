#!/bin/bash

if [ $KEYCLOAK_USER ] && [ $KEYCLOAK_PASSWORD ]; then
    keycloak/bin/add-user-keycloak.sh --user $KEYCLOAK_USER --password $KEYCLOAK_PASSWORD
fi
#ip=$(grep `hostname` /etc/hosts | awk '{print $1}')
#exec /opt/jboss/keycloak/bin/standalone.sh -c clustered.xml -Djboss.bind.address=$ip -Djboss.bind.address.management=0.0.0.0 -Djgroups.join_timeout=1000 -Djboss.default.jgroups.stack=kubernetes

#exec /opt/jboss/keycloak/bin/standalone.sh -c standalone-ha.xml -Djboss.bind.address=$ip -Djboss.bind.address.management=0.0.0.0 -Djgroups.join_timeout=1000 -Djboss.default.jgroups.stack=kubernetes

exec /opt/jboss/keycloak/bin/standalone.sh -c standalone-ha.xml -Djboss.bind.address=$ip -Djboss.bind.address.management=0.0.0.0  -Djgroups.join_timeout=1000 -Djboss.default.jgroups.stack=kubernetes -Djavax.net.debug=all $@


#exec /opt/jboss/keycloak/bin/standalone.sh $@
exit $?
