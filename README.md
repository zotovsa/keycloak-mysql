# keycloak-mysql


Run mysql:


oc new-app mysql -e MYSQL_ROOT_PASSWORD=root -e MYSQL_DATABASE=keycloak -e MYSQL_USER=keycloak -e MYSQL_PASSWORD=keycloak


**Key generation:**
**Root CA generation:**

```bash

openssl genrsa -out rootCA.key 4096
 
   Set of question - it doesn't metter what you answer.

openssl req -x509 -new -key rootCA.key -days 10000 -out rootCA.crt

```


```bash

3. We can start generating keystore and signing it with our root key!
   3.1 generate keystore: 
        
        keytool -genkey -alias tomcat -keyalg RSA  -keystore keystore.jks
        

   3.2 
        keytool -certreq -keyalg RSA -alias tomcat -file certreq.csr -keystore keystore.jks   

   3.3 
        openssl x509 -req -sha256 -in certreq.csr -CA rootCA.crt -CAkey rootCA.key -CAcreateserial -out certrequ_out.crt -days 5000

   3.4   Import public root certificate and signed cretificate to the same keystore
        
        keytool -import -alias root -keystore keystore.jks -trustcacerts -file ./rootCA.crt
        

        keytool -import -alias tomcat -keystore keystore.jks  -file ./certreq_out.crt

```

To add rootCA to java java's cacerts(assuming you in java root):


```bash
sudo ./keytool -importcert -alias rootcert1 -keystore ../jre/lib/security/cacerts -storepass changeit -file ~/dev/keycloak/integration/keycloak-mysql/keys/rootCA.crt

```