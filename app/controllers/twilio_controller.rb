class TwilioController < ApplicationController
  include Webhookable

  after_filter :set_header

  skip_before_action :verify_authenticity_token

  def incoming

    begin
      to_number = params[:To]
      if to_number.include? "sip"
        to_sip = /[^@]+$/.match(to_number).to_s
        @agent = User.find_by sip_domain: to_sip
        client_id = @agent.id
      else
        @agent = User.find_by phone_number: to_number
        client_id = @agent.id
      end

    rescue Exception => e
      puts "exception #{e} caught"
    end

    response = Twilio::TwiML::Response.new do |r|
     r.Dial do |d|
       d.Client client_id
     end
    end

    render_twiml response
  end

  def status 
    render_twiml Twilio::TwiML::Response.new
  end
  
end