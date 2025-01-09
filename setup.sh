#!/bin/bash

# pydantic workaround for specific windows/python version. Ref: https://github.com/pydantic/pydantic/issues/6557
mkdir -p package
pip install pydantic==2.6.1 boto3 openai --only-binary=:all: --upgrade --platform manylinux2014_x86_64 --target ./package --implementation cp --python-version 3.8
cd package
zip -r ../deployment_package.zip .
cd ..
zip deployment_package.zip lambda_function.py
echo "Deployment package created successfully: deployment_package.zip"
