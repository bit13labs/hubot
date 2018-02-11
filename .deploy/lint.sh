#!/usr/bin/env bash
set -e;
shopt -s globstar;

base_dir=$(dirname "$0");
# shellcheck source=/dev/null
source "${base_dir}/shared.sh";

# get_opts() {
# 	while getopts ":n:v:o:" opt; do
# 	  case $opt in
# 			n) export opt_project_name="$OPTARG";
# 			;;
# 			v) export opt_version="$OPTARG";
# 			;;
# 			o) export opt_docker_org="$OPTARG";
# 			;;
# 			\?) echo "Invalid option -$OPTARG" >&2;
# 			exit 1;
# 			;;
# 		esac;
# 	done;
#
# 	return 0;
# };
#
# get_opts "$@";

WORKDIR="${WORKSPACE:-"$(pwd)"}"

PULL_REGISTRY="${DOCKER_REGISTRY:-"docker.artifactory.bit13.local"}"

[[ -z "${PULL_REGISTRY// }" ]] && echo "Environment variable 'PULL_REGISTRY' missing or is empty";

# # shellcheck disable=SC2035
# docker run --rm \
#   -e SHELLCHECK_OPTS="-e SC2086 -e SC2155 -e SC2002 -e SC1117" \
#   -v "${WORKDIR}":/work \
#   -w /work koalaman/shellcheck -- **/*.sh;

__info "Running coffeelint";
docker run --rm \
  -v "${WORKDIR}":/work \
  "${PULL_REGISTRY}/camalot/coffeelint";
