require 'shopify_api'
require 'date'

SCHEDULER.every '5m', first_in: 0 do
  # configuration
  api_key  = ENV['API_KEY']  # retrieve api key from environment variable
  password = ENV['PASSWORD'] # retrieve api password from environment variable
  shop     = ENV['SHOP']     # retrieve shop name from environment variable
  url      = "http://#{api_key}:#{password}@#{shop}.myshopify.com/admin"
  ShopifyAPI::Base.site(url)

  # set times
  now        = DateTime.now.strftime('%Y-%m-%d %H:%M')
  last_month = DateTime.now << 1
  last_year  = DateTime.now << 12

  # hit API for order count during time range
  total_orders     = ShopifyAPI::Order.count
  orders_for_month = ShopifyAPI::Order.count(params: {
    created_at_min: last_month.strftime('%Y-%m-%d 00:00'),
    created_at_max: now
  })
  orders_for_year = ShopifyAPI::Order.count(params: {
    created_at_min: last_year.strftime('%Y-%m-%d 00:00'),
    created_at_max: now
  })

  # send data to the view
  send_event('order_count', {
    total_orders:     "#{total_orders}",
    orders_for_month: "#{orders_for_month}",
    orders_for_year:  "#{orders_for_year}"
  })
end
