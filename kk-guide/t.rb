require 'net/http'
require 'uri'

uri = URI('http://127.0.0.1:4567/admin/links')

def submit_link(http, uri, index)
  form_data = {
    'title' => "DevOps#{index.to_s.rjust(2, '0')}",
    'url' => "https://devops#{index.to_s.rjust(2, '0')}.com",
    'category_id' => '5',
    'icon' => '🛠️',
    'sort_order' => index.to_s,
    'description' => "DevOps#{index.to_s.rjust(2, '0')} description"
  }

  encoded_data = URI.encode_www_form(form_data)
  request = Net::HTTP::Post.new(uri.path)

  # Headers（如需更简洁可裁剪）
  request['Accept'] = 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7'
  request['Accept-Language'] = 'en-US,en;q=0.9,zh-CN;q=0.8,zh;q=0.7,fil;q=0.6'
  request['Cache-Control'] = 'no-cache'
  request['Connection'] = 'keep-alive'
  request['Content-Type'] = 'application/x-www-form-urlencoded'
  request['Cookie'] = 'rack.session=xtn734GhK35m2OvoaRnpfE5sRWGMLTI8VLoMB8CF1I0JOMXTwzRSimu3Rs3ekpo0rjULArdMo69I0lpOCoFJW3zPdrGcRu1tKs959pKXGvMoqVupbvKnXik8tyZSvsTN5E46Lum2GuCXDIRZA8wKymgmOC1TTsaEP82XMnhe3Z2LLAVYO9Ti6bxf0hv0UumeJbnv%2F5YNSb257fDjIqvYGhbHjh9IgLSXgHMZJyMBDCnzKItGewIUn9BNdGpERrm4TQiqIEhAhKK9WCBy76HfIg5tj%2FN8whqPZvvZTyZ%2FNzZ4F7alHUmL4U9NfdiwC5azLUE23U9Lr4WTs%2FQaUsDwEMrHCqaXS6iWOiIMFfeB0g0JqgSGes4hyMawMiSAQ72%2BjYwX%2FNDOXyoE0xU8xcJRoDOOmS79Ye3MNUTwWotkitcUwxZDWoe9kNVRS%2B8Ev17EVSWsoHASVeEeBIim35TX09RqAMxzV9uM5jcwKD0IcBUE--0sMMDHmnJngSJtAZ--gvg5ezmMYZI9rDacdyTAcg%3D%3D'
  request['Origin'] = 'http://127.0.0.1:4567'
  request['Pragma'] = 'no-cache'
  request['Referer'] = 'http://127.0.0.1:4567/admin/links'
  request['Sec-Fetch-Dest'] = 'document'
  request['Sec-Fetch-Mode'] = 'navigate'
  request['Sec-Fetch-Site'] = 'same-origin'
  request['Sec-Fetch-User'] = '?1'
  request['Upgrade-Insecure-Requests'] = '1'
  request['User-Agent'] = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36'
  request['sec-ch-ua'] = '"Chromium";v="136", "Google Chrome";v="136", "Not.A/Brand";v="99"'
  request['sec-ch-ua-mobile'] = '?0'
  request['sec-ch-ua-platform'] = '"macOS"'

  request.body = encoded_data

  response = http.request(request)
  puts "[#{index}] Status: #{response.code} - #{form_data['title']}"
end

http = Net::HTTP.new(uri.host, uri.port)

(1..10).each do |i|
  submit_link(http, uri, i)
  sleep 0.2  # 避免短时间过快提交导致服务阻断
end
