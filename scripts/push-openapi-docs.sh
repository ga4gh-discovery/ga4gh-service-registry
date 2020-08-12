# push-openapi-docs.sh
# on travis ci, run the gh-openapi-docs tool and push built documentation to gh-pages branch

# install node version manager (nvm), which will install the correct nodejs version
function install_nvm {
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
    nvm --version
}

# install correct nodejs version via nvm
function install_node {
    NODE_VERSION="12.18.3"
    nvm install ${NODE_VERSION}
    nvm use ${NODE_VERSION}
    node -v
}

# install the gh-openapi-docs tool from npm
function install_gh_openapi_docs {
    npm install -g @redocly/openapi-cli && npm install -g redoc-cli
    npm install -g @ga4gh/gh-openapi-docs
}

# configure the github account that will push to the gh-pages branch of this repo
function setup_github_bot {
    git config user.name $GH_PAGES_NAME
    git config user.email $GH_PAGES_EMAIL
    git config credential.helper "store --file=.git/credentials"
    echo "https://${GH_PAGES_TOKEN}:x-oauth-basic@github.com" > .git/credentials
}

# remove credentials of github account from build
function cleanup_github_bot {
  rm .git/credentials
}

# pulls the remote gh-pages branch to local
function setup_github_branch {
    git checkout -b gh-pages
    git branch --set-upstream-to=origin/gh-pages
    git config pull.rebase false
    git add preview
    git add docs
    git add openapi.json
    git add openapi.yaml
    git stash save
    git pull
    git checkout stash -- .
}

# commit the outputs from gh-openapi-docs
function commit_gh_openapi_docs_outputs {
    git commit -m "added docs from gh-openapi-docs"
}

# main method
function main {
    if [[ $TRAVIS_BRANCH == master || $TRAVIS_BRANCH == develop || $TRAVIS_BRANCH == release* ]]; then
        echo -e "travis branch: ${TRAVIS_BRANCH}; building documentation"
        echo -e "installing nvm"
        install_nvm
        echo -e "installing nodejs"
        install_node
        echo -e "installing gh-openapi-docs"
        install_gh_openapi_docs
        echo -e "running gh-openapi-docs"
        gh-openapi-docs
        echo -e "configuring github account to push to gh-pages branch"
        setup_github_bot
        echo -e "pulling gh-pages to local and merging local changes"
        setup_github_branch
        commit_gh_openapi_docs_outputs
        echo -e "pushing to remote gh-pages branch"
        git push
        echo -e "cleaning up"
        cleanup_github_bot
    else
        echo -e "travis branch: ${TRAVIS BRANCH}; not building documentation"
    fi
}

main
exit 0
