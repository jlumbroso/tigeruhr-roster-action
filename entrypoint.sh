#!/bin/sh -l

# FIRST TRY TO CHECKOUT REPO 

# Configure Git generic
git config --global user.email "github_actions@users.noreply.github.com"
git config --global user.name "github_actions"

# Switch from HTTP2 -> HTTP1.1
# See https://stackoverflow.com/a/59474908/408734
echo "Using HTTP 1.1"
git config --global http.version HTTP/1.1

# Change POST buffer chunk size
# TODO: Set this to largest individual file size as per Atlassian recommendations
# See https://confluence.atlassian.com/bitbucketserverkb/git-push-fails-fatal-the-remote-end-hung-up-unexpectedly-779171796.html
echo "Using large POST buffer size"
git config --global http.postBuffer 157286400

git remote prune origin

echo "<> Cloning destination git repository"
git clone --single-branch "./"

rm -Rf "${INPUT_ROSTER_FILENAME}.csv"

# UPDATE FILE

cat <<EOF | pipenv run python update_tigeruhr_rosters.py
{
  "tigeruhr_username": "${INPUT_TIGERUHR_API_USERNAME}",
  "tigeruhr_password": "${INPUT_TIGERUHR_API_PASSWORD}",
  "tigeruhr_position": "${INPUT_TIGERUHR_POSITION}",
  "roster_filename": "${INPUT_ROSTER_FILENAME}",
}
EOF

git add "${INPUT_ROSTER_FILENAME}.csv"
git commit -m "Update roster file"