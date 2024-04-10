#######################################################################
#DEPLOY BEDROCK AND KEEP THE ASSETS IN PLACE SCRIPT
#######################################################################
# ------------ CHANGE THESE VARIABLES TO CONFIGURE THE BELOW SCRIPT FOR ITS ENVIRONMENT. SHOULDN'T NEED TO CHANGE ANYTHING ELSE ------------
if [[ "$CI_BRANCH" == "release"* ]]; then USERNAME=$PRODUCTION_USERNAME; SERVER=$PRODUCTION_SERVER; fi
if [ "$CI_BRANCH" == "staging" ]; then USERNAME=$STAGING_USERNAME; SERVER=$STAGING_SERVER; fi
# ------------ COPY THE BUILD FILES TO THE REMOTE ------------
#I cannot seem to escape having to force this directory to exist, so if that's the case, so be it.
ssh -t $USERNAME@$SERVER "if [ ! -d /home/$USERNAME/build ]; then mkdir -p /home/$USERNAME/build; fi"
#a tar pipe appears to be the fastest way to deploy the entire directory.
cd ~/clone/ && tar czf - . | ssh $USERNAME@$SERVER tar xvzfC - /home/$USERNAME/build/
# ------------ EXECUTE THE INITIAL SETUP SCRIPT ------------
#I'm running this every time so I don't need to update this deploy script if I change "is this a new build" conditions / what I want to set up for initial deployments.
ssh -t $USERNAME@$SERVER "cd /home/$USERNAME/build/scripts && ./initial-setup.sh $USERNAME"
# ------------ EXECUTE THE DEPLOYMENT SCRIPTS ON THE SERVER ------------
#execute the pre-deploy script, if it exists
ssh -t $USERNAME@$SERVER "cd /home/$USERNAME/build/scripts && if [ -f pre-deploy.sh ]; then pre-deploy.sh $USERNAME; fi"
#execute the deployment script on the remote server
ssh -t $USERNAME@$SERVER "cd /home/$USERNAME/build/scripts && ./deploy.sh $USERNAME"
#execute the post-deploy script, if it exists
ssh -t $USERNAME@$SERVER "cd /home/$USERNAME/build/scripts && if [ -f post-deploy.sh ]; then post-deploy.sh $USERNAME; fi"