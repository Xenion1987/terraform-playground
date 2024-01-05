#!/usr/bin/env bash

# OPTIONAL: Setup oh-my-bash
if .devcontainer/scripts/setup-docker-container.sh setup oh-my-bash; then
  .devcontainer/scripts/on-create-command.sh
fi

# Install terraform autocomplete
terraform -install-autocomplete

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

# Re-source profile
# shellcheck source=/dev/null
source ~/".${SHELL##*/}rc"
if ! git status &>/dev/null; then
  git config --global --add safe.directory "${PWD}"
fi
pre-commit install
