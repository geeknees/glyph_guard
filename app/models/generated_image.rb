class GeneratedImage < ApplicationRecord
  has_one_attached :image

  validates_presence_of :image
  validates_presence_of :given_text
end
