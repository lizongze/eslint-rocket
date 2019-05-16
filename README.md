# eslint-rocket
eslint rocket fast faster fastest speed super parallel Multi Processing Multi Threading git diff algorithm between commit blame

# install
sometimes, you need append the follow into scripts in package.json, such as rush package manager.

    "eslint-rocket": "sh node_modules/eslint-rocket/run.sh",
    "eslint-fresh": "sh node_modules/eslint-rocket/fresh.sh",
	"eslint-blame": "node node_modules/eslint-rocket/blame.js",

# usage
you can try to exec the follow cmd to feel:
	npm run eslint-rocket
	npm run eslint-fresh
	npm run eslint-blame

# problems
if you find it slow in sometimes, you can try "npm run eslint-fresh" to fresh the begin commit id which works when eslint in a new branch

# ads: pre-commit/pre-push
if you use rush package manager, you can choose pre-commit-for-rush and pre-push-for-rush
