class FamiliesController < ApplicationController
  skip_before_filter :require_login, :only => :members #for shutterfly member list
  skip_before_filter :require_admin, :only => [:members, :show]
  before_filter :store_request_in_thread
  
  def index
    @families = Family.order('last_name').all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @families }
    end
  end

  def members
    @families = Family.where(:is_member => true, :is_active => true).order('last_name')

    respond_to do |format|
      format.js
      format.mobile
    end
  end

  def show
    @family = Family.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @family }
    end
  end

  def new
    @family = Family.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @family }
    end
  end

  def edit
    @family = Family.find(params[:id])
  end

  def create
    @family = Family.new(params[:family])

    respond_to do |format|
      if @family.save
        if @family.send_welcome_email 
          FamilyMailer.welcome(@family, request.host).deliver
        end
        
        format.html { redirect_to families_url, notice: 'Family was successfully created.' }
        format.json { render json: @family, status: :created, location: @family }
      else
        format.html { render action: "new" }
        format.json { render json: @family.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @family = Family.find(params[:id])

    respond_to do |format|
      if @family.update_attributes(params[:family])
        format.html { redirect_to families_url, notice: 'Family was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @family.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @family = Family.find(params[:id])
    puts 
    @family.is_active = false
    if !@family.save
     @family.errors.full_messages.each do |msg|
      puts msg
    end
  end

    respond_to do |format|
      format.html { redirect_to families_url, notice: 'Family was successfully marked inactive.' }
      format.json { head :no_content }
    end
  end

  def store_request_in_thread
    Thread.current[:request] = request
  end
end