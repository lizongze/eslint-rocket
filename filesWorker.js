/* eslint-disable no-use-before-define,max-len,no-console,arrow-body-style */
const Promise = require('bluebird');
const fs = Promise.promisifyAll(require('fs'));
const os = require('os');
const childProcess = Promise.promisifyAll(require('child_process'));
require('./color');
const { spawnAsync, groupFiles, genArr } = require('./util');

const execSync = childProcess.execSync;

const workerList = genArr(parseInt(process.argv[2], 10) || (os.cpus().length - 1));
const cpuLen = workerList.length;
const branch = execSync('git rev-parse --abbrev-ref HEAD').toString('utf8').replace(/[\n\r\t]/g, '');

beforeLint();

const cmd = process.argv[3];
const taskType = process.argv[4] || '';
const isSuperLint = taskType === 'super';

console.log(cmd);

childProcess.execAsync(cmd)
.then(res => res.toString('utf8').split('\n').filter(v => v))
.catch(() => [])
.then((files) => {
  if (files.length === 0) {
    console.log('当前没有需要检查的文件');
    return undefined;
  }
  const groupedFiles = groupFiles(files, cpuLen);
  console.log('worker files', groupedFiles.map(item => item.length));
  console.log('代码检测中...');

  const promiseList = workerList.map((idx) => {
    const params = ['--cache', '--cache-location', `./.lib_cache/eslint/.${isSuperLint ? 'eslint' : branch}-${taskType}${idx}.cache`].concat(groupedFiles[idx]);
    const ret = spawnAsync('./node_modules/.bin/eslint', params, { stdio: 'inherit' });
    return ret;
  });

  return Promise.all(promiseList).catch(() => error());
});

function beforeLint() {
  fs.accessAsync('./.lib_cache/eslint').catch(() => {
    return fs.mkdirAsync('./.lib_cache/eslint');
  });
}

function error(text) {
  if (text) console.log(`✘ ${text}`.red);
  process.exit(1);
}
// function getName(branchName, idx) {
//   return `./.lib_cache/eslint/.${branchName}-${idx}.cache`;
// }

