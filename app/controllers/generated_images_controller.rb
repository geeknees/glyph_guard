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
    if @generated_image.save
      redirect_to @generated_image, notice: "Generated image was successfully created."
    else
      render :new
    end
  end

  private

  def generated_image_params
    params.require(:generated_image).permit(:text, :options) # 例: text, optionsなど
  end
end
