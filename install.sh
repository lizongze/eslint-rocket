# "eslint-rocket": "sh node_modules/eslint-rocket/run.sh",
# "eslint-fresh": "sh node_modules/eslint-rocket/fresh.sh",
# "eslint-blame": "node node_modules/eslint-rocket/blame.js",

cwd=`pwd`
echo "pwd $cwd"

dir=`git rev-parse --show-toplevel`
echo dir $dir
# cd $dir

if [[ "$cwd" != "$dir" ]]; then
	cd ..
	cd ..
fi

echo "pwd $(pwd)"

t1=`printf '    '`;

cat package.json | grep -q '"eslint-blame": "node'
res=$?
if [[ 0 -ne $res ]]; then
	sed -i '' "/\"scripts\":/ a\\
		tt-tt\"eslint-blame\": \"node node_modules/eslint-rocket/blame.js\",
	" package.json
	sed -i "" $"s/tt-tt/$t1/g" package.json
fi

cat package.json | grep -q '"eslint-fresh": "sh'
res=$?
if [[ 0 -ne $res ]]; then
	sed -i '' "/\"scripts\":/ a\\
		tt-tt\"eslint-fresh\": \"sh node_modules/eslint-rocket/fresh.sh\",
	" package.json
	sed -i "" $"s/tt-tt/$t1/g" package.json
fi

cat package.json | grep -q '"eslint-rocket": "sh'
res=$?
if [[ 0 -ne $res ]]; then
	sed -i '' "/\"scripts\":/ a\\
		tt-tt\"eslint-rocket\": \"sh node_modules/eslint-rocket/run.sh\",
	" package.json
	sed -i "" $"s/tt-tt/$t1/g" package.json
fi

cat .gitignore | grep -q '.lib_cache'
res=$?
if [[ 0 -ne $res ]]; then

	sed -i '' -e "$ a\\
	# eslint-rocket
	" .gitignore

	sed -i '' -e "$ a\\
	.lib_cache
	" .gitignore
fi
