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
    @generated_image = GeneratedImage.new(
      generated_image_params.except(:wave, :implode, :blur))

    @generated_image.options = {
      "wave" => params[:generated_image][:wave] == "1",
      "implode" => params[:generated_image][:implode] == "1",
      "blur" => params[:generated_image][:blur] == "1"
    }
    if @generated_image.generate_ocr_block_image!
      redirect_to @generated_image,
      notice: "Generated image was successfully created."
    else
      render :new
    end
  end

  private

  def generated_image_params
    params.require(:generated_image).permit(:given_text, :wave, :implode, :blur)
  end
end
