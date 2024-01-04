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
  install_tf_trivy "${4}"
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
  if [[ $(grep -Evc '^[[:space:]]*#' ../requirements.txt) -ge 0 ]]; then
    python3 -m pip install --upgrade \
      -r ../requirements.txt
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
function install_tf_docs() {
  local machine_arch machine_os tfdocs_version
  machine_arch=$(get_machine_arch)
  machine_os=$(uname)
  machine_os=${machine_os,,}
  tfdocs_version="${1:-latest}"
  if [[ ${tfdocs_version} == "latest" ]]; then
    tfdocs_version=$(curl --fail -sS "https://api.github.com/repos/terraform-docs/terraform-docs/releases/latest" |
      grep '"tag_name":' |
      sed -E 's/.*"([^"]+)".*/\1/')
  fi
  curl -sSLo /tmp/terraform-docs.tar.gz \
    --url "https://terraform-docs.io/dl/${tfdocs_version}/terraform-docs-${tfdocs_version}-${machine_os}-${machine_arch}.tar.gz"
  tar -xzf /tmp/terraform-docs.tar.gz -C /tmp/
  chmod +x /tmp/terraform-docs
  mv /tmp/terraform-docs /usr/local/bin/
  rm -f /tmp/{README.md,LICENSE,terraform-docs.tar.gz}
}
function install_tf_lint() {
  local TFLINT_VERSION
  export TFLINT_VERSION="${1:-latest}"
  curl -sSL https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash
}
function install_tf_trivy() {
  local tftrivy_version
  tftrivy_version="${1:-latest}"
  if [[ ${tftrivy_version} == "latest" ]]; then
    tftrivy_version="trivy"
  else
    tftrivy_version="trivy=${tftrivy_version}-1"
  fi
  curl -sSLo - https://aquasecurity.github.io/trivy-repo/deb/public.key |
    gpg --dearmor -o /usr/share/keyrings/trivy.gpg
  echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" |
    tee /etc/apt/sources.list.d/trivy.list
  apt_install "${tftrivy_version}"
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
  theme="${1:-powerline-multiline}"
  bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)" &&
    sleep 1
  sed -E -i \
    -e '/composer/d' \
    -e 's/OSH_THEME="(.*)"/OSH_THEME="'"${theme}"'"/' \
    ~/.bashrc
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
  all
    [TF_VERSION]
    [TFDOCS_VERSION]
    [TFLINT_VERSION]
    [TFTRIVY_VERSION]       - Install all applications
  help                      - Show [COMMAND] help
  pip                       - Install pip
  pip-requirements          - Install pip packages from requirements.txt
  pre-commit                - Install PreCommit via pip
  os-requirements           - Install OS requirements
  terraform [VERSION]       - Install terraform VERSION (default: latest)
  terraform-docs [VERSION]  - Install terraform-docs VERSION (default: latest)
  terraform-lint [VERSION]  - Install terraform-lint VERSION (default: latest)


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
      install_all "${1:-latest}" "${2:-latest}" "${3:-latest}" "${4:-latest}"
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
    terraform-lint)
      shift
      install_tf_lint "${1}"
      ;;
    terraform-trivy)
      shift
      install_tf_trivy "${1}"
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
