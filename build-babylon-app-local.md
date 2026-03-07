We are building out the `local` deployment for the `babylon` project.

## Task
Your task is to get the `babylon-app` service working in the docker-compose network.

## Artifacts
We will eventually be building all dependent packages to run containers as zipped artifacts.
The container should pull the artifact from the repo, and unzip it.

### Babylon App Artifact
The Babylon App artifact is a Github artifact. Here is the latest: `https://github.com/ajponte/babylon/releases/tag/latest`.

### Github Token.
The github PAT token is an envireonment variable `BABYLON_API_GITHUB_PAT_TOKEN`. That variable should be referenced in all scripts and commands.

### Problems with starting Babylon App Which Require Code Changes
For any issues or concerns with how the app is started, create a file named `BABYLON-APP-FIXES.md` to append to.

## Testing
To test, create a `health-babylon-app.sh` script to ping the `health` route via cURL.
