#!/bin/bash

# ROBOT_APP=robomaker-navigation-robot-app
# SIM_APP=robomaker-navigation-sim-app

build=$1

if [ $build = true ]; then
    echo "--- build robot app ---"
    DOCKER_BUILDKIT=1 docker build . \
    --build-arg ROS_DISTRO=melodic \
    --build-arg LOCAL_WS_DIR=./robot_ws \
    --build-arg APP_NAME=navigation-robot-app \
    -t $ROBOT_APP

    echo "--- build sim app ---"
    DOCKER_BUILDKIT=1 docker build . \
    --build-arg GAZEBO_VERSION=gazebo-9 \
    --build-arg ROS_DISTRO=melodic \
    --build-arg LOCAL_WS_DIR=./simulation_ws \
    --build-arg APP_NAME=navigation-sim-app \
    -t $SIM_APP

fi

echo "--- login ecr ---"
aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.${AWS_REGION}.amazonaws.com

echo "--- docker push robot app ---"
docker tag $ROBOT_APP $ACCOUNT_ID.dkr.ecr.${AWS_REGION}.amazonaws.com/$ROBOT_APP:latest
docker push $ACCOUNT_ID.dkr.ecr.${AWS_REGION}.amazonaws.com/$ROBOT_APP

echo "--- docker push sim app ---"
docker tag $SIM_APP $ACCOUNT_ID.dkr.ecr.${AWS_REGION}.amazonaws.com/$SIM_APP:latest
docker push $ACCOUNT_ID.dkr.ecr.${AWS_REGION}.amazonaws.com/$SIM_APP