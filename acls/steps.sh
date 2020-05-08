#Using the single node install you created in the first 30 days, Setup Authentication of your choice for two users, create an ACL to allow/de-allow something for the 2 users, publish as one user to show it works and as the other user to show it (rightly) is denied by ACL rule.

#list topics first (as admin user)
kafka-topics --bootstrap-server localhost:9094 --list --command-config admin.conf

#create new topic as Admin
kafka-topics --bootstrap-server localhost:9094 --command-config admin.conf \
--create --topic jacks-topic --partitions 1 --replication-factor 1

#give Jack WRITE access to jacks topic
#kafka-acls.sh  --add --allow-principal User:jack --operation Write --topic jacks-topic
kafka-acls --bootstrap-server localhost:9094 --command-config admin.conf --add \
--allow-principal User:jack --producer --topic jacks-topic

#give Jill READ access to jack's topic
#kafka-acls.sh --add --allow-principal User:jill --operation Read --topic jacks-topic
#kafka-acls.sh --add --allow-principal User:jill --operation Read --group jills-group
kafka-acls --bootstrap-server localhost:9094 --command-config admin.conf --add \
--allow-principal User:jack --consumer --topic jacks-topic --group jacks-group

#produce to topic as Jack
kafka-console-producer \
  --broker-list localhost:9094 \
  --topic jacks-topic \
  --producer.config jack.conf

#allow anyone BUT Jill to read from Jack's topic
#kafka-acls --bootstrap-server localhost:9094 --command-config admin.conf --add \
#--allow-principal "User:*" --allow-host '*' --deny-principal User:jill --operation Read --topic jacks-topic

#allow anyone to read 
kafka-acls --bootstrap-server localhost:9094 --command-config admin.conf --add \
--allow-principal "User:*" --allow-host '*' --consumer --topic jacks-topic --group '*'

#consume as Jill
kafka-console-consumer \
  --bootstrap-server localhost:9094 \
  --topic jacks-topic \
  --consumer.config jill.conf \
  --from-beginning

#now, use deny principal to deny Jill access to Jack's topic altogether.
kafka-acls --bootstrap-server localhost:9094 --command-config admin.conf --add \
--deny-principal "User:jill" --cluster --topic 'jacks-topic'

#try consuming again as Jill (shouldn't work)
kafka-console-consumer \
  --bootstrap-server localhost:9094 \
  --topic jacks-topic \
  --consumer.config jill.conf \
  --from-beginning

#consume as Jack
kafka-console-consumer \
  --bootstrap-server localhost:9094 \
  --topic jacks-topic \
  --consumer.config jack.conf \
  --from-beginning

