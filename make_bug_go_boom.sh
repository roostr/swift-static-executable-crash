#!/bin/bash

# Get the current working directory of this script
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Make sure we're in the same directory as the script
cd "$DIR"

# Build the docker image
printf "\nBuilding our container...\n"
docker build -t swift_static_executable_crash .

printf "\nChecking for previous instances of our container, stopping them if found\n"
for ID in $(docker ps -qf "ancestor=swift_static_executable_crash") ; do
	printf "Stopping previous docker instance: $ID\n"
	docker stop "$ID" > /dev/null
done

# Run the container
printf "\nStarting our container so we can check for the bug...\n"
CONTAINER_ID="$(docker run -p 8090:8090 -d swift_static_executable_crash)"

printf "\nListing all running containers...\n"
docker ps

# Hit the API once
printf "\nMaking a call to the API...\n"
if curl -s "http://localhost:8090/" > /dev/null
then
	printf "Call succeeded. This is expected.\n"
else
	printf "Call failed. This is not expected.\n"
fi

# Wait for a minute (and change). It seems that leaving at least 60 seconds
# between the previous call and the next call is a critical component of
# reproducing the crash.
printf "\nThis bug can be reproduced when there is at least 60 seconds between calls.\n"
printf "\nWaiting for a minute (plus a few extra seconds to be sure) before making the next call...\n"
sleep 65

# Hit the API again
printf "\nMaking another call to the API...\n"
if curl -s "http://localhost:8090/" > /dev/null
then
	printf "Call succeeded. This means the bug has NOT been reproduced.\n"
else
	printf "Call failed. This means the server has crashed and the bug was reproduced.\n"
fi

printf "\nListing all running containers... (if this listing is different than the previous listing, then our container crashed because of the bug.)\n"
docker ps

printf "\nAttempting to clean up our container, just in case it's still running (though we expect it to be crashed).\n"
docker stop "$CONTAINER_ID" > /dev/null
