# google image crawler
与えられたcsvファイルのキーワードをグーグル画像検索API(deprecated)を利用して検索し、取得したURLの画像をローカルにダウンロードする

# Setup

```
git clone https://github.com/YuheiNakasaka/google_image_crawler.git
cd google_image_crawler
chmod a+x initialize.sh
sh initialize.sh
```

# Usage

1. config.ymlにcsvのファイルパスと画像のdownload_directoryを記述(download_directoryはデフォルトのままでもよい)
2. google_image_crawlerディレクトリ配下で以下を実行

```
ruby crawler.rb
```

# Example

example.csvを使用して実行する場合(デフォルト設定)

```
$ ruby crawler.rb
[2015/05/28 14:40] Start crawling...
[2015/05/28 14:40] [0] Download ラブライブ
[2015/05/28 14:40] [1] Download SHIROBAKO
[2015/05/28 14:40] [2] Download 遊戯王
[2015/05/28 14:41] [3] Download 黒子のバスケ
[2015/05/28 14:41] [4] Download けいおん
[2015/05/28 14:42] Finished all
```