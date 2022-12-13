class Achievement < ApplicationRecord
  belongs_to :user, optional: true
  
  validates :title, presence: true
  validate :unique_title_for_one_user
  
  enum privacy: [ :public_access, :private_access, :friends_access]
  
  mount_uploader :cover_image, CoverImageUploader

  def description_html
    Redcarpet::Markdown.new(Redcarpet::Render::HTML).render(description)
  end
  
  private
  
  def unique_title_for_one_user
    existing_achievement = Achievement.find_by(title: title)
    if existing_achievement && existing_achievement.user == user
      errors.add(:title, "You can't have achievements with the same title")
    end
  end
end
