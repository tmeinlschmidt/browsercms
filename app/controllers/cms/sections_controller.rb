class Cms::SectionsController < Cms::BaseController

  before_filter :load_parent, :only => [:new, :create]

  def index
    #If the route is /cms/sections?page_id=123, the page_id will be 123
    if(params[:page_id])
      @selected_page = Page.find(params[:page_id])
      @selected_section = @selected_page.section
    end
    @section = Section.root.first
    render :layout => 'cms/sitemap'
  end

  def show
    @selected_section = Section.find(params[:id])
    @section = Section.root.first
    render :action => 'index', :layout => 'cms/sitemap'
  end
  
  def new
    @section = @parent.children.build
  end
  
  def create
    @section = @parent.children.build(params[:section])
    if @section.save
      flash[:notice] = "Section '#{@section.name}' was created"
      redirect_to cms_url(@section)
    else
      render :action => 'new'
    end    
  end

  def edit
    @section = Section.find(params[:id])
  end
  
  def update
    @section = Section.find(params[:id])
    if @section.update_attributes(params[:section])
      flash[:notice] = "Section '#{@section.name}' was updated"
      redirect_to cms_url(@section)
    else
      render :action => 'edit'
    end      
  end
  
  def destroy
    @section = Section.find(params[:id])
    @parent = @section.parent
    if @parent
      if @section.destroy
        flash[:notice] = "Section '#{@section.name}' was deleted"
      end
      redirect_to cms_url(@parent)
    else
      flash[:error] = "Section '#{@section.name}' cannot be deleted"
      redirect_to cms_url(@section)
    end
  end  
  
  def move
    @section = Section.find(params[:id])
    if params[:section_id]
      @move_to = Section.find(params[:section_id])
    else
      @move_to = Section.root.first
    end
  end
  
  def move_to
    @section = Section.find(params[:id])
    @move_to = Section.find(params[:section_id])
    if @section.move_to(@move_to)
      flash[:notice] = "Section '#{@section.name}' was moved to '#{@move_to.name}'."
    end
    
    respond_to do |format|
      format.html { redirect_to cms_url(@move_to) }
      format.js { render :template => 'cms/shared/show_notice' }
    end
  end  
  
  protected
    def load_parent
      @parent = Section.find(params[:section_id])
    end

end