# keycloak-mysql


Run mysql:


oc new-app mysql -e MYSQL_ROOT_PASSWORD=root -e MYSQL_DATABASE=keycloak -e MYSQL_USER=keycloak -e MYSQL_PASSWORD=keycloak




**Key generation:**

**Root CA generation:**
**1. create a root key**
openssl genrsa -out rootCA.key 4096
we will have: rootCA.key should store in some hidden storage. it will used for signing other staff
**2. create root certificate (it should be installed in all browsers and in java keystore)
openssl req -x509 -new -key rootCA.key -days 10000 -out rootCA.crt
here rootCA.key - our root key
     rootCA.crt - output of our public certificate

3. We can start generating keystore and signing it with our root key!
   3.1 generate keystore: 
        
`        keytool -genkey -alias tomcat -keyalg RSA  -keystore keystore.jks
`        

   3.2 
`        keytool -certreq -keyalg RSA -alias tomcat -file certreq.csr -keystore keystore.jks   
`
   3.3 
`        openssl x509 -req -in certreq.csr -CA rootCA.crt -CAkey rootCA.key -CAcreateserial -out certrequ_out.crt -days 5000
`
   3.4   Import public root certificate and signed cretificate to the same keystore
`        keytool -import -alias root -keystore keystore.jks -trustcacerts -file ./rootCA.crt
`        

`         keytool -import -alias tomcat -keystore keystore.jks  -file ./certreq_out.crt
`        

`openssl x509 -req -in certreq.csr -CA rootCA.crt -CAkey rootCA.key -CAcreateserial -out certrequ_out.crt -days 5000
`




To add rootCA to java java's cacerts(assuming you in java root):

sudo ./keytool -importcert -alias rootcert1 -keystore ../jre/lib/security/cacerts -storepass changeit -file ~/dev/keycloak/integration/keycloak-mysql/keys/rootCA.crt
