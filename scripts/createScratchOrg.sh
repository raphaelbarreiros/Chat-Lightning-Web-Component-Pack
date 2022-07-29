#!/bin/bash
source `dirname $0`/config.sh

execute() {
  $@ || exit
}

if [ -z "$DEV_HUB_URL" ]; then
  echo "set default devhub user"
  execute sfdx force:config:set defaultdevhubusername=$DEV_HUB_ALIAS

  echo "deleting old scratch org"
  sfdx force:org:delete -p -u $SCRATCH_ORG_ALIAS
fi

echo "Creating scratch org"
execute sfdx force:org:create -a $SCRATCH_ORG_ALIAS -s -f ./config/project-scratch-def.json -d 30

echo "Make sure Org user is english"
sfdx force:data:record:update -s User -w "Name='User User'" -v "Languagelocalekey=en_US"

echo "Install dependencies"
execute sfdx force:package:install --package=04t4W000002g20RQAQ -u $SCRATCH_ORG_ALIAS -v $DEV_HUB_ALIAS

echo "Pushing changes to scratch org"
execute sfdx force:source:push

echo "Assigning permission"
execute sfdx force:user:permset:assign -n Admin

echo "Create sample data"
#sfdx force:apex:execute -f scripts/createSampleData.apex -u $SCRATCH_ORG_ALIAS

sh ./runTests.sh