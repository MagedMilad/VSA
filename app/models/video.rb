class Video < ActiveRecord::Base

  has_attached_file :attach_video, :styles => {
    :medium => { :geometry => "640x480", :format => 'mp4' },
    :thumb => { :geometry => "100x100#", :format => 'jpg', :time => 10 }
  }, :processors => [:transcoder]

  has_attached_file :summarized_video, :styles => {
    :medium => { :geometry => "640x480", :format => 'mp4' },
    :thumb => { :geometry => "100x100#", :format => 'jpg', :time => 10 }
  }, :processors => [:transcoder]

  validates_attachment_presence :attach_video
  # validates_attachment_size :attach_video, :less_than => 5.megabytes
  validates_attachment_content_type :attach_video, content_type: /\Avideo\/.*\Z/

  def add_summarized_video
    # update_attribute(:summarized_video, video)
    file_path = "#{Rails.root}/public/videos/summary/"+self.id.to_s+".mp4"
    
    if File.exist?(file_path)
      file = File.open(file_path)
      self.summarized_video = file
      file.close
      self.save!
    end
  end

end
