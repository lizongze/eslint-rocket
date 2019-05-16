const fs = require('fs');
const Promise = require('bluebird');
const childProcess = Promise.promisifyAll(require('child_process'));

const execSync = childProcess.execSync;
const execAsync = childProcess.execAsync;

function filterMap(map) {
  return Object.keys(map).reduce((acc, key) => {
	  	const { files, ...rest } = map[key];
	   	acc[key] = rest;
	   	return acc;
	}, {});
}
const pwd = process.env.PWD;
const errorTaskLine = [];
const taskMap = {};

function main(authorName) {
  try {
	execSync(`cd ${pwd}; npm run eslint-rocket > .lib_cache/eslint/.eslintstatus 2>/dev/null`);
  } catch (e) {
    const result = fs.readFileSync('.lib_cache/eslint/.eslintstatus', 'utf8');
    const reNum = /(\d+):\d+/;
	const reAuthor = /^\^?\w+\s\(([^\s]+)\s/;

	const lineList = result.split('\n').filter(v => (v || '').trim());
	let fileNameTemp = '';
	const lineMap = lineList.reduce((acc, line) => {
		// 确定需要 blame 的行
		if (/^\//.test(line)) {
			fileNameTemp = line;
			return acc;
		}
		acc[line] = fileNameTemp;
		return acc;
	}, {});
	// console.log('lineMap', lineMap);
    let blameLine = '';

    const blame = {
      map: {},
      addBlame(author, type, file, pos) {
        if (this.map[author]) {
          if (this.map[author][type]) {
            this.map[author][type] += 1;
          } else {
            this.map[author][type] = 1;
          }

          this.map[author].files.push(`${file} ${pos}`);
        } else {
          this.map[author] = {
            [type]: 1,
            files: [`${file} ${pos}`],
          };
        }
      },
	};

	const lineHandler = (line, index, async = true) => {
		// 确定需要 blame 的行
		if (/^\//.test(line)) {
		  return Promise.resolve();
		}

		const curBlameLine = lineMap[line];
		const items = line.split(/\s+/).filter(v => v);

		// 认为是 blame 的内容
		if (items[0] && reNum.test(items[0])) {
		  const match = items[0].match(reNum);
		  const num = match[1];
		  const level = items[1];

		  const handler = (task) => execAsync(task)
			  .then((res) => res.toString('utf8'))
			  .then((blameResult) => {
				  taskMap[task] = true;
				  const matchAuthor = blameResult.match(reAuthor);
				  if (matchAuthor && matchAuthor[1]) {
					const au = matchAuthor[1].replace(/^'|'$/g, '');
					blame.addBlame(au, level, curBlameLine, items[0]);
				  }
			  }).catch(err => {
				  err.task = task;
				  taskMap[task] = false;
				  throw err;
			  });

		  const task = `git blame ${curBlameLine} -L ${num},${num}`;
		  if (taskMap[task]) {
			  return Promise.resolve();
		  }
		  taskMap[task] = true;

		//   console.log(`git blame ${curBlameLine} -L ${num},${num}`)

		  if (async) {
			return handler(task);
		  } else {
			  const blameResult = execSync(task).toString('utf8') || '';
			  const matchAuthor = blameResult.match(reAuthor);
			  if (matchAuthor && matchAuthor[1]) {
				const au = matchAuthor[1].replace(/^'|'$/g, '');
				blame.addBlame(au, level, curBlameLine, items[0]);
			  }
		  }
		}
		return Promise.resolve();
	};

	const listHandler = (list, errList) => {
		return Promise.map(list, (line, index) => {
			return lineHandler(line, index)
				.catch(err => {
					// console.log('errTaskLine', line, err.task);
					errList.push(line);
				});
		})
		.catch(err => console.log('err1', err))
	}
	const lastHandler = (list) => {
		let r = authorName ? blame.map[authorName] : filterMap(blame.map);
		console.log('handleErrorBefore', r);

		errorTaskLine.forEach((line, index) => {
			try {
				lineHandler(line, index, false);
			} catch(err) {
				console.log('err sync', line, err);
			}
		});
	}

	// run serveral parallel to reduce the sync file counts
	const errorTaskLists = [[], [], [], [], [], [], []];
	let errorListsIndex = 0;
	const proHandler = (list, errList) => {
		const curErrorListsIndex = errorListsIndex;
		const curErrList = errList[errorListsIndex++];

		console.log('list-----', list.length);

		return listHandler(list, curErrList).then(() => {
			console.log('curErrList-----', curErrorListsIndex, curErrList.length);

			if (curErrList.length && errList[curErrorListsIndex + 1]) {
				return proHandler(curErrList, errList)
			} else {
				if (curErrList.length) {
					lastHandler(curErrList);
				}
				console.log('\n=============== 检查结果 ===============\n');
				console.log(filterMap(blame.map));

				if (authorName) {
					console.log(blame.map[authorName]);

					if (!blame.map[authorName]) {
						console.log('检测完成，没有问题');
						return;
					}
				}

				console.log('task num', Object.keys(taskMap).length);
				console.log('');
			}
		});
	};

	proHandler(lineList, errorTaskLists)

	return ;
  }
}

const argv = process.argv;
main(argv[2]);
