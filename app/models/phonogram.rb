class Phonogram < ApplicationRecord
  has_one_attached :source_sound
  has_one_attached :parsed_csv

  belongs_to :user

  # statuses:
  # 0 - source not loaded
  # 1 - source sended to storage
  # 2 - sended to transcribation
  # 3 - ready for parsing to csv
  # 4 - creating csv
  # 5 - completed
  # 7 - error

  def flush
    update(status: 1, task_uuid: nil, parsed_text: nil)
  end
end
