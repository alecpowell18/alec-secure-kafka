#!/bin/bash

set -o nounset \
    -o errexit \
    -o verbose
#    -o xtrace

mkdir -p secrets
cd secrets

# Cleanup files
rm -f *.crt *.csr *_creds *.jks *.srl *.key *.pem *.der *.p12

# Generate CA key
openssl req -new -x509 -keyout ca1.key -out ca1.crt -days 365 -subj '/CN=ca1.demo.confluent.io/OU=DEMO/O=CONFLUENT/L=MountainView/S=CA/C=US' -passin pass:confluent -passout pass:confluent

for i in localhost broker1 client1 
do
	echo "------------------------------- $i -------------------------------"

	# Create host keystore
	keytool -genkey -noprompt \
				 -alias localhost \
				 -dname "CN=$i,OU=DEMO,O=CONFLUENT,L=MountainView,S=CA,C=US" \
				 -ext SAN=DNS:localhost \
				 -keystore kafka.$i.keystore.jks \
				 -keyalg RSA \
				 -storepass confluent \
				 -keypass confluent \
				 -validity 365 


	# Create the certificate signing request (CSR)
	keytool -keystore kafka.$i.keystore.jks -alias localhost -certreq -file $i.csr -storepass confluent -keypass confluent

        # Sign the host certificate with the certificate authority (CA)
	openssl x509 -req -CA ca1.crt -CAkey ca1.key -in $i.csr -out $i-ca1-signed.crt -days 365 -CAcreateserial -passin pass:confluent

        # Sign and import the CA cert into the keystore
	keytool -noprompt -keystore kafka.$i.keystore.jks -alias CARoot -import -file ca1.crt -storepass confluent -keypass confluent

        # Sign and import the host certificate into the keystore
	keytool -noprompt -keystore kafka.$i.keystore.jks -alias localhost -import -file $i-ca1-signed.crt -storepass confluent -keypass confluent

	# Create truststore and import the CA cert
	keytool -noprompt -keystore kafka.$i.truststore.jks -alias CARoot -import -file ca1.crt -storepass confluent -keypass confluent

	# Save creds
  	#echo "confluent" > ${i}_sslkey_creds
  	#echo "confluent" > ${i}_keystore_creds
  	#echo "confluent" > ${i}_truststore_creds

	rm $i.csr
	rm $i-ca1-signed.crt

	# Create pem files and keys used for Schema Registry HTTPS testing
	#   openssl x509 -noout -modulus -in client.certificate.pem | openssl md5
	#   openssl rsa -noout -modulus -in client.key | openssl md5 
        #   echo "GET /" | openssl s_client -connect localhost:8082/subjects -cert client.certificate.pem -key client.key -tls1 
#	keytool -export -alias $i -file $i.der -keystore kafka.$i.keystore.jks -storepass confluent
#	openssl x509 -inform der -in $i.der -out $i.certificate.pem
#	keytool -importkeystore -srckeystore kafka.$i.keystore.jks -destkeystore $i.keystore.p12 -deststoretype PKCS12 -deststorepass confluent -srcstorepass confluent -noprompt
#	openssl pkcs12 -in $i.keystore.p12 -nodes -nocerts -out $i.key -passin pass:confluent

echo "confluent" > cert_creds
done
