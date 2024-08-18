#!/bin/bash

echo "VERCEL_ENV: $VERCEL_ENV"
echo "VERCEL_GIT_COMMIT_REF: $VERCEL_GIT_COMMIT_REF"

if [ "$VERCEL_ENV" == "production" ] || [ "$VERCEL_GIT_COMMIT_REF" == "main" ]; then 
    echo "✅ Production build - proceeding with build"
    exit 1
fi

echo "🛑 Not a production build - ignoring build"
exit 0