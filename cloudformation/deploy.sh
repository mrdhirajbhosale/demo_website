#!/usr/bin/env bash
#AWS_PROFILE_OPTION=`create_aws_profile_option ${AWS_PROFILE}`
UUID=""
STACK_NAME="demoWebSite"
LAMBDA_VERSION="1.0"
REALM="dev"
INSTANCE=${INSTANCE}
DEFAULT_PYTHON_RUNTIME="python3.8"
CODE_S3_PREFIX=${NOW}
BucketName="web-page-${INSTANCE}"
REGION="ap-south-1"


CODE_ZIP="events-function.zip"

deploy(){

  cd ../site
  npm install
  npm run build
  ls
  cd ../cloudformation
  ls

  aws --region ${REGION} cloudformation deploy \
      --template-file template.yml \
      --stack-name ${STACK_NAME} \
      --capabilities CAPABILITY_NAMED_IAM \
      --no-fail-on-empty-changeset \
      --parameter-overrides \
      RealmName=${REALM} \
      BucketName=${BucketName}

  DISTRIBUTION_ID=$(aws --region ${REGION} cloudformation describe-stacks --stack-name $STACK_NAME --query "Stacks[0].Outputs[?OutputKey=='CloudFrontDistributionID'].OutputValue" --output text)
  aws --region ${REGION} s3 sync ../site/build s3://$BucketName --exclude README.md --exclude ".git/*" --exclude ".circleci/*" --acl public-read --delete
  aws --region ${REGION} cloudfront create-invalidation --distribution-id $DISTRIBUTION_ID --paths  '/' '/*'

}

deploy
