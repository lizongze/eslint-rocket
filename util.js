const childProcess = require('child_process');
const groupBy = require('lodash/groupBy');

exports.spawnAsync = (...args) => new Promise((resolve, reject) => {
  const child = childProcess.spawn(...args);
  child.on('close', (code) => {
    if (code !== 0) {
      reject(code);
    } else {
      resolve(code);
    }
  });
});

exports.groupFiles = (fileArr, cpuLen) => {
  const filesMap = groupBy(fileArr, (name) => {
    name = name || '';
    const mathedList = (name.match(/((?!\/)([^/]+))/g) || []).slice(0, -2);
    const key = `${mathedList[mathedList.length - 1]}${mathedList[mathedList.length - 2] || ''}`;
    return key;
  });
  const groupedList = Object.keys(filesMap).reduce((acc, cur) => {
    const indexNum = (cur || '').split('').map(str => str.charCodeAt()).reduce((a, b) => a + b, 0);
    filesMap[cur].forEach((item, idx) => {
      const i = (idx + indexNum) % cpuLen;
      acc[i] = [item].concat(acc[i]);
    });
    return acc;
  }, []);
  return groupedList;
};

exports.genArr = len => '1'.repeat(len).split('').map((item, idx) => idx);
