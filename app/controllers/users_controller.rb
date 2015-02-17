class UsersController < ApplicationController
  before_filter :authenticate_user!

  def index
    @users = User.all
  end

  def show
   @user = User.find(params[:id])
    unless @user == current_user
      redirect_to :back, :alert => "Access denied."
    end
  end

  def provision_twilio

    # begin
    #   domain_string = "#{Faker::Address.city}-#{Faker::Address.building_number}-wrtc.sip.twilio.com".downcase.gsub(/\s+/, "")

    #   client = Twilio::REST::Client.new(Rails.application.secrets.twilio_account_sid, Rails.application.secrets.twilio_auth_token)
    #   @number = client.account.incoming_phone_numbers.create( :area_code => '415',
    #    :voice_url => "https://akjordan.ngrok.com/incoming", :friendly_name => "#{current_user.email}'s Number")

    #   @sipdomain = client.account.sip.domains.create(:friendly_name => "#{current_user.email}'s SIP domain",
    #   :voice_url => "https://akjordan.ngrok.com/incoming", :domain_name => domain_string)

    # rescue Exception => e
    #   puts "Failure during account provisioning #{e}"
    # end

    begin
      @user = current_user.update_attributes(sip_domain: "foobarbaz@sip.twilio.com",
      sip_domain_sid: "SD1935754341943eabf9b86d3e89c74d37", phone_number: "+14158675309")
      redirect_to '/twilio',  notice: 'Twilio endpoints were successfully provisioned!'
    rescue
      redirect_to '/twilio',  notice: "Provisioning failed for reason #{e}"
    end

  end

  def provision_credential_list
    begin
      client = Twilio::REST::Client.new(Rails.application.secrets.twilio_account_sid, Rails.application.secrets.twilio_auth_token)
      credential_list = client.account.sip.credential_lists.create(:friendly_name => "#{current_user.email}")
      current_user.update_attributes(:auth_acl => credential_list.sid )

      credential_list_mapping = client.account.sip.domains.get(current_user.sip_domain_sid)
      .credential_list_mappings.create(:credential_list_sid => credential_list.sid)

      redirect_to '/twilio',  notice: 'Twilio credential_list created, and associated!'
    rescue Exception => e
      redirect_to '/twilio',  notice: "Twilio credential_list ceation failed for reason #{e}"
    end
  end

  def provision_ip_list
    begin
      client = Twilio::REST::Client.new(Rails.application.secrets.twilio_account_sid, Rails.application.secrets.twilio_auth_token)
      ip_access_control_list = client.account.sip.ip_access_control_lists.create(:friendly_name => "#{current_user.email}")
      current_user.update_attributes(:ip_acl => ip_access_control_list.sid )

      ip_access_control_list_mapping = client.account.sip.domains.get(current_user.sip_domain_sid)
      .ip_access_control_list_mappings.create(:ip_access_control_list_sid => ip_access_control_list.sid)

      redirect_to '/twilio',  notice: 'Twilio ip_access_control_list  created, and associated!'
    rescue Exception => e
      redirect_to '/twilio',  notice: "Twilio ip_access_control_list ceation failed for reason #{e}"
    end
  end


end