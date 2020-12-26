#!/usr/bin/env bash
#AWS_PROFILE_OPTION=`create_aws_profile_option ${AWS_PROFILE}`
UUID=""
STACK_NAME="demoWebSite"
LAMBDA_VERSION="1.0"
REALM="dev"
INSTANCE="dev"
DEFAULT_PYTHON_RUNTIME="python3.8"
CODE_S3_PREFIX=${NOW}
BucketName="demo-web-page"
REGION="ap-south-1"


CODE_ZIP="events-function.zip"

deploy(){
  rm ./events/cloudformation/${CODE_ZIP}
  cd ./events/lambda/api

  pip3 install -r ./requirements.txt --target ./
  cp -r /root/LambdaCDDemo/events/lambda/dispatcher dispatcher
  zip -r ../../cloudformation/${CODE_ZIP} .

  ls
  cd ../../cloudformation
  ls

  aws --region ${REGION} cloudformation deploy \
      --template-file template.yml \
      --stack-name ${STACK_NAME} \
      --capabilities CAPABILITY_NAMED_IAM \
      --no-fail-on-empty-changeset \
      --parameter-overrides \
      RealmName=${REALM} \
      BucketName=${BUCKET_NAME} \

      DISTRIBUTION_ID=$(aws --region ${REGION} cloudformation describe-stacks --stack-name $STACK_NAME --query "Stacks[0].Outputs[?OutputKey=='CloudFrontDistributionID'].OutputValue" --output text)
      aws --region ${REGION} s3 sync ../build s3://$EVENTS_UI_BUCKET_NAME --exclude README.md --exclude ".git/*" --exclude ".circleci/*" --acl public-read --delete
      aws --region ${REGION} cloudfront create-invalidation --distribution-id $DISTRIBUTION_ID --paths '/' '/\*'

}

deploy
