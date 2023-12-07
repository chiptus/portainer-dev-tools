#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# This script generates LDIF file with users and groups for testing LDAP

LDIF_FILE="init-data.ldif"

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <num_groups> <num_users_per_group>"
  exit 1
fi

NUM_GROUPS=$1
NUM_USERS_PER_GROUP=$2

# Function to generate LDIF entry for a user
generate_user_entry() {
  local CN="$1"
  local SN="$2"
  local userId="$3"
  local PASSWORD="$4"

  cat <<EOL
# Entry for $CN
dn: uid=$userId,ou=users,{{ LDAP_BASE_DN }}
objectClass: top
objectClass: person
objectClass: organizationalPerson
objectClass: inetOrgPerson
uid: $userId
cn: $CN
sn: $SN
givenName: User
userPassword: $PASSWORD

EOL
}

# Function to generate LDIF entry for a group
generate_group_entry() {
  local CN="$1"
  local MEMBERS=("${@:2}")

  cat <<EOL
# Entry for $CN
dn: cn=$CN,ou=groups,{{ LDAP_BASE_DN }}
objectClass: top
objectClass: groupOfNames
cn: $CN
description: $CN
$(for member in "${MEMBERS[@]}"; do echo "member: $member"; done)

EOL
}

# Clear the LDIF file
echo "" > "$LDIF_FILE"

# Entry for the root
cat <<EOL > "$LDIF_FILE"

# Entry for the users organizational unit
dn: ou=users,{{ LDAP_BASE_DN }}
objectClass: top
objectClass: organizationalUnit
ou: users
description: Users

# Entry for the users organizational unit
dn: ou=groups,{{ LDAP_BASE_DN }}
objectClass: top
objectClass: organizationalUnit
ou: groups
description: Groups

EOL

# Generate LDIF entries for groups and users
{
  for ((i=1; i<=$NUM_GROUPS; i++)); do
    group_members=()
    for ((j=1; j<=$NUM_USERS_PER_GROUP; j++)); do
      user_cn="User$((i * 10 + j))"
      user_sn="$((i * 10 + j))"
      user_uid="user$((i * 10 + j))"
      user_password="Password$((i * 10 + j))"
      generate_user_entry "$user_cn" "$user_sn" "$user_uid" "$user_password"
      group_members+=("uid=$user_uid,ou=users,{{ LDAP_BASE_DN }}")
    done
    generate_group_entry "Group$i" "${group_members[@]}"
  done
} >> "$LDIF_FILE"

echo "LDIF file generated: $LDIF_FILE"