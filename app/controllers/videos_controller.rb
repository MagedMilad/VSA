class VideosController < ApplicationController
  before_action :set_video, only: [:show, :edit, :update, :destroy]

  # # GET /videos
  # # GET /videos.json
  # def index
  #   @videos = Video.all
  # end

  def index

    # Initialize filterrific with the following params:
    # * `Student` is the ActiveRecord based model class.
    # * `params[:filterrific]` are any params submitted via web request.
    #   If they are blank, filterrific will try params persisted in the session
    #   next. If those are blank, too, filterrific will use the model's default
    #   filter settings.
    # * Options:
    #     * select_options: You can store any options for `<select>` inputs in
    #       the filterrific form here. In this example, the `#options_for_...`
    #       methods return arrays that can be passed as options to `f.select`
    #       These methods are defined in the model.
    #     * persistence_id: optional, defaults to "<controller>#<action>" string
    #       to isolate session persistence of multiple filterrific instances.
    #       Override this to share session persisted filter params between
    #       multiple filterrific instances. Set to `false` to disable session
    #       persistence.
    #     * default_filter_params: optional, to override model defaults
    #     * available_filters: optional, to further restrict which filters are
    #       in this filterrific instance.
    # This method also persists the params in the session and handles resetting
    # the filterrific params.
    # In order for reset_filterrific to work, it's important that you add the
    # `or return` bit after the call to `initialize_filterrific`. Otherwise the
    # redirect will not work.
    # script = "#{Rails.root}/public/system/summarize.py"
    #     @info = %x(python script)
    @filterrific = initialize_filterrific(
      Video,
      params[:filterrific],
      select_options: {
        sorted_by: Video.options_for_sorted_by,
      }
    ) or return
    # Get an ActiveRecord::Relation for all students that match the filter settings.
    # You can paginate with will_paginate or kaminari.
    # NOTE: filterrific_find returns an ActiveRecord Relation that can be
    # chained with other scopes to further narrow down the scope of the list,
    # e.g., to apply permissions or to hard coded exclude certain types of records.
    @videos = @filterrific.find.page(params[:page])

    # Respond to html for initial page load and to js for AJAX filter updates.
    respond_to do |format|
      format.html
      format.js
    end

  # # Recover from invalid param sets, e.g., when a filter refers to the
  # # database id of a record that doesn’t exist any more.
  # # In this case we reset filterrific and discard all filter params.
  # rescue ActiveRecord::RecordNotFound => e
  #   # There is an issue with the persisted param_set. Reset it.
  #   puts "Had to reset filterrific params: #{ e.message }"
  #   redirect_to(reset_filterrific_url(format: :html)) and return
  end


  # GET /videos/1
  # GET /videos/1.json
  def show
    @video = Video.find(params[:id])
    if params[:summary] == "true"
      @url = @video.summarized_video.url
      @name = @video.attach_video_file_name + " [summary]"
    else
      @url = @video.attach_video.url
      @name = @video.attach_video_file_name
    end
  end

  # GET /videos/new
  def new
    @video = Video.new
  end

  # GET /videos/1/edit
  def edit
  end

  # POST /videos
  # POST /videos.json
  def create
    @video = Video.new(video_params)
    @process = true;
    respond_to do |format|
      if @video.save
        script1 = "#{Rails.root}/public/system/summarize.py"
        script2 = "/home/magedmilad/PycharmProjects/VSA/VSA.py"
        command = "python '" + script1 +"' "+ @video.attach_video.url.to_s + " " + @video.id.to_s
        if File.file?(script2)
          logger.info "cccccccccccccccccccccccccc found the summarize script"
          command = "python #{script2} -p '#{Rails.root}/public#{@video.attach_video.url.to_s}' -id #{@video.id} -dir '#{Rails.root}/public/videos/summary/'"
        end
        logger.info "cccccccccccccccccccccccccc" + command.to_s
        logger.info "cccccccccccccccccccccccccc" + "#{Rails.root}/public#{@video.attach_video.url.to_s}"
        @info = %x(#{command} 2>&1) 
        logger.info "cccccccccccccccccccccccccc"
        logger.info @info.to_s
        @video.add_summarized_video
        format.html { redirect_to @video, notice: 'Video was successfully created.' }
        format.json { render :show, status: :created, location: @video}
      else
        format.html { render :new }
        format.json { render json: @video.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /videos/1
  # PATCH/PUT /videos/1.json
  def update
    respond_to do |format|
      if @video.update(video_params)
        format.html { redirect_to @video, notice: 'Video was successfully updated.' }
        format.json { render :show, status: :ok, location: @video }
      else
        format.html { render :edit }
        format.json { render json: @video.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /videos/1
  # DELETE /videos/1.json
  def destroy
    @video.destroy
    respond_to do |format|
      format.html { redirect_to videos_url, notice: 'Video was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def home
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_video
      @video = Video.find(params[:id])
      # @video.add_summarized_video
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def video_params
      # params.fetch(:video, {})
      params.require(:video).permit(:attach_video)
    end
end
