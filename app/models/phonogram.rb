class Phonogram < ApplicationRecord
  has_one_attached :source_sound

  belongs_to :user

  # statuses:
  # 0 - source not loaded
  # 1 - source sended to storage
  # 2 - sended to transcribation
  # 3 - ready for parsing to csv
  # 7 - error
end
