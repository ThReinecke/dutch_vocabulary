#!/bin/bash

mkdir -p package
pip install pydantic==2.6.1 boto3 openai --only-binary=:all: --upgrade --platform manylinux2014_x86_64 --target ./package --implementation cp --python-version 3.8
cd package
zip -r ../my_deployment_package.zip .
cd ..
zip my_deployment_package.zip lambda_function.py
echo "Deployment package created successfully: my_deployment_package.zip"
