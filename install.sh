# "eslint-rocket": "sh node_modules/eslint-rocket/run.sh",
# "eslint-fresh": "sh node_modules/eslint-rocket/fresh.sh",
# "eslint-blame": "node node_modules/eslint-rocket/blame.js",
sedPrefix=""

sed -i "" "" package.json 2>/dev/null
win=$?
[[ 0 -ne $win ]] && sedPrefix='""'

echo win $win
# sed -i $sedPrefix "/\"scripts\":/ a\"node-----" package.json
# sed -i $sedPrefix $v package.json

cwd=`pwd`
echo "pwd $cwd"

dir=`git rev-parse --show-toplevel`
rdir=`echo ${dir:2}`
rcwd=`echo ${cwd:2}`

echo dir $dir $cwd
# cd $dir

if [[ "$rcwd" != "$rdir" ]]; then
	cd ..
	cd ..
fi
echo "pwd `pwd`"

t1=`printf '    '`;

cat package.json | grep -q '"eslint-blame": "node'

res=$?
if [[ 0 -ne $res ]]; then
	blame='tt-tt\"eslint-blame\": \"node node_modules/eslint-rocket/blame.js\",'
	sed -i $sedPrefix -e "/\"scripts\":/ a\\
$blame
	" package.json
	sed -i $sedPrefix -e $"s/tt-tt/$t1/g" package.json
fi

cat package.json | grep -q '"eslint-fresh": "sh'
res=$?
if [[ 0 -ne $res ]]; then
	fresh='tt-tt\"eslint-fresh\": \"sh node_modules/eslint-rocket/fresh.sh\",'
	sed -i $sedPrefix -e "/\"scripts\":/ a\\
$fresh
	" package.json
	sed -i $sedPrefix -e $"s/tt-tt/$t1/g" package.json
fi

cat package.json | grep -q '"eslint-rocket": "sh'
res=$?
if [[ 0 -ne $res ]]; then
	rocket='tt-tt\"eslint-rocket\": \"sh node_modules/eslint-rocket/run.sh\",'
	sed -i $sedPrefix -e "/\"scripts\":/ a\\
$rocket
	" package.json
	sed -i $sedPrefix -e $"s/tt-tt/$t1/g" package.json
fi

cat .gitignore | grep -q '.lib_cache'
res=$?
if [[ 0 -ne $res ]]; then

	sed -i $sedPrefix -e "$ a\\
# eslint-rocket
	" .gitignore

	sed -i $sedPrefix -e "$ a\\
.lib_cache
	" .gitignore
fi

# read -p "press"