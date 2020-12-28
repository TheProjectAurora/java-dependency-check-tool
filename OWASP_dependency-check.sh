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

GITHUB_USERNAME=${GITHUB_USERNAME}
GITHUB_TOKEN=${GITHUB_TOKEN}
PARAMETERS=${PARAMETERS}

PACKAGES="curl wget unzip"
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
    CURL_CONTENT=$(curl --silent -i -u ${GITHUB_USERNAME}:${GITHUB_TOKEN} https://github.com/jeremylong/DependencyCheck/blob/main/RELEASE_NOTES.md)
    export VERSION=$(echo "${CURL_CONTENT}" | grep 'https://github.com/jeremylong/DependencyCheck/releases/tag/v' | head -1 | grep -o '>Version .*<' | awk -F'<' '{print $1}' | awk -F' ' '{print $2}');
    echo VERSION_IS:${VERSION}
    if [ "${VERSION}" != "" ]
    then
        break;
    fi
    LOOP_ROUNDS=$((${LOOP_ROUNDS} -1 ))
    sleep 6m
done
echo "https://github.com/jeremylong/DependencyCheck/releases/download/v${VERSION}/dependency-check-${VERSION}-release.zip"
wget -q --header=PRIVATE-TOKEN:${GITHUB_TOKEN} https://github.com/jeremylong/DependencyCheck/releases/download/v${VERSION}/dependency-check-${VERSION}-release.zip
unzip dependency-check-${VERSION}-release.zip
chmod +x ./dependency-check/bin/dependency-check.sh
#./dependency-check/bin/dependency-check.sh --out /source --failOnCVSS 10 --scan /app
./dependency-check/bin/dependency-check.sh ${PARAMETERS}