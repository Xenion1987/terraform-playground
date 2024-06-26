#!/usr/bin/env bash

# Add newline to PS1
sed -r -i 's/}\\\$ "$/}\\n\\$ "/' ~/".${SHELL##*/}rc"

# Install terraform autocomplete
terraform -install-autocomplete
terragrunt --install-autocomplete

# Install terraform-docs autocomplete
if ! grep -q 'terraform-docs completion' ~/".${SHELL##*/}rc"; then
  # shellcheck disable=SC2016
  echo -e 'source <(terraform-docs completion "${SHELL##*/}")' >>~/".${SHELL##*/}rc"
fi

# Install trivy autocomplete
if ! grep -q 'trivy completion' ~/".${SHELL##*/}rc"; then
  # shellcheck disable=SC2016
  echo -e 'source <(trivy completion "${SHELL##*/}")' >>~/".${SHELL##*/}rc"
fi

if ! git status &>/dev/null; then
  git config --global --add safe.directory "${PWD}"
fi
pre-commit install

# # Create silent ssh config file
# [[ -d ~/.ssh ]] || mkdir ~/.ssh
# chmod 700 ~/.ssh
# cat << _EOF > ~/.ssh/config
# StrictHostKeyChecking no
# UserKnownHostsFile /dev/null
# LogLevel ERROR
# _EOF

# Add functions to source aws and openstack credentials
if [[ ! $(grep -qo source-aws-credentials ~/".${SHELL##*/}rc") == "source-aws-credentials" ]]; then
  cat <<_EOF >>~/".${SHELL##*/}rc"

function source-aws-credentials() {
  export AWS_DEFAULT_REGION=\$(awk -F' = ' '/region/ {print \$NF}' ~/.aws/config)
  export AWS_ENDPOINT_URL=\$(awk -F' = ' '/endpoint/ {print \$NF}' ~/.aws/config)
  export AWS_ACCESS_KEY_ID=\$(awk -F' = ' '/aws_access_key_id/ {print \$NF}' ~/.aws/credentials)
  export AWS_SECRET_ACCESS_KEY=\$(awk -F' = ' '/aws_secret_access_key/ {print \$NF}' ~/.aws/credentials)
  grep -E '^AWS' < <(env | sort)
}
_EOF
fi
if [[ ! $(grep -qo source-openstack-credentials ~/".${SHELL##*/}rc") == "source-openstack-credentials" ]]; then
  cat <<_EOF >>~/".${SHELL##*/}rc"

function source-openstack-credentials() {
  . ~/.config/openstack/groupone-mcs-openstack.sh \\
    && grep "OS_" < <(env | sort)
}
_EOF
fi
if ! grep -qo 'function sc' ~/".${SHELL##*/}rc"; then
  cat <<_EOF >>~/".${SHELL##*/}rc"

# Source AWS and OS credentials and print them safely
function sc() {
  local o
  o=\$(source-aws-credentials)
  o+=\$'\n'
  o+=\$(source-openstack-credentials)
  while read -r v; do
    export \$v
  done <<<"\${o}"
  sed -E \\
    -e 's/^(.*ACCESS_KEY.*)=(.*)$/\1=***/' \\
    -e 's/^(OS_PASSWORD=)(.*)$/\1***/' <<<"\${o}" | \\
      column -s '=' -t
}
_EOF
fi
if ! grep -qo 'function cc' ~/".${SHELL##*/}rc"; then
  cat <<_EOF >>~/".${SHELL##*/}rc"

# Check environment for AWS and OS credentials and print them safely
function cc() {
  local o
  o=\$(grep -E -e "^AWS_" -e "^OS_"< <(env | sort))
  sed -E \\
    -e 's/^(.*ACCESS_KEY.*)=(.*)$/\1=***/' \\
    -e 's/^(OS_PASSWORD=)(.*)$/\1***/' <<<"\${o}" | \\
      column -s '=' -t
}
_EOF
fi
if ! grep -qo 'eval sc' ~/".${SHELL##*/}rc"; then
  cat <<_EOF >>~/".${SHELL##*/}rc"

eval sc
_EOF
fi

if command -v openstack &>/dev/null; then
  if ! grep -qo 'openstack complete' ~/".${SHELL##*/}rc"; then
    cat <<_EOF >>~/".${SHELL##*/}rc"

source <(openstack complete)
_EOF
  fi
fi
