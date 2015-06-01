# coding: utf-8
require 'bundler/setup'
require "faraday"
require "faraday_middleware"
require 'yaml'
require 'csv'
require 'fileutils'
require 'parallel'

class GoogleImageClient

  def initialize(options)
    @options = options
  end

  def get
    resource.sample(@options[:count]) if resource
  rescue => exception
    lg("Error: #{self}##{__method__} - #{exception}")
    nil
  end

  private

  def resource
    @resource ||= begin
      if data = response.body["responseData"]
        data["results"].map { |r| r["unescapedUrl"] }
      end
    end
  end

  def response
    connection.get(url, params)
  end

  def url
    "http://ajax.googleapis.com/ajax/services/search/images"
  end

  def given_params
    {
      q: @options[:query]
    }
  end

  def default_params
    {
      rsz: 8,
      safe: "active",
      v: "1.0",
      as_filetype: @options[:ext]
    }
  end

  def params
    default_params.merge(given_params).reject{|key, value| value.nil?}
  end

  def connection
    Faraday.new do |connection|
      connection.adapter :net_http
      connection.response :json
    end
  end
end

class Downloader
  def initialize(options)
    @options = options
  end

  def download(url)
    response = connection.get(url)
    create_file(response) if response.status == 200
  rescue => exception
    lg("Error: #{self}##{__method__} - #{exception}")
    raise 'error'
  end

  private
  def create_file(res)
    File.open(@options[:filename], 'wb') { |fp| fp.write(res.body) }
  end

  def connection
    Faraday.new do |connection|
      connection.adapter :net_http
    end
  end
end

def lg(comment)
  puts "[#{Time.now.strftime('%Y/%m/%d %H:%M')}] #{comment}"
end

################ 実行開始 ################
lg("Start crawling...")

# load config
config = YAML.load(File.read("config.yml"))

# CSVパース
parsed_csv = CSV.open(config["csv_file_path"], {headers: true, return_headers: false})

# ディレクトリ作成
root_dir = config["download_directory"]
timestamp = Time.now.to_i
full_dir = "#{root_dir}/#{timestamp}/"
download_dir = FileUtils.mkdir_p(full_dir).first

# 画像ダウンロード
parsed_csv.each_with_index do |row,i|
  lg("[#{i}] Download #{row['keyword']}")
  current_image_count = 0
  filename_head = format("%08d",i)
  # URL取得
  gic = GoogleImageClient.new(query: row["keyword"], count: config["image_url_count"], ext: config["extension"])
  gic.get.each_with_index do |url,j|
    begin
      @downloader = Downloader.new(filename: "#{download_dir}#{filename_head}-#{j}.jpg")
      @downloader.download(url)
      current_image_count += 1
      break if current_image_count >= config["fetch_image_count"].to_i
    rescue
      lg("CoundNotDownload => FileName: #{download_dir}#{filename_head}-#{j}.jpg, SouceUrl: #{url}\n")
      next
    end
  end
end

lg("Finished all")