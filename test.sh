# get the local directory to convert relative paths to absolute ones
LOCAL_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# docker build . -f deployment/app/Dockerfile -t todorus/lindy-admin:develop
docker-compose -f $LOCAL_DIR/deployment/test.yaml build
docker-compose -f $LOCAL_DIR/deployment/test.yaml up --abort-on-container-exit --force-recreate
