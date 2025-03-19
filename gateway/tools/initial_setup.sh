#!/bin/sh

# Copyright (C) 2025 NEC Corporation.
# 
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.

set -e

PUBLIC_KEY=$(cat ./public_key.pem)

echo "Service ..."
curl -X POST http://gateway:8001/services -d name=layout-apply -d url='http://localhost:3500/v1.0/invoke/layout-apply/method/cdim/api/v1'
curl -X POST http://gateway:8001/services -d name=configuration-manager -d url='http://localhost:3500/v1.0/invoke/configuration-manager/method/cdim/api/v1'
curl -X POST http://gateway:8001/services -d name=performance-manager -d url='http://localhost:3500/v1.0/invoke/performance-manager/method/api/v1'

echo "Route ..."
curl -X POST http://gateway:8001/services/layout-apply/routes -d 'paths[]=/cdim/api/v1/layout-apply' -d name=layout-apply
curl -X POST http://gateway:8001/services/configuration-manager/routes -d 'paths[]=/cdim/api/v1/configuration-manager' -d name=configuration-manager
curl -X POST http://gateway:8001/services/performance-manager/routes -d 'paths[]=/cdim/api/v1/performance-manager' -d name=performance-manager

echo "CORS Plugin ..."
curl -X POST http://gateway:8001/plugins/ -d "name=cors" -d "config.origins=*"

echo "ACL Plugin ..."
curl -X POST http://gateway:8001/routes/layout-apply/plugins -d "name=acl" -d "config.allow=layout-apply-group"
curl -X POST http://gateway:8001/routes/configuration-manager/plugins -d "name=acl" -d "config.allow=configuration-manager-group"
curl -X POST http://gateway:8001/routes/performance-manager/plugins -d "name=acl" -d "config.allow=performance-manager-group"

echo "Consumer ..."
curl -X POST http://gateway:8001/consumers -d "username=cdim-client"

echo "ACL Plugin ..."
curl -X POST http://gateway:8001/consumers/cdim-client/acls -d "group=layout-apply-group"
curl -X POST http://gateway:8001/consumers/cdim-client/acls -d "group=configuration-manager-group"
curl -X POST http://gateway:8001/consumers/cdim-client/acls -d "group=performance-manager-group"

echo "JWT Plugin ..."
curl -X POST http://gateway:8001/routes/layout-apply/plugins \
  -H "accept: application/json" \
  -H "Content-Type: application/json" \
  -d '{"name": "jwt","config": {"uri_param_names": ["paramName_2.2.x"],"key_claim_name": "azp", "claims_to_verify":["exp"]}}'
curl -X POST http://gateway:8001/routes/configuration-manager/plugins \
  -H "accept: application/json" \
  -H "Content-Type: application/json" \
  -d '{"name": "jwt","config": {"uri_param_names": ["paramName_2.2.x"],"key_claim_name": "azp", "claims_to_verify":["exp"]}}'
curl -X POST http://gateway:8001/routes/performance-manager/plugins \
  -H "accept: application/json" \
  -H "Content-Type: application/json" \
  -d '{"name": "jwt","config": {"uri_param_names": ["paramName_2.2.x"],"key_claim_name": "azp", "claims_to_verify":["exp"]}}'

echo "JWT Credential ..."
curl -X POST http://gateway:8001/consumers/cdim-client/jwt \
  -H 'Content-Type: application/json' \
  -d "{\"key\": \"cdim-client\",
       \"algorithm\": \"RS256\",
       \"rsa_public_key\": \"$PUBLIC_KEY\"}"

echo "end"
