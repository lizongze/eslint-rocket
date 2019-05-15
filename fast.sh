time=$(date +%s)

cwd=`pwd`
if [[ "$1" ]]; then
	cwd=$1
fi
cd $cwd

branch=$(git rev-parse --abbrev-ref HEAD);
idCacheFile=".lib_cache/eslint/.$branch.cache"

getCacheName() {
  echo "./.lib_cache/eslint/.$1-$2.cache"
}
cpTask() {
  for ((i=0;i<$1;i++));
  do
    cp $(getCacheName $2 $i) $(getCacheName $3 $i) 2>/dev/null
  done
}
if [ ! -f ".lib_cache/eslint/.$branch-0.cache" ]; then
  cpTask 3 master $branch
fi

task='git ls-files | grep .js | grep src'
node ./scripts/eslint/filesWorker.js 3 "$task"

err=$?
echo time: $[$(date +%s)-time];
exit $err
