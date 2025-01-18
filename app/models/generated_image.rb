require "mini_magick"

class GeneratedImage < ApplicationRecord
  serialize :options, coder: JSON

  has_one_attached :image

  validates_presence_of :image
  validates_presence_of :given_text

  # OCRブロック画像の生成メソッド
  def generate_ocr_block_image!
    # options がハッシュで保存されていると想定
    # 例: { "font_path": "/path/to/font.ttf", "font_size": 24, "wave": true, ... }
    font_path   = options["font_path"]   || "app/assets/fonts/JetBrainsMonoNL-Regular.ttf"
    font_path = if options["use_zxx_noise_font"]
      "app/assets/fonts/ZXXNoise.otf"
    else
      options["font_path"] || "app/assets/fonts/UDEVGothicJPDOC-Regular.ttf"
    end
    font_size   = options["font_size"]   || 24
    wave        = options["wave"]        || false
    implode     = options["implode"]     || false
    blur        = options["blur"]        || false


    # caption:を用いて、テキストを自動折り返しで描画した画像を作成
    temp_caption = Tempfile.new([ "caption", ".png" ])
    MiniMagick::Tool::Convert.new do |cmd|
      cmd.size "1200x"   # 幅 1200 のイメージ (高さは自動)
      cmd.background "white"
      cmd.fill "black"
      cmd.font font_path
      cmd.pointsize font_size.to_i

      # caption: で自動折り返し
      escaped_text = given_text.gsub(/(['"])/, '\\\\\1')
      cmd << "caption:#{escaped_text}"

      cmd << temp_caption.path
    end

    # wave/implode/blur 等カスタム処理
    image = MiniMagick::Image.open(temp_caption.path)
    image = image.wave("5x50")   if wave
    image = image.implode("0.5") if implode
    image = image.blur("0x2")    if blur

    # 変換結果を一時ファイルに書き出し
    result_tempfile = Tempfile.new([ "result", ".png" ])
    image.write(result_tempfile.path)

    # ActiveStorageにattach
    self.image.attach(
      io: File.open(result_tempfile.path),
      filename: "ocr_block_#{SecureRandom.hex}.png",
      content_type: "image/png"
    )
    self.save!
  ensure
    temp_caption&.close!
    result_tempfile&.close! if defined?(result_tempfile)
  end
end
