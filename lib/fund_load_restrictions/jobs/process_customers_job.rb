class ProcessCustomersJob < ApplicationJob
  queue_as :default

  def perform(customer_id)
    customer = Customer.find(customer_id)
    customer.process_customers
  end
end