class Users::RegistrationsController < Devise::RegistrationsController

  def create
    company_name = params[:user][:company_name]
    build_resource(sign_up_params)

    ActiveRecord::Base.transaction do
      resource.save!
      
      if company_name.present?
        resource.companies.create!(name: company_name)
      end
      
      yield resource if block_given?
      if resource.persisted?
        if resource.active_for_authentication?
          set_flash_message! :notice, :signed_up
          sign_up(resource_name, resource)
          respond_with resource, location: after_sign_up_path_for(resource)
        else
          set_flash_message! :notice, :"signed_up_but_#{resource.inactive_message}"
          expire_data_after_sign_up!
          respond_with resource, location: after_inactive_sign_up_path_for(resource)
        end
      else
        clean_up_passwords resource
        set_minimum_password_length
        respond_with resource
      end
    end
  rescue ActiveRecord::RecordInvalid => e
    clean_up_passwords resource
    set_minimum_password_length
    respond_with resource
  end

end
