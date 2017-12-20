#!/bin/bash

set -eu

if [[ "${FLY_CACERT:-X}" == "X" ]]; then
  fly --target tutorial login \
      --concourse-url ${FLY_URL:?required} \
      --username      ${FLY_USERNAME:?required} \
      --password      ${FLY_PASSWORD:?required} \
      --team-name main
else
  echo "$FLY_CACERT" > fly.cacert
  fly --target tutorial login \
      --concourse-url ${FLY_URL:?required} \
      --username      ${FLY_USERNAME:?required} \
      --password      ${FLY_PASSWORD:?required} \
      --team-name main \
      --ca-cert       fly.cacert
fi

echo "${CREDHUB_CACERT:?required}" > credhub.cacert
credhub login \
      --server  ${CREDHUB_URL:?required} \
      --ca-cert credhub.cacert \
      --username ${CREDHUB_USERNAME:?required} \
      --password ${CREDHUB_PASSWORD:?required}

export fly_target=tutorial

cd ${REPO_ROOT:?required}

./tutorials/test-pipeline-vars.sh

for f in tutorials/*/*/test.sh
do
  echo "\n\n\nlesson $f\n"
  pushd `dirname $f`
  ./test.sh
  popd
done
