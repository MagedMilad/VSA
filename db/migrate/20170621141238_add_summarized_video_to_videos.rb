class AddSummarizedVideoToVideos < ActiveRecord::Migration
    def self.up
    change_table :videos do |t|
      t.attachment :summarized_video
    end
  end

  def self.down
    remove_attachment :videos, :summarized_video
  end
end
