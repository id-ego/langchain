#!/bin/bash

# 환경 변수 출력
echo "VERCEL_ENV: $VERCEL_ENV"
echo "VERCEL_GIT_COMMIT_REF: $VERCEL_GIT_COMMIT_REF"

# production 환경인 경우에만 빌드 진행, 그 외에는 모든 배포 허용
if [ "$VERCEL_ENV" == "production" ]; then
    echo "✅ Production environment - proceeding with build"
    exit 1
else
    echo "✅ Preview environment - proceeding with build"
    exit 1
fi