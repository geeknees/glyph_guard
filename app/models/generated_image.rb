require "image_processing/mini_magick"

class GeneratedImage < ApplicationRecord
  has_one_attached :image

  validates_presence_of :image
  validates_presence_of :given_text


  # OCRブロック画像の生成メソッド
  def generate_ocr_block_image!
    # options がハッシュで保存されていると想定
    # 例: { "font_path": "/path/to/font.ttf", "font_size": 24, "wave": true, ... }
    font_path   = options["font_path"]   || "app/assets/fonts/JetBrainsMonoNL-Regular.ttf"
    font_size   = options["font_size"]   || 24
    wave        = options["wave"]        || false
    implode     = options["implode"]     || false
    blur        = options["blur"]        || false

    # まずは空の画像を生成するため、一時ファイルを作る
    # ここでは 1200x630 の白背景PNGを作る
    # `mini_magick` を直接呼ぶが、後段で image_processing パイプラインに渡せる
    temp_empty = Tempfile.new([ "empty", ".png" ])
    MiniMagick::Tool::Convert.new do |cmd|
      cmd.size "1200x630"
      cmd.xc "white"  # 白背景
      cmd << temp_empty.path
    end

    # `image_processing` のパイプライン作成
    pipeline = ImageProcessing::MiniMagick
      .source(temp_empty.path)
      .custom do |image|
        image = image.font(font_path) if font_path
        image = image.fill("black")
        image = image.pointsize(font_size.to_i)
        escaped_text = given_text.gsub(/(['"])/, '\\\\\1')

        # テキストを140文字ごとに分割
        lines = given_text.scan(/.{1,140}/)
        y_offset = 50
        line_height = font_size.to_i + 10
        image = image.draw("text 10,50 '#{escaped_text}'")
        lines.each do |line|
          escaped_text = line.gsub(/(['"])/, '\\\\\1')
          image = image.draw("text 10,#{y_offset} '#{escaped_text}'")
          y_offset += line_height
        end

        # wave/implode/blur 等カスタム処理
        image = image.wave("5x50")   if wave
        image = image.implode("0.5") if implode
        image = image.blur("0x2")    if blur

        image
      end

    # 実行して変換結果を一時ファイルに書き出し
    result_tempfile = pipeline.call

    # ActiveStorageにattach
    self.image.attach(
      io:       File.open(result_tempfile.path),
      filename: "ocr_block_#{SecureRandom.hex}.png",
      content_type: "image/png"
    )

    # モデルを保存
    self.save!
  ensure
    # 一時ファイルをクリーンアップ
    temp_empty.close! if temp_empty
    result_tempfile.close! if result_tempfile
  end
end
