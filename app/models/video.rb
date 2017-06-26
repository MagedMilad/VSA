class Video < ActiveRecord::Base
  require 'date'

  has_attached_file :attach_video, :styles => {
    # :medium => { :geometry => "640x480", :format => 'mp4' },
    :thumb => { :geometry => "200x200#", :format => 'jpg', :time => 5 }
  }, :processors => [:transcoder]

  has_attached_file :summarized_video, :styles => {
    # :medium => { :geometry => "640x480", :format => 'mp4' },
    :thumb => { :geometry => "200x200#", :format => 'jpg', :time => 5 }
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
      File.delete(file_path)
      self.save!
    end
  end

   filterrific(
    default_filter_params: { sorted_by: 'created_at_desc' },
    available_filters: [
      :sorted_by,
      :search_query,
      :with_created_at_gte
    ]
  )

  self.per_page = 10


 scope :search_query, lambda { |query|
    logger.info "xxxxxxxxxxxxxxxxxx" + query.to_s

    return nil  if query.blank?

    query = query.to_s.downcase
    wildcard_search = "%#{query}%"

    where("videos.attach_video_file_name LIKE ?", wildcard_search)

    # # condition query, parse into individual keywords
    # terms = query.downcase.split(/\s+/)
    # # replace "*" with "%" for wildcard searches,
    # # append '%', remove duplicate '%'s
    # terms = terms.map { |e|
    #   (e.gsub('*', '%') + '%').gsub(/%+/, '%')
    # }
    # # configure number of OR conditions for provision
    # # of interpolation arguments. Adjust this if you
    # # change the number of OR conditions.
    # num_or_conditions = 3
    # where(
    #   terms.map {
    #     or_clauses = [
    #       "LOWER(students.first_name) LIKE ?",
    #       "LOWER(students.last_name) LIKE ?",
    #       "LOWER(students.email) LIKE ?"
    #     ].join(' OR ')
    #     "(#{ or_clauses })"
    #   }.join(' AND '),
    #   *terms.map { |e| [e] * num_or_conditions }.flatten
    # )
  }
  


  scope :sorted_by, lambda { |sort_option|
    logger.info "sssssssssssssssss" + sort_option.to_s
        # extract the sort direction from the param value.
    direction = (sort_option =~ /desc$/) ? 'desc' : 'asc'
    case sort_option.to_s
    when /^created_at_/
      # Simple sort on the created_at column.
      # Make sure to include the table name to avoid ambiguous column names.
      # Joining on other tables is quite common in Filterrific, and almost
      # every ActiveRecord table has a 'created_at' column.
      order("videos.created_at #{ direction }")
    when /^name_/
      # Simple sort on the name colums
      order("LOWER(videos.attach_video_file_name) #{ direction }")
    else
      raise(ArgumentError, "Invalid sort option: #{ sort_option.inspect }")
    end
  }

  scope :with_created_at_gte, lambda { |ref_date|
      logger.info "dddddddddddddddddd" + ref_date + ref_date.class.to_s

    ref_date = DateTime.strptime(ref_date, '%m/%d/%Y')

    # ref_date =  ref_date.to_s.gsub('/','-')
    # ref_date = ref_date.concat(' 00:00:00')
    # ref_date = DateTime.parse(ref_date.to_s)
    logger.info "dddddddddddddddddd" + ref_date.to_s
    where('videos.created_at >= ?', ref_date)
  }

  # This method provides select options for the `sorted_by` filter select input.
  # It is called in the controller as part of `initialize_filterrific`.
  def self.options_for_sorted_by
    [
      ['Name (a-z)', 'name_asc'],
      ['Registration date (newest first)', 'created_at_desc'],
      ['Registration date (oldest first)', 'created_at_asc'],
    ]
  end


end
