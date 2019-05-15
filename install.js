const { spawnAsync } = require('./util');
const fs = require('fs');
const pwd = process.env.PWD;

spawnAsync('sh', [`./install.sh`, pwd], { stdio: 'inherit' })
	.then(() => {
		process.exit(0);
	})
	.catch(() => {
		process.exit(1);
	})
