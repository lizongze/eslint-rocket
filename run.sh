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

mkdir .lib_cache 2>/dev/null
mkdir .lib_cache/eslint 2>/dev/null
branch=$(git rev-parse --abbrev-ref HEAD);
idCacheFile=".lib_cache/eslint/.$branch.cache"
masterIdFile=".lib_cache/eslint/.master.cache"
[ ! -f $idCacheFile ] && cp ".lib_cache/eslint/.master.cache" $idCacheFile 2>/dev/null
touch $idCacheFile
touch $masterIdFile
# lastId=$(cat $idCacheFile  2>/dev/null | grep commitId | sed 's/commitId //')
lastId=`sed -n 1p $idCacheFile | sed 's/commitId //'`
commitId=$(git log -1 | head -1 | sed 's/commit //' | cut -b 1-6);
task='git ls-files | grep .[tj]sx* | grep src'
eslintcacheFile="./.lib_cache/eslint/.${branch}-${idx}.cache"

getCacheName() {
  echo "./.lib_cache/eslint/.$1-$2.cache"
}
cpTask() {
  for ((i=0;i<$1;i++));
  do {
    cp $(getCacheName $2 $i) $(getCacheName $3 $i) 2>/dev/null
  }
  done
  # wait
}
# echo lastId $lastId

#--------main--------------
# check if has last cached id
if [ "$lastId" ]; then
  task="git diff --name-only $lastId $commitId | grep '\.[tj]sx*' | grep src"
  node "$root/filesWorker.js" $cpus "$task"
else
  lastMasterId=`sed -n 1p $masterIdFile | sed 's/commitId //'`
  if [ "$lastMasterId" ]; then
    task="git diff --name-only $lastMasterId $commitId | grep '\.[tj]sx*' | grep src"
    node "$root/filesWorker.js" $cpus "$task"
  else
    # if no cached id, copy cached file from master
    if [ ! -f ".lib_cache/eslint/.$branch-0.cache" ]; then
      cpTask $cpus master $branch
    fi
    node "$root/filesWorker.js" $cpus "$task"
  fi
fi
err=$?

#--------cache--------------
#cache current head id
if [ 0 -eq $err ]; then
  # echo $commitId
  # if has no last cached id, copy cached file to master,
  # for the issue: when checkout to a new branch, no cache file to use.
  # before eslint, make it can be copied from master by new branch
  if [ '' == "$lastId" ]; then
    echo commitId $commitId > $idCacheFile;
    cpTask $cpus $branch master
  else
    sed -i '' '1 i\
      commitId '$commitId'
      ' $idCacheFile
  fi
fi

echo time: $[$(date +%s)-time];
exit $err
