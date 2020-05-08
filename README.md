# alec-secure-kafka

last updated : 05/07/20

###STEPS:
1. ./certs-create.sh
1b. (verify certs are there with ls secrets/)
2. docker-compose up -d
3. Login to port 9093 through pure SSL (mTLS) authentication using client.properties
`TBD code here`
4. Follow steps.sh to create ACL permissions for users Jack & Jill.
