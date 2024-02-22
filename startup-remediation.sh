#!/usr/bin/env bash
#MYDIR=$(dirname $0)

if [[ "$1" == "" ]]; then
  read -e -i "${DOCKER_ACCOUNT}" -p "Please enter your DockerHub user/account name: " input
  name="${input:-$DOCKER_ACCOUNT}"
else
  DOCKER_ACCOUNT=$1
fi

#cat $MYDIR/logshell-vuln.yaml | envsubst | kubectl apply -f -
cat logshell-remediation.yaml | envsubst | kubectl apply -f -

echo "⌚️ Waiting for pod deployment..."
kubectl wait --for=condition=running pod \
             --selector=app=log4shell-vulnerable-app \
             --timeout=5m

echo "Done."
