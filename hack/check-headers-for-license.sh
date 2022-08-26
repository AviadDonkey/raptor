#!/bin/bash

# Copyright (c) 2022 RaptorML authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -o errexit
set -o nounset
set -o pipefail

function listPkgDirs() {
	go list -f '{{.Dir}}' -tags=ignore_autogenerated ./... | grep -v generated
}

#Lists all go files
function listFiles() {
	# pipeline is much faster than for loop
	listPkgDirs | xargs -I {} find {} \( -name '*.go' -o -name '*.sh' \)  | grep -v generated
}

echo "Checking for license header..."
echo ""
allfiles=$(listFiles | sort | uniq)
licRes=""
for file in $allfiles; do
  if ! head -n4 "${file}" | grep -Eq "(Copyright|generated|GENERATED|Licensed)" ; then
    licRes="${licRes}\n  - ${file}"
    if [ ! -z ${GITHUB+x} ]; then
      echo "::error file=${file/$(pwd)\//},line=1,col=5::Missing license header"
    fi
  fi
done
if [ -n "${licRes}" ] && [ -z ${GITHUB+x} ]; then
  echo -e "\033[0;31mLicense header checking failed:\033[0m"
  echo -e "${licRes}"
fi

if [ -n "${licRes}" ]; then
  exit 1
fi