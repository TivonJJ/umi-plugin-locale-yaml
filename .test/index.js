const main =  require('../lib/index');
const path = require('path');

const a=main.getLocaleFileList(__dirname);
console.log(a)