/**
 * shell 如果不支持sh命令（windows），则跳过
 */

const childProcess = require('child_process');

const spawnAsync = (...args) => new Promise((resolve, reject) => {
	const child = childProcess.spawn(...args);
	child.on('close', (code) => {
		if (code !== 0) {
			reject(code);
		} else {
			resolve(code);
		}
	});
});

// console.log('argv', process.argv.slice(2))

const argv = process.argv.slice(2);
const cmd = argv[0];
const params = argv.slice(1);

spawnAsync('sh', ['-c', '']).catch(() => {
	process.exit(0);
}).then(() =>
	// spawnAsync('sh', [`./scripts/router-check.sh`], { stdio: 'inherit' })
	spawnAsync(cmd, params, { stdio: 'inherit' })
		.catch(() => {
			process.exit(11);
		}).then(() => {
		process.exit(0);
	})
);

process.on('exit', (code) => {
	if (code === 1) {
		// sh 命令不存在报错
		process.exit(0);
	} else if (code === 11) {
		// check 失败
		process.exit(1);
	}
});
