# "eslint-rocket": "sh node_modules/eslint-rocket/run.sh",
# "eslint-fresh": "sh node_modules/eslint-rocket/fresh.sh",
cwd=`pwd`
echo "pwd $cwd"

dir=`git rev-parse --show-toplevel`
echo dir $dir
# cd $dir
cd ..
cd ..
echo "pwd $(pwd)"

t1=`printf '    '`;

cat package.json | grep -q \"eslint-fresh\":
res=$?
if [[ 0 -ne $res ]]; then
	sed -i '' "/\"scripts\":/ a\\
		tt-tt\"eslint-fresh\": \"sh node_modules/eslint-rocket/fresh.sh\",
	" package.json
	sed -i "" $"s/tt-tt/$t1/g" package.json
fi

cat package.json | grep -q \"eslint-rocket\":
res=$?
if [[ 0 -ne $res ]]; then
	sed -i '' "/\"scripts\":/ a\\
		tt-tt\"eslint-rocket\": \"sh node_modules/eslint-rocket/run.sh\",
	" package.json
	sed -i "" $"s/tt-tt/$t1/g" package.json
fi
