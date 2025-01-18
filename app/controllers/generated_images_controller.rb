class GeneratedImagesController < ApplicationController
  def index
    @generated_images = GeneratedImage.all
  end

  def show
    @generated_image = GeneratedImage.find(params[:id])
  end

  def new
    @generated_image = GeneratedImage.new
  end

  def create
    @generated_image = GeneratedImage.new(generated_image_params)

    # generate_ocr_block_image! メソッドを呼び出す
    @generated_image.options = {}
    if @generated_image.generate_ocr_block_image!
      redirect_to @generated_image, notice: "Generated image was successfully created."
    else
      render :new
    end
  end

  private

  def generated_image_params
    params.require(:generated_image).permit(:given_text, :options)
  end
end
