class AddAttachmentAttachVideoToVideos < ActiveRecord::Migration
  def self.up
    change_table :videos do |t|
      t.attachment :attach_video
    end
  end

  def self.down
    remove_attachment :videos, :attach_video
  end
end
