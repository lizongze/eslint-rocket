time=$(date +%s)

cwd=`pwd`
if [[ "$1" ]]; then
	cwd=$1
fi
cd $cwd
root="$cwd/node_modules/eslint-rocket"

cpus=`sysctl hw.logicalcpu | uniq | sed 's/hw.logicalcpu: //'`
res=$?
if [[ 0 -ne $res ]]; then
	cpus=`cat /proc/cpuinfo| grep "cpu cores"| uniq`
fi
echo "cpu num: $cpus"
let cpus--

# sh ./scripts/automerge.sh
err=0

if [ 0 -eq $err ]; then
  masterId=$(git log origin/master -1 | head -1 | sed 's/commit //')
  branchId=$(git log -1 | head -1 | sed 's/commit //')
  task="git diff --name-only $masterId $branchId | grep .js | grep src"
  node $root/filesWorker.js $cpus "$task" super
  err=$?
fi

echo time: $[$(date +%s)-time];
exit $err
