var fs = require("fs");
var casper = require("casper").create();
var json = require("./config.json");

function getLinks() {
  this.scrollTo(0, 500);
  var links = document.querySelectorAll('a img');
  return Array.prototype.map.call(links, function(e) {
    return e.getAttribute('src');
  });
}

function createImage(urls, dir, uniqid) {
  urls = urls.filter(function(v) {
    return (v.length > 0 && v.match(/data:image\/jpeg;base64,/));
  });
  [].forEach.call(urls, function(base64Data, index) {
    if (index < parseInt(json["fetch_image_count"])) {
      var filename = ("0000000"+uniqid).slice(-7)+'-'+index;
      fs.write(dir + filename + '.jpg', atob(base64Data.replace(/data:image\/jpeg;base64,/, "")), 'b');
    }
  });
}

function timeToLocalString(date) {
  return [
    date.getFullYear(),
    ('00'+(date.getMonth() + 1)).slice(-2),
    ('00'+date.getDate()).slice(-2)
  ].join( '/' ) + ' ' + [
    ('00'+date.getHours()).slice(-2),
    ('00'+date.getMinutes()).slice(-2),
    ('00'+date.getSeconds()).slice(-2)
  ].join(':');
}

function lg(text) {
  var date = new Date();
  console.log('['+timeToLocalString(date)+'] '+text);
}

// Start
lg('Start crawling https://www.google.co.jp/imghp');

// 開発者ツールのコンソールに navigator.userAgent と打ち込むと出る
casper.userAgent("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/43.0.2357.81 Safari/537.36");

// ディレクトリ作成
var dirPath = './images/' + (new Date()).getTime() + '/';
if (fs.makeDirectory(dirPath))
  lg('create images into ' + dirPath);
else
  throw ('Could not make directory');

// ルートURL
var uri = "https://www.google.co.jp/imghp";

// ファイル読み込み
var stream = fs.open(json["target_csv"], "r");
var keywords = [];
while (!stream.atEnd()) {
  var line = stream.readLine().trim();
  keywords.push(line);
}
stream.close();

// 検索実行する回数とカウンタ
var limit = keywords.length;
var count = 0;

// 処理を開始する
casper.options.viewportSize = { width: 1600, height: 950 };
casper.start(uri).repeat(limit, function(){
  lg(keywords[count]);
  this.wait(2000,function(){
    this.fill('form#tsf', { q: keywords[count] }, true);
    urls = this.evaluate(getLinks);
    createImage(urls, dirPath, count);
  });
  count++;
}).run();
