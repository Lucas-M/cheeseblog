class Article < ActiveRecord::Base
  validates_presence_of :title, :body

  belongs_to :user 
  has_and_belongs_to_many :categories 
  has_many :comments

  scope :published, lambda { where("articles.published_at IS NOT NULL") }
  scope :draft, lambda { where("articles.published_at IS NULL") }

  def long_title
    "#{title} - #{published_at}"
  end
end
