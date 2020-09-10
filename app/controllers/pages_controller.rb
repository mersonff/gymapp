class PagesController < ApplicationController
    before_action :require_user
    
    def home
      @clients_indebt = Array.new
      @payment_dates_indebt = Array.new 
      @payments = Payment.where("payment_date > ?", Date.current - 7.days)
      @clients = current_user.clients
      @clients.each do |client|
        @day_of_payment = client.payments.last.payment_date + 1.month
        if (client.payments.last.payment_date + 1.month) <= Date.current
          @clients_indebt << client
        end
      end
    end
end