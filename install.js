const { spawnAsync } = require('./util');
const fs = require('fs');
const pwd = process.env.PWD;
console.log('pwd', pwd);
spawnAsync('sh', [`./install.sh`, pwd], { stdio: 'inherit' }).catch((err) => {
	console.log(err);
}).then(err => {
	process.exit(0);
});
