# google image crawler
与えられたcsvファイルのキーワードをGoogle画像検索フォームを利用して検索し、取得したURLの画像をローカルにダウンロードする

# Setup

```
git clone https://github.com/YuheiNakasaka/google_image_crawler.git
cd google_image_crawler
chmod a+x initialize.sh
sh initialize.sh
```

# Usage

1. config.jsonにcsvのファイルパスを記述
2. google_image_crawlerディレクトリ配下で以下を実行

```
casperjs crawler.js --ignore-ssl-errors=yes
```

# Example

example.csvを使用して実行する場合(デフォルト設定)

```
$ casperjs crawler.js --ignore-ssl-errors=yes
[2015/06/02 15:47:10] Start crawling https://www.google.co.jp/imghp
[2015/06/02 15:47:10] create images into ./images/1433227630399/
[2015/06/02 15:47:11] keyword
[2015/06/02 15:47:14] ラブライブ
[2015/06/02 15:47:16] SHIROBAKO
```