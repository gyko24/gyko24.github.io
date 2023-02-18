#!/usr/bin/env bash

# Run this script to deploy the app to Github Pages
# NOTE: Run in the <your-user-name>.github.io repository folder

# Parse cmd arguments

DEPLOY_BRANCH="gh-pages"

USAGE_MSG="usage: deploy [-h|--help] [-d|--deploy DEPLOY_BRANCH] [--verbose] [--no-push]"

while [[ $# > 0 ]]; do
    key="$1"

    case $key in
        -h|--help)
        echo $USAGE_MSG
        exit 0
        ;;
        -d|--deploy)
        DEPLOY_BRANCH="$2"
        shift
        ;;
        --verbose)
        set -x
        ;;
        --no-push)
        NO_PUSH="--no-push"
        ;;
        *)
        echo "Option $1 is unknown." >&2
        echo $USAGE_MSG >&2
        exit 1
        ;;
    esac
    shift
done

# Exit if any subcommand fails
set -e

echo "Deploying..."
echo "Deploy branch: $DEPLOY_BRANCH"

# Checkout DEPLOY_BRANCH branch
git checkout $DEPLOY_BRANCH

# Export JEKYLL_ENV=production
export JEKYLL_ENV=production

# Build site
bundle exec jekyll build

# Delete and move files
find . -maxdepth 1 ! -name '_site' ! -name '.git' ! -name 'CNAME' ! -name '.gitignore' -exec rm -rf {} \;
mv _site/* .
rm -R _site/

# Create `.nojekyll` file (bypass GitHub Pages Jekyll processing)
touch .nojekyll

# Push to DEPLOY_BRANCH
git add -fA
git commit --allow-empty -m "rebuilding site $(date)"
[[ ${NO_PUSH} ]] || git push -f -q origin $DEPLOY_BRANCH

echo "Deployed successfully!"

exit 0
