const { spawnAsync } = require('./util');
const fs = require('fs');
const pwd = process.env.PWD;

fs.readdir('./',(err,files)=>{

	if(err) throw err;

	console.log('readdir ---- ', files);

});


spawnAsync('sh', [`./install.sh`, pwd], { stdio: 'inherit' })
	.then(() => {
		process.exit(0);
	})
	.catch(() => {
		process.exit(1);
	})
