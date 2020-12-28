#!/bin/bash
set -e

## EXECUTE https://github.com/jeremylong/DependencyCheck VULNEABILITY CHECK AGAINS JAR files.
## PARAMETERS: https://jeremylong.github.io/DependencyCheck/dependency-check-cli/arguments.html
# chmod +x OWASP_dependency-check.sh
# docker run --rm -u root \
# 	-v $(pwd):/source \
# 	--entrypoint /source/OWASP_dependency-check.sh \
# 	-e GITHUB_USERNAME=${GITHUB_USERNAME} \
# 	-e GITHUB_TOKEN=${GITHUB_TOKEN} \
# 	-e PARAMETERS='--out /source --format ALL --failOnCVSS 10 --scan /app' \
# 	<PRODUCTION_DOCKER_IMAGE>

#NOTE: 
#    --failOnCVSS <score>        Specifies if the build should be failed if
#                                a CVSS score above a specified level is
#                                identified. The default is 11; since the
#                                CVSS scores are 0-10, by default the build
#                                will never fail.

GITHUB_USERNAME=${GITHUB_USERNAME}
GITHUB_TOKEN=${GITHUB_TOKEN}
PARAMETERS=${PARAMETERS}

PACKAGES="curl wget unzip jq"
if [ -e /etc/alpine-release ];
then
    apk --no-cache add ${PACKAGES}
else
    apt-get update
    apt-get install -y ${PACKAGES}
fi

LOOP_ROUNDS=11
while [ ${LOOP_ROUNDS} -gt 0 ]
do
    CURL_CONTENT=$(curl --silent -u ${GITHUB_USERNAME}:${GITHUB_TOKEN} "https://api.github.com/repos/jeremylong/DependencyCheck/releases/latest")
    export HTML_URL=$(echo "${CURL_CONTENT}" | jq '.assets[] | select(.content_type | contains("application/zip"))' | jq -r '.browser_download_url' | grep -v ant );
    echo HTML_URL:${HTML_URL}
    if [ "${HTML_URL}" != "" ]
    then
        break;
    fi
    LOOP_ROUNDS=$((${LOOP_ROUNDS} -1 ))
    sleep 6m
done
wget -q --header=PRIVATE-TOKEN:${GITHUB_TOKEN} ${HTML_URL}
unzip dependency-check-*-release.zip
chmod +x ./dependency-check/bin/dependency-check.sh
#./dependency-check/bin/dependency-check.sh --out /source --failOnCVSS 10 --scan /app
./dependency-check/bin/dependency-check.sh ${PARAMETERS}