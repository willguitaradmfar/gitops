set -e
echo "Configuring git credentials ssh"
mkdir -p ~/.ssh
echo $_GLOBAL_MANIFEST_SSH_PRIVATE_KEY | base64 -d > ~/.ssh/id_rsa
chmod 600 ~/.ssh/id_rsa
ssh-keyscan -t rsa $_GLOBAL_MANIFEST_REPOSITORY_DOMAIN >> ~/.ssh/known_hosts
export GIT_SSH_COMMAND='ssh -i ~/.ssh/id_rsa -o IdentitiesOnly=yes -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no'


set -x

echo "Cloning global-manifest"
git clone $_GLOBAL_MANIFEST_REPOSITORY global-manifest >> /tmp/log 2>&1 || {
    cat /tmp/log
    exit 1
}

echo "Checkout branch main"
cd global-manifest
git checkout main >> /tmp/log 2>&1 || {
    cat /tmp/log
    exit 1
}
git config user.name "GitOps Robot"
git config user.email "bot@gitops.com"

cd apps/$TRIGGER_NAME/overlays/$_GLOBAL_MANIFEST_OVERLAY >> /tmp/log 2>&1 || {
    cat /tmp/log
    exit 1
}

kustomize edit set image image-set=$_ARTIFACT_REGISTRY:$COMMIT_SHA >> /tmp/log 2>&1 || {
    cat /tmp/log
    exit 1
}
git add kustomization.yaml >> /tmp/log 2>&1 || {
    cat /tmp/log
    exit 1
}
git commit -m "Deploying ($TRIGGER_NAME) on ($_GLOBAL_MANIFEST_OVERLAY) overlay. Built from commit ${COMMIT_SHA}" >> /tmp/log 2>&1 || {
    cat /tmp/log
    exit 1
}
git push origin main >> /tmp/log 2>&1 || {
    cat /tmp/log
    exit 1
}