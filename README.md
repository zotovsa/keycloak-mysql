
##1. Root CA generation:

####1.1 Generate root key. 
 This key is a very secure. This is the main part we should hide from other persons and don't share to any one.
 As an input we have the name of root key file name: `rootCA.key`
```bash
openssl genrsa -out rootCA.key 4096
```

> Output:
> ```
> Generating RSA private key, 4096 bit long modulus
> .........................................................................................................................................++
> .......................................................................................................................................................................................++
> e is 65537 (0x10001) 
> ```


####1.2 Generate root certificate.
  This certificate is the one we should share with all clients. It should be imported in to the browser and java trusted CA stores. 
  The input is `rootCA.key` - the root key, `10000` as a number of days the root certificate is valid and `rootCA.crt` as an output of root certificate file name.
```bash
openssl req -x509 -new -key rootCA.key -days 10000 -out rootCA.crt
```

> Output: 
> ```
> You are about to be asked to enter information that will be incorporated
> into your certificate request.
> What you are about to enter is what is called a Distinguished Name or a DN.
> There are quite a few fields but you can leave some blank
> For some fields there will be a default value,
> If you enter '.', the field will be left blank.
> -----
> Country Name (2 letter code) [AU]:US
> State or Province Name (full name) [Some-State]:Colorado
> Locality Name (eg, city) []:Denver
> Organization Name (eg, company) [Internet Widgits Pty Ltd]:My Company Name 
> Organizational Unit Name (eg, section) []:Organizational Unit name
> Common Name (e.g. server FQDN or YOUR name) []:This name will be dispayed in keychain and other CA stores                                    
> Email Address []:test@test.com
> ```

##2. We can start generating keystore and signing it with our root key.
####2.1 generate keystore: 
Here output name is `keystore.jks` and alias name is `tomcat`. Do not forget to record the password. Here we will use one password for keystore and SAME password for alias, because some old tomcat version are not supported different passwords(tomcat v7+ looks like supported and required to use additional parameter for that ). 
Please enter you domain name in `your first and last name?` because it will be checked during https connection creation. There is no info about port number. 
> **Example:** you can enter `localhost` domain for localhost tests.

```bash        
keytool -genkey -alias tomcat -keyalg RSA  -keystore keystore.jks
```        

> Output:
> 
> ```
> Enter keystore password: 
> Re-enter new password:   
> What is your first and last name?
>   [Unknown]:  your-domain.name.com
> What is the name of your organizational unit?
>   [Unknown]:  My organization unit name
> What is the name of your organization?
>   [Unknown]:  My organization. Probably forsythe or NM for instance
> What is the name of your City or Locality?
>   [Unknown]:  Denver
> What is the name of your State or Province?
>   [Unknown]:  Colorado
> What is the two-letter country code for this unit?
>   [Unknown]:  US
> Is CN=your-domain.name.com, OU=My organization unit name, O=My organization. Probably forsythe or NM for instance, L=Denver, ST=Colorado, C=US correct?
>   [no]:  yes
> 
> Enter key password for <tomcat>
> 	(RETURN if same as keystore password):  !!RETURN KEY IMPORTANT!!
> ```


####2.2 Generate the Certificate Signing Request:
Here input `keystore.jks` as keystore name with alias name `tomcat` and output file name `certreq.csr`. Please enter keystore password in password prompt here.        
```bash
keytool -certreq -keyalg RSA -alias tomcat -file certreq.csr -keystore keystore.jks   
```
> Output:
> ```
> Enter keystore password:  
> ```

####2.3 Signing the Certificate Signing Request with our root key and root certificate:
Here input `certreq.csr` as the Certificate Signing Request, `rootCA.crt` as a root certificate, `rootCA.key` as a root key and `5000` as a number of certificate valid days. The output `certreq_out.crt` - the name of the Signed Request.   
``` bash   
openssl x509 -req -sha256 -in certreq.csr -CA rootCA.crt -CAkey rootCA.key -CAcreateserial -out certreq_out.crt -days 5000
```

> Output:
> ```
> Signature ok
> subject=/C=US/ST=Colorado/L=Denver/O=My organization. Probably forsythe or NM for instance/OU=My organization unit name/CN=your-domain.name.com
> Getting CA Private Key
> ```

####2.4  Import public root certificate and signed certificate to the same keystore:
   
#####First import root certificate: 

Here input `keystore.jks `as a keystore name and `rootCA.crt` as a root certificate name
> NOTE: In the end please answer **yes**

```bash        
keytool -import -alias root -keystore keystore.jks -trustcacerts -file rootCA.crt
```        
> Output:
> ```bash
> Enter keystore password:  
> Certificate already exists in system-wide CA keystore under alias <rootcert1>
> Do you still want to add it to your own keystore? [no]:  yes
> Certificate was added to keystore
> ```


#####Finally import signed request: 
Here input `keystore.jks `as a keystore name and `certreq_out.crt` as a signed request we got on previous step.
```bash
keytool -import -alias tomcat -keystore keystore.jks  -file certreq_out.crt
```
> Output:
> ```bash
> Enter keystore password:  
> Certificate reply was installed in keystore
> ```

---
###3. Add root certificate to java's certificate authority.
 
 Assuming you in java root folder. When asked `Trust this certificate?` by `keytool`, answer `yes` and you’ll be good to go. And don't forget this command is run under sudo rights to allow access to cacert file!

```bash
sudo ./keytool -importcert -alias rootcert1 -keystore ../jre/lib/security/cacerts -storepass changeit -file /User/sergey/dev/keycloak/integration/keycloak-mysql/keys/rootCA.crt
```





##Run mysql:

```bash
oc new-app mysql -e MYSQL_ROOT_PASSWORD=root -e MYSQL_DATABASE=keycloak -e MYSQL_USER=keycloak -e MYSQL_PASSWORD=keycloak
```