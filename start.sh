#!/bin/sh

set -eu

if [ ! -e /etc/ldap/bootstrap.lock ]; then
  echo "Configuring OpenLDAP"
  cat <<EOF | debconf-set-selections
slapd slapd/internal/generated_adminpw password ${LDAP_ROOTPASS:-secret}
slapd slapd/internal/adminpw password ${LDAP_ROOTPASS:-secret}
slapd slapd/password2 password ${LDAP_ROOTPASS:-secret}
slapd slapd/password1 password ${LDAP_ROOTPASS:-secret}
slapd slapd/dump_database_destdir string /var/backups/slapd-VERSION
slapd slapd/domain string ${LDAP_DOMAIN:-example.com}
slapd shared/organization string ${LDAP_ORGANISATION:-Example Corporation}
slapd slapd/backend string HDB
slapd slapd/purge_database boolean true
slapd slapd/move_old_database boolean true
slapd slapd/allow_ldap_v2 boolean false
slapd slapd/no_configuration boolean false
slapd slapd/dump_database select when needed
EOF
  DEBIAN_FRONTEND=noninteractive dpkg-reconfigure -f noninteractive slapd

  echo "Bootstrap finished."
  touch /etc/ldap/bootstrap.lock
else
  echo "Already bootstrapped. Skipping."
fi

echo "Starting OpenLDAP"
exec slapd -h "ldap:/// ldapi:///" -u openldap -g openldap ${LDAP_OPTS:-} -d ${LDAP_DEBUG:-"stats"}
