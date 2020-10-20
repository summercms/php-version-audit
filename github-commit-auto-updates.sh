#!/bin/sh
set -eu

cat <<- EOF > "${HOME}/.netrc"
        machine github.com
        login $GITHUB_ACTOR
        password $GITHUB_TOKEN
        machine api.github.com
        login $GITHUB_ACTOR
        password $GITHUB_TOKEN
EOF
chmod 600 "${HOME}/.netrc"
git config --global user.email "daniel@developerdan.com"
git config --global user.name "Auto Updates"

COMMIT_MESSAGE="Automatic github actions updates."
LINES_ADDED=$(git diff --numstat docs/rules-v1.json | sed 's/^\([0-9]*\)\(.*\)/\1/g')
if [ "$LINES_ADDED" -gt "1" ]; then
   COMMIT_MESSAGE="${COMMIT_MESSAGE} Changes found @lightswitch05"
fi

git add ./docs/rules-v1.json
git commit -m "${COMMIT_MESSAGE}"
LAST_TAG=$(git tag -l --sort=v:refname | tail -1)
echo "Last tag: ${LAST_TAG}"
MAJOR_VERSION="${LAST_TAG%%.*}"
echo "Major version: ${MAJOR_VERSION}"
MINOR_VERSION=$(date +"%Y%m%d")
echo "Minor version: ${MINOR_VERSION}"
PATCH_VERSION="${LAST_TAG##*.}"
echo "Patch version: ${PATCH_VERSION}"
NEW_TAG="${MAJOR_VERSION}.${MINOR_VERSION}.$((PATCH_VERSION+1))"
echo "New tag: ${NEW_TAG}"
git tag "${NEW_TAG}"
git push origin : "${NEW_TAG}"
