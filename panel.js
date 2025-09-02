const express = require('express');
const fileUpload = require('express-fileupload');
const fs = require('fs');
const path = require('path');
const bodyParser = require('body-parser');
const { exec } = require('child_process');
const config = require('./config.json');

const app = express();
app.use(fileUpload());
app.use(bodyParser.urlencoded({ extended: true }));
app.use(express.static('public'));
app.set('view engine', 'ejs');

// ---------- ROOT FOLDER ----------
let ROOT = config.ROOT_FOLDER;

if (ROOT.startsWith('~')) {
  ROOT = path.join(process.env.HOME, ROOT.slice(1));
}

// Allow override via environment variable
if (process.env.APP_ROOT) {
  ROOT = process.env.APP_ROOT;
}

// ---------- BASIC AUTH ----------
app.use((req, res, next) => {
  const auth = { login: config.USERNAME, password: config.PASSWORD };
  const b64auth = (req.headers.authorization || '').split(' ')[1] || '';
  const [login, password] = Buffer.from(b64auth, 'base64').toString().split(':');
  if (login && password && login === auth.login && password === auth.password) return next();
  res.set('WWW-Authenticate', 'Basic realm="Admin Panel"');
  res.status(401).send('Authentication required.');
});

// ---------- LIST FILES ----------
app.get('/', (req, res) => {
  const files = fs.readdirSync(ROOT);
  res.render('index', { files });
});

// ---------- UPLOAD ----------
app.post('/upload', (req, res) => {
  if (!req.files || !req.files.file) return res.status(400).send('No file uploaded.');
  const file = req.files.file;
  file.mv(path.join(ROOT, file.name), err => {
    if (err) return res.status(500).send(err);
    res.redirect('/');
  });
});

// ---------- DOWNLOAD ----------
app.get('/download/:file', (req, res) => {
  res.download(path.join(ROOT, req.params.file));
});

// ---------- EDIT ----------
app.get('/edit/:file', (req, res) => {
  const filePath = path.join(ROOT, req.params.file);
  if (!fs.existsSync(filePath)) return res.send('File not found');
  const content = fs.readFileSync(filePath, 'utf-8');
  res.render('edit', { file: req.params.file, content });
});

app.post('/edit/:file', (req, res) => {
  const filePath = path.join(ROOT, req.params.file);
  fs.writeFileSync(filePath, req.body.content, 'utf-8');
  res.redirect('/');
});

// ---------- RESTART NODE APP ----------
app.post('/restart', (req, res) => {
  exec('pm2 restart your-app-name', (err, stdout, stderr) => {
    if (err) return res.send('Restart failed: ' + err.message);
    res.redirect('/');
  });
});

// ---------- START SERVER ----------
app.listen(4000, () => console.log('Panel running at http://<vm-ip>:4000'));
