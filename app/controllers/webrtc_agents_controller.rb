class WebrtcAgentsController < ApplicationController
  before_filter :authenticate_user!

  def index
    @agent = current_user
    @client = Twilio::REST::Client.new(Rails.application.secrets.twilio_account_sid, Rails.application.secrets.twilio_auth_token)


    if @agent.phone_number.nil? || @agent.sip_domain.nil?
      @number =  'agent not created'
      @domain = 'agent not created'
    else
      @number = @agent.phone_number
      @domain = @agent.sip_domain
    end

    if @agent.ip_acl.nil?
      @ip_acl_label = "Create IPACL"
    else
      @ip_acl_label = "Configure IPACL"
      @ip_acl = @client.account.sip.domains.get(current_user.sip_domain_sid)
    end

    if @agent.auth_acl.nil?
      @acl_label = "Create ACL"
    else
      @acl_label = "Configure ACL"
    end

    capability = Twilio::Util::Capability.new Rails.application.secrets.twilio_account_sid, Rails.application.secrets.twilio_auth_token
    capability.allow_client_incoming current_user.id
   @token = capability.generate()
  end

end