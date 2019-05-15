cwd=`pwd`
if [[ "$1" ]]; then
	cwd=$1
fi
cd $cwd

commitId=`git log origin/master -1 | head -1 | sed 's/commit //' | cut -b 1-6`
# echo $commitId
idCacheFile=".lib_cache/eslint/.master.cache"
mkdir .lib_cache 2>/dev/null
mkdir .lib_cache/eslint 2>/dev/null
touch $idCacheFile
lastId=`sed -n 1p $idCacheFile | sed 's/commitId //'`
if [ "$lastId" ]; then
  sed -i '' '1 i\
    commitId '$commitId'
    ' $idCacheFile
else
  echo commitId $commitId > $idCacheFile;
fi

# sed -n 1p .lib_cache/eslint/.master.cache | sed 's/commitId //'
