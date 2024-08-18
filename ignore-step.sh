#!/bin/bash

# 환경 변수 출력
echo "VERCEL_ENV: $VERCEL_ENV"
echo "VERCEL_GIT_COMMIT_REF: $VERCEL_GIT_COMMIT_REF"

# 프리뷰 빌드를 허용할 브랜치 목록
ALLOWED_PREVIEW_BRANCHES="develop staging"

# production 환경인 경우 빌드 진행
if [ "$VERCEL_ENV" == "production" ]; then
    echo "✅ Production environment - proceeding with build"
    exit 1
else
    # Preview 환경에서 특정 브랜치만 빌드 허용
    if [[ $ALLOWED_PREVIEW_BRANCHES == *"$VERCEL_GIT_COMMIT_REF"* ]]; then
        echo "✅ Preview build allowed for branch: $VERCEL_GIT_COMMIT_REF"
        exit 1
    else
        echo "🛑 Preview build blocked for branch: $VERCEL_GIT_COMMIT_REF"
        exit 0
    fi
fi