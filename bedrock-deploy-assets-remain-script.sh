#######################################################################
#DEPLOY BEDROCK AND KEEP THE ASSETS IN PLACE SCRIPT
#######################################################################
# ------------ CHANGE THESE VARIABLES TO CONFIGURE THE BELOW SCRIPT FOR ITS ENVIRONMENT. SHOULDN'T NEED TO CHANGE ANYTHING ELSE ------------
if [[ "$CI_BRANCH" == "release"* ]]; then USERNAME=$PRODUCTION_USERNAME; SERVER=$PRODUCTION_SERVER; fi
if [ "$CI_BRANCH" == "staging" ]; then USERNAME=$STAGING_USERNAME; SERVER=$STAGING_SERVER; fi

# ------------ COPY THE BUILD FILES TO THE REMOTE ------------
#a tar pipe appears to be the fastest way to deploy the entire directory.
cd ~/clone/ && tar czf - . | ssh $USERNAME@$SERVER tar xvzfC - /home/$USERNAME/build/

#####SCP????
#scp -rp ~/clone/* ssh_user@your.server.com:/path/on/server/    -    https://docs.cloudbees.com/docs/cloudbees-codeship/latest/basic-continuous-deployment/deployment-with-ftp-sftp-scp#_run_commands_on_a_remote_server_via_ssh

ssh -t $USERNAME@$SERVER "cd /home/$USERNAME/build && ./deploy.sh $USERNAME"