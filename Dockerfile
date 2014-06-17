FROM ubuntu:trusty
MAINTAINER cptactionhank <cptactionhank@users.noreply.github.com>

RUN apt-get -qq update \
    && apt-get -yqq install ca-certificates ssl-cert ldap-utils slapd

EXPOSE 389

# Add VOLUMEs to allow backup of config, logs and databases
# * To store the data outside the container, mount /var/lib/ldap as a data volume
VOLUME ["/etc/ldap", "/var/lib/ldap", "/run/slapd"]

ENTRYPOINT ["slapd", "-h", "ldap:/// ldapi:///"]
