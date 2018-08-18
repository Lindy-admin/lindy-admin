# get the local directory to convert relative paths to absolute ones
LOCAL_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

docker-compose -f $LOCAL_DIR/deployment/test-setup.yaml up --abort-on-container-exit --force-recreate
