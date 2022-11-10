#!/bin/bash
# Copyright 2020 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


DEFAULT_CONFIG_DIR=$HOME/git/chromebook-config
echo "New config directory"
echo "hit <enter> for default: '$DEFAULT_CONFIG_DIR'"
read -e -p "config dir: " CONFIG_DIR
CONFIG_DIR=${CONFIG_DIR:-$DEFAULT_CONFIG_DIR}
echo "You are about to copy custom config files to: $CONFIG_DIR"
read -e -p "Hit <enter> to continue or 'ctrl c' to exit." KEY_PRESS
mkdir -p $CONFIG_DIR
cp -R ./includes_custom $CONFIG_DIR
cp -R ./playbooks_custom $CONFIG_DIR
cp ./ansible.cfg $CONFIG_DIR
cp -R ./hosts.yml $CONFIG_DIR