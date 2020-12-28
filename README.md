# INFO:
Implementation based to: <BR>
https://github.com/jeremylong/DependencyCheck <BR>
https://jeremylong.github.io/DependencyCheck/dependency-check-cli/arguments.html

## Shortly:
- Install OWASP dependency check tool to inside of PRODUCTION_DOCKER_IMAGE container by using volume mount and OWASP_dependency-check.sh script
- Execute dependency-check.sh with PARAMETERS against folder that is define in --scan parameter
- REPORT OUTPUT file formats: XML, HTML, CSV, JSON, JUNIT

EXIT VALUE DEFINITION:
```
    --failOnCVSS <score>        Specifies if the build should be failed if
                                a CVSS score above a specified level is
                                identified. The default is 11; since the
                                CVSS scores are 0-10, by default the build
                                will never fail.
```

# USAGE
```
chmod +x OWASP_dependency-check.sh
docker run --rm -u root \
	-v $(pwd):/source \
	--entrypoint /source/OWASP_dependency-check.sh \
	-e GITHUB_USERNAME=${GITHUB_USERNAME} \
	-e GITHUB_TOKEN=${GITHUB_TOKEN} \
	-e PARAMETERS='--out /source --format ALL --failOnCVSS 10 --scan /app' \
	<PRODUCTION_DOCKER_IMAGE>
```