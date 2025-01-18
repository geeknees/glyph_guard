require "test_helper"
include ActionDispatch::TestProcess

class GeneratedImageTest < ActiveSupport::TestCase
  test "should not save generated image without image" do
    generated_image = GeneratedImage.new(given_text: "Sample text")
    assert_not generated_image.save, "Saved the generated image without an image"
  end

  test "should not save generated image without given_text" do
    generated_image = GeneratedImage.new(image: fixture_file_upload("test/fixtures/files/sample_image.png", "image/png"))
    assert_not generated_image.save, "Saved the generated image without given_text"
  end

  test "should save generated image with image and given_text" do
    generated_image = GeneratedImage.new(
      image: fixture_file_upload("test/fixtures/files/sample_image.png", "image/png"),
      given_text: "Sample text"
    )
    assert generated_image.save, "Failed to save the generated image with image and given_text"
  end
  test "should generate OCR block image" do
    generated_image = GeneratedImage.new(
      given_text: "Sample text",
      options: {
        "font_size" => 24,
        "wave" => true,
        "blur" => true,
        "implode" => true
      }
    )
    generated_image.generate_ocr_block_image!
    assert generated_image.image.attached?, "OCR block image was not generated and attached"
  end

  test "should generate OCR block image with punctuations" do
    generated_image = GeneratedImage.new(
      given_text: "Sample's text",
      options: {
        "font_size" => 24,
        "wave" => true,
        "blur" => true,
        "implode" => true
      }
    )
    generated_image.generate_ocr_block_image!
    assert generated_image.image.attached?, "OCR block image was not generated and attached"
  end
end
