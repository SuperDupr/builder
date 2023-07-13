# In our app this controller serves the purpose of organizations controller
# Being wrapped in the admin scope, an Organization of FTE is equivalent of 
# Account in Jumpstart

module Admin
  class AccountsController < Admin::ApplicationController
    # Overwrite any of the RESTful controller actions to implement custom behavior
    # For example, you may want to send an email after a foo is updated.
    #
    def create
      super      
      flash[:notice] = "Organization was created successfully!"
    end
    
    def update
      super
      flash[:notice] = "Organization was updated successfully!"      
    end

    def destroy
      super
      flash[:notice] = "Organization was deleted successfully!"  
    end
    
    # Override this method to specify custom lookup behavior.
    # This will be used to set the resource for the `show`, `edit`, and `update`
    # actions.
    #
    # def find_resource(param)
    #   Foo.find_by!(slug: param)
    # end

    # Override this if you have certain roles that require a subset
    # this will be used to set the records shown on the `index` action.
    #
    # def scoped_resource
    #  if current_user.super_admin?
    #    resource_class
    #  else
    #    resource_class.with_less_stuff
    #  end
    # end

    # See https://administrate-demo.herokuapp.com/customizing_controller_actions
    # for more information
  end
end
