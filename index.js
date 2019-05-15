const { spawnAsync } = require('./util');
const fs = require('fs');
const pwd = process.env.PWD;

spawnAsync('sh', [`${pwd}/node_modules/eslint-rocket/run.sh`, pwd], { stdio: 'inherit' })
	.then(() => {
		process.exit(0);
	})
	.catch(() => {
		process.exit(1);
	})

