
const fs = require("fs");
const path = require("path");


function traverse(src, filter, fn) {
  fs.stat(src, (err, stat) => {
    if(stat && stat.isDirectory()) {
      fs.readdir(src, (err, files) => {
        // FIXME: chk error
        files.forEach(file => traverse(path.join(src, file), filter, fn))
      })
    }
    else if(filter(src)) fn(src);
  })
}

module.exports = {
  run: (src, destDir, params) =>
    traverse(src, file => file.match(/.sol$/), file => {
      const newFile = file.replace(src, destDir);
      const replace = (txt, key) => txt.replace(`{{${key}}}`, params[key]);
      fs.readFile(file, 'utf8', (err, txt) => {
        // FIXME: chk error
        const newDir = path.dirname(newFile);
        if(!fs.existsSync(newDir)) fs.mkdirSync(newDir); // FIXME: mkdir -p
        const newTxt = Object.keys(params).reduce(replace, txt);
        fs.writeFile(newFile, newTxt, err => {
          if(err) console.error(err)
          else console.log(file, "->", newFile)
        })
      })
    })
};
