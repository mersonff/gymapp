class IndebtsController < ApplicationController
  before_action :set_client, only: [:new, :edit, :update, :show, :destroy]
  before_action :require_user, except: [:index, :show]
  before_action :require_same_user, only: [:edit, :update, :destroy]
  
  def new
    
  end
  
  def index
    @clients_indebt = Array.new
    @clients = current_user.clients
    @clients.each do |client|
      @day_of_payment = client.payments.last.payment_date + 1.month
      if (client.payments.last.payment_date + 1.month) < Time.zone.now
        @clients_indebt << client
      end
    end
  end
  
  private
  
  def set_client
    @client = Client.find(params[:id])
  end
  
  def require_same_user
    if current_user != @client.user && !current_user.admin?
      flash[:danger] = "You can only edit or delete your own Client"
      redirect_to root_path
    end
  end
end