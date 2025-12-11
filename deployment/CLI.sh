
# GitHubのpersonal access token (classic)を作成し、シークレットは事前に作成しておくこと
# https://docs.github.com/ja/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens#personal-access-token-classic-%E3%81%AE%E4%BD%9C%E6%88%90
function get-secret() {
if [ "$SECRET_NAME" == "" ]; then
  echo "Secret $SECRET_NAME does not exist."
  return 1
fi
aws secretsmanager describe-secret \
    --secret-id "$SECRET_NAME" \
    --region "$REGION" \
    --profile "$TEAM_ACCOUNT_PROFILE"
}
function create-secret() {
if [ "$SECRET_NAME" == "" ]; then
  echo "Secret $SECRET_NAME does not exist."
  return 1
fi
if [ "$1" == "" ]; then
  echo "Usage: create-secret <GitHub Personal Access Token>"
  return 1
fi
if [ "$ENV" == "" ]; then
  echo "Environment variable ENV is not set."
  return 1
fi

aws secretsmanager create-secret \
    --name "$SECRET_NAME" \
    --description "GitHub repository credentials for TEAM application" \
    --secret-string '{
        "url": "https://github.com/yourname/iam-identity-center-team.git",
        "AccessToken": "'"$1"'"
    }' \
    --region "$REGION" \
    --tags Key=Project,Value=YourProjectName Key=Env,Value="$ENV" \
    --profile "$TEAM_ACCOUNT_PROFILE"
}

function delete-secret() {
if [ "$SECRET_NAME" == "" ]; then
  echo "Secret $SECRET_NAME does not exist."
  return 1
fi    

# 削除するときは以下のコマンドを使用
aws secretsmanager delete-secret \
   --secret-id "$SECRET_NAME" \
   --force-delete-without-recovery \
   --region "$REGION" \
   --profile "$TEAM_ACCOUNT_PROFILE"
}

# CloudTrailのイベントデータストアは事前に作成しておくこと
function create-eds() {
if [ "$EDS_NAME" == "" ]; then
  echo "Event data store $EDS_NAME does not exist."
  return 1
fi
if [ "$ENV" == "" ]; then
  echo "Environment variable ENV is not set."
  return 1
fi

aws cloudtrail create-event-data-store \
    --name "$EDS_NAME" \
    --multi-region-enabled \
    --organization-enabled \
    --retention-period 365 \
    --termination-protection-enabled \
    --tags-list Key=Project,Value=YourProjectName Key=Env,Value=$ENV \
    --region "$REGION" \
    --profile "$TEAM_ACCOUNT_PROFILE"
}

function delete-eds() {
if [ "$EDS_NAME" == "" ]; then
  echo "Event data store $EDS_NAME does not exist."
  return 1
fi
# 削除するときは以下のコマンドを使用
aws cloudtrail delete-event-data-store \
    --event-data-store "$EDS_NAME" \
    --region "$REGION" \
    --profile "$TEAM_ACCOUNT_PROFILE"
}