#!/usr/bin/env bash
##############################################
# Helper functions
##############################################
export DEBIAN_FRONTEND=noninteractive
function apt_cleanup() {
  apt -y autoremove
  apt -y autoclean
  apt -y clean
  rm -rf /var/lib/apt/lists/*
}
function apt_install() {
  apt update &&
    apt -y --no-install-recommends install "${@}" &&
    apt_cleanup
}
function get_latest_git_release() {
  local org="${1}"
  local repo="${2}"
  curl --fail -sS "https://api.github.com/repos/${org}/${repo}/releases/latest" |
    grep '"tag_name":' |
    sed -E 's/.*"([^"]+)".*/\1/'
}
function get_machine_arch() {
  local machine_arch=""
  case $(uname -m) in
  i386)
    machine_arch="386"
    ;;
  i686)
    machine_arch="386"
    ;;
  x86_64)
    machine_arch="amd64"
    ;;
  arm64)
    machine_arch="arm64"
    ;;
  aarch64)
    dpkg --print-architecture | grep -q "arm64" && machine_arch="arm64" || machine_arch="arm"
    ;;
  esac
  echo $machine_arch
}
##############################################
# Install functions
##############################################
function install_all() {
  install_os_requirements
  install_pip
  install_pip_requirements
  install_pre_commit
  install_terraform "${1}"
  install_tf_docs "${2}"
  install_tf_lint "${3}"
  install_trivy "${4}"
  install_terragrunt "${5}"
  apt_cleanup
}
function install_os_requirements() {
  apt -y purge imagemagick imagemagick-6-common
  apt_install \
    apt-transport-https \
    apt-utils \
    curl \
    dialog \
    git \
    gpg \
    gnupg \
    lsb-release \
    python3-minimal \
    python3-pip \
    openssh-client \
    sudo \
    unzip
  apt -y dist-upgrade
}
function install_pip() {
  python3 -m pip install --upgrade \
    pip
}
function install_pip_requirements() {
  if [[ $(grep -Evc '^[[:space:]]*#' .devcontainer/requirements.txt) -gt 0 ]]; then
    python3 -m pip install --upgrade \
      -r .devcontainer/requirements.txt
  fi
}
function install_pre_commit() {
  python3 -m pip install --upgrade \
    pre-commit
}
function install_terraform() {
  local tf_version
  tf_version="${1:-latest}"
  if [[ ${tf_version} == "latest" ]]; then
    tf_version="terraform"
  else
    tf_version="terraform=${tf_version}-1"
  fi
  curl -sSLo - https://apt.releases.hashicorp.com/gpg |
    gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
  echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" |
    tee /etc/apt/sources.list.d/hashicorp.list
  apt_install "${tf_version}"
}
function install_terragrunt() {
  local machine_arch machine_os version
  local org=gruntwork-io
  local repo=terragrunt
  local binary_path=/usr/bin
  local binary_name=terragrunt
  machine_arch=$(get_machine_arch)
  machine_os=$(uname)
  machine_os=${machine_os,,}
  version="${1:-latest}"

  if [[ ${version} == "latest" ]]; then
    version=$(get_latest_git_release "${org}" "${repo}")
  fi
  curl -sSLo "${binary_path}/${binary_name}" \
    --url "https://github.com/${org}/${repo}/releases/download/${version}/terragrunt_${machine_os}_${machine_arch}"
  chmod +x "${binary_path}/${binary_name}"
}
function install_tf_docs() {
  local machine_arch machine_os version
  local org=terraform-docs
  local repo=terraform-docs
  local binary_path=/usr/bin
  local binary_name=terraform-docs

  machine_arch=$(get_machine_arch)
  machine_os=$(uname)
  machine_os=${machine_os,,}
  version="${1:-latest}"
  if [[ ${version} == "latest" ]]; then
    version=$(get_latest_git_release "${org}" "${repo}")
  fi
  curl -sSLo /tmp/terraform-docs.tar.gz \
    --url "https://terraform-docs.io/dl/${version}/terraform-docs-${version}-${machine_os}-${machine_arch}.tar.gz"
  tar -xzf /tmp/terraform-docs.tar.gz -C /tmp/
  chmod +x "/tmp/${binary_name}"
  mv "/tmp/${binary_name}" "${binary_path}/${binary_name}"
  rm -f /tmp/{README.md,LICENSE,*{.tar,.tgz,.gz}}
}
function install_tf_lint() {
  local TFLINT_VERSION
  export TFLINT_VERSION="${1:-latest}"
  curl -sSL https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash
}
function install_trivy() {
  local version
  version="${1:-latest}"
  if [[ ${version} == "latest" ]]; then
    version="trivy"
  else
    version="trivy=${version}-1"
  fi
  curl -sSLo - https://aquasecurity.github.io/trivy-repo/deb/public.key |
    gpg --dearmor -o /usr/share/keyrings/trivy.gpg
  echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" |
    tee /etc/apt/sources.list.d/trivy.list
  apt_install "${version}"
}
##############################################
# Setup functions
##############################################
function setup_python_argcomplete() {
  if [ -f /usr/bin/activate-global-python-argcomplete3 ]; then
    /usr/bin/activate-global-python-argcomplete3
  elif [ -f /usr/bin/activate-global-python-argcomplete ]; then
    /usr/bin/activate-global-python-argcomplete
  else
    return 0
  fi
}
function setup_user() {
  local usr
  # local pswd
  usr="${1}"
  useradd -m -s /bin/bash "${usr}"
  usermod -a -G sudo "${usr}"
  # pswd=$(
  #   tr </dev/urandom -dc '_A-Z-a-z-0-9' | head -c"${2:-13}"
  #   echo
  # )
  # chpasswd <<<"${usr}:${pswd}"
  # echo "${pswd}" >"/home/${usr}/sudo_password.txt"
  echo "${usr} ALL=(ALL) NOPASSWD: ALL" >"/etc/sudoers.d/50-${usr}"
  chmod 400 "/etc/sudoers.d/50-${usr}"
  sed -i -r \
    -e 's/^([[:space:]]*)#(.*)--color(.*)/\1\2--color\3/' \
    -e 's/#force_color_prompt/force_color_prompt/' \
    -e 's/^([[:space:]]*)PS1(.*)\\\$/\1PS1\2\\n\\$/' \
    "/home/${usr}/.bashrc"
}
function setup_omb() {
  local theme
  local user_home
  theme="${1:-powerline-multiline}"
  user_home="$(awk -F':' '{print $6}' < <(getent passwd "$(whoami)"))"

  if ! ls -1Ad "${user_home}/.oh-my-bash" &>/dev/null; then
    rm -rf "${user_home}/.oh-my-bash"
  fi
  curl -fsSL -o /tmp/install.sh https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh
  chmod +x /tmp/install.sh
  if /tmp/install.sh --unattended; then
    sed -E -i \
      -e '/composer/d' \
      -e 's/OSH_THEME="(.*)"/OSH_THEME="'"${theme}"'"/' \
      ~/.bashrc
    rm -f /tmp/install.sh
  fi
}
function setup_ssh_key() {
  local usr
  usr="${1}"
  su - "${usr}" -c 'ssh-keygen -q -t rsa -b 4096 -f ~/.ssh/id_rsa -N "" -C "ansible_devcontainer" <<<y >/dev/null'
}
##############################################
# Help functions
##############################################
function help() {
  cat <<_ENDOFHELP

 USAGE:
  ./${0} COMMAND SUB-COMMAND

 COMMANDS:
  install       - Install applications
  setup         - Setup applications

 SUB-COMMANDS:
  help          - Show [COMMAND] help


_ENDOFHELP
}
function help_install() {
  cat <<_ENDOFHELP

 USAGE:
  ./${0} install SUB-COMMAND

 COMMAND:
  install                   - Install applications

 SUB-COMMANDS:
  all \\
    [TF_VERSION] \\
    [TFDOCS_VERSION] \\
    [TFLINT_VERSION] \\
    [TFTRIVY_VERSION] \\
    [TERRAGRUNT_VERSION]    - Install all applications
  help                      - Show [COMMAND] help
  pip                       - Install pip
  pip-requirements          - Install pip packages from requirements.txt
  pre-commit                - Install PreCommit via pip
  os-requirements           - Install OS requirements
  terraform [VERSION]       - Install terraform VERSION (default: latest)
  terraform-docs [VERSION]  - Install terraform-docs VERSION (default: latest)
  terragrunt [VERSION]      - Install terragrunt VERSION (default: latest)
  tflint [VERSION]          - Install terraform-lint VERSION (default: latest)
  trivy [VERSION]           - Install trivy VERSION (default: latest)



_ENDOFHELP
}
function help_setup() {
  cat <<_ENDOFHELP

 USAGE:
  ./${0} setup SUB-COMMAND [OPTIONS]

 COMMAND:
  setup               - Setup applications

 SUB-COMMANDS:
  help                - Show [COMMAND] help
  oh-my-bash [THEME]  - Setup Oh-My-Bash command line with theme THEME (default: 'powerline-multiline')
  python-argcomplete  - Setup Python-Argcomplete
  ssh-key USERNAME    - Add USERNAME's id_rsa ssh key pair
  user USERNAME       - Add linux user USERNAME



_ENDOFHELP
}
##############################################
# Main function
##############################################
function main() {
  case $1 in
  install)
    shift
    case $1 in
    all)
      shift
      install_all "${1:-latest}" "${2:-latest}" "${3:-latest}" "${4:-latest}" "${5:-latest}"
      ;;
    pip)
      install_pip
      ;;
    pip-requirements)
      install_pip_requirements
      ;;
    pre-commit)
      install_pre_commit
      ;;
    os-requirements)
      install_os_requirements
      ;;
    terraform)
      shift
      install_terraform "${1}"
      ;;
    terraform-docs)
      shift
      install_tf_docs "${1}"
      ;;
    terragrunt)
      shift
      install_terragrunt "${1}"
      ;;
    tflint)
      shift
      install_tf_lint "${1}"
      ;;
    trivy)
      shift
      install_trivy "${1}"
      ;;
    *)
      echo "Missing or wrong SUB-COMMAND - Exit"
      help_install
      exit 1
      ;;
    esac
    ;;
  setup)
    shift
    case $1 in
    oh-my-bash)
      shift
      setup_omb "${1}"
      ;;
    python-argcomplete)
      setup_python_argcomplete
      ;;
    user)
      shift
      if [[ -z "${1}" ]]; then
        echo "Missing USERNAME - Exit"
        help_setup
        exit 1
      fi
      setup_user "${1}"
      ;;
    ssh-key)
      shift
      if [[ -z "${1}" ]]; then
        echo "Missing USERNAME - Exit"
        help_setup
        exit 1
      fi
      setup_ssh_key "${1}"
      ;;
    *)
      echo "Missing or wrong SUB-COMMAND - Exit"
      help_setup
      exit 1
      ;;
    esac
    ;;
  *)
    echo "Missing or wrong SUB-COMMAND - Exit"
    help
    exit 1
    ;;
  esac
}
main "${@}"
