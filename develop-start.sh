# get the local directory to convert relative paths to absolute ones
LOCAL_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

#docker run -it -v $LOCAL_DIR/rails-app:/rails-app todorus/lindy-admin:develop /bin/bash
docker-compose -f $LOCAL_DIR/deployment/develop.yaml up
