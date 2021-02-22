require 'rest-client'
require 'json'


class Leaf
  attr_accessor :username, :password, :token, :user_id, :vin, :car

  def initialize(username=nil, password=nil)
    self.username = username
    self.password = password
    if(username.nil?)
      auth = JSON.parse(File.read(ENV['HOME']+'/.leaf.json'))
      self.username = auth['username']
      self.password = auth['password']
    end
  end

  def login
    headers = {}
    headers["Accept-Api-Version"] = 'protocol=1.0,resource=2.1';
    headers["Host"] = "prod.eu.auth.kamereon.org";
    headers["Accept-Api-Version"] = "protocol=1.0,resource=2.1";
    headers["Origin"] = "https://prod.eu.auth.kamereon.org";
    headers["X-Password"] = "anonymous";
    headers["Accept-Language"] = "en-UK";
    headers["X-Username"] = "anonymous";
    headers["User-Agent"] =
        "Mozilla/5.0 (Linux; Android 5.1.1; SM-N950N Build/NMF26X; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/74.0.3729.136 Mobile Safari/537.36";
    headers["Content-Type"] = "application/json";
    headers["Accept"] = "application/json, text/javascript, */*; q=0.01";
    headers["Cache-Control"] = "no-cache";
    headers["X-Requested-With"] = "XMLHttpRequest";
    headers["X-Nosession"] = "true";
    headers["Referer"] =
        "https://prod.eu.auth.kamereon.org/kauth/XUI/?realm=%2Fa-ncb-prod&goto=https%3A%2F%2Fprod.eu.auth.kamereon.org%2Fkauth%2Foauth2%2Fa-ncb-prod%2Fauthorize%3Fclient_id%3Da-ncb-prod-android%26redirect_uri%3Dorg.kamereon.service.nci%253A%252Foauth2redirect%26response_type%3Dcode%26scope%3Dopenid%2520profile%2520vehicles%26state%3Daf0ifjsldkj%26nonce%3Dsdfdsfez";
    headers["Cookie"] = "i18next=en-UK";

    url = "https://prod.eu.auth.kamereon.org/kauth/json/realms/root/realms/a-ncb-prod/authenticate?goto=https%3A%2F%2Fprod.eu.auth.kamereon.org%2Fkauth%2Foauth2%2Fa-ncb-prod%2Fauthorize%3Fclient_id%3Da-ncb-prod-android%26redirect_uri%3Dorg.kamereon.service.nci%253A%252Foauth2redirect%26response_type%3Dcode%26scope%3Dopenid%2520profile%2520vehicles%26state%3Daf0ifjsldkj%26nonce%3Dsdfdsfez"

    resp = RestClient.post(url, nil, headers)
    body = JSON.parse(resp.body)
    #puts "AuthId: #{body['authId']}"

    headers['Cookie'] = resp.headers[:set_cookie];

    body['callbacks'].each {|c| i = c['input'].first; i['value'] = i['name'] == 'IDToken1' ? username : password }

    url = "https://prod.eu.auth.kamereon.org/kauth/json/realms/root/realms/a-ncb-prod/authenticate?goto=https%3A%2F%2Fprod.eu.auth.kamereon.org%2Fkauth%2Foauth2%2Fa-ncb-prod%2Fauthorize%3Fclient_id%3Da-ncb-prod-android%26redirect_uri%3Dorg.kamereon.service.nci%253A%252Foauth2redirect%26response_type%3Dcode%26scope%3Dopenid%2520profile%2520vehicles%26state%3Daf0ifjsldkj%26nonce%3Dsdfdsfez",

    body = JSON.parse(RestClient.post(url, JSON.generate(body), headers).body)

    token_id = body['tokenId']
    #puts "TokenID: #{token_id}"

    headers = {}
    headers["Host"] = "prod.eu.auth.kamereon.org"
    headers["Upgrade-Insecure-Requests"] = "1";
    headers["User-Agent"] = "Mozilla/5.0 (Linux; Android 5.1.1; SM-N950N Build/NMF26X; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/74.0.3729.136 Mobile Safari/537.36";
    headers["Accept"] = "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3"
    headers["Referer"] = "https://prod.eu.auth.kamereon.org/kauth/XUI/?realm=%2Fa-ncb-prod&goto=https%3A%2F%2Fprod.eu.auth.kamereon.org%2Fkauth%2Foauth2%2Fa-ncb-prod%2Fauthorize%3Fclient_id%3Da-ncb-prod-android%26redirect_uri%3Dorg.kamereon.service.nci%253A%252Foauth2redirect%26response_type%3Dcode%26scope%3Dopenid%2520profile%2520vehicles%26state%3Daf0ifjsldkj%26nonce%3Dsdfdsfez"
    headers["Accept-Language"] = "en-UK,en-US;q=0.9,en;q=0.8"
    headers["Cookie"] = "i18next=en-UK; amlbcookie=05; kauthSession=\"#{token_id}\""
    headers["X-Requested-With"] = "com.android.browser"

    url = "https://prod.eu.auth.kamereon.org/kauth/oauth2/a-ncb-prod/authorize?client_id=a-ncb-prod-android&redirect_uri=org.kamereon.service.nci%3A%2Foauth2redirect&response_type=code&scope=openid%20profile%20vehicles&state=af0ifjsldkj&nonce=sdfdsfez"

    begin
      resp = RestClient::Request.execute(method: :get, url: url, headers: headers, max_redirects: 0)
    rescue RestClient::ExceptionWithResponse => e
      code = /code=([\w-]+)/.match(e.response.headers[:location])[1]
    end

    #puts "Code: #{code}"

    headers = {}
    headers["Host"] = 'prod.eu.auth.kamereon.org'
    headers["User-Agent"] = 'okhttp/3.11.0';
    headers["Content-Type"] = 'application/x-www-form-urlencoded';

    url = "https://prod.eu.auth.kamereon.org/kauth/oauth2/a-ncb-prod/access_token?code=#{code}&client_id=a-ncb-prod-android&client_secret=3LBs0yOx2XO-3m4mMRW27rKeJzskhfWF0A8KUtnim8i%2FqYQPl8ZItp3IaqJXaYj_&redirect_uri=org.kamereon.service.nci%3A%2Foauth2redirect&grant_type=authorization_code"

    resp = RestClient.post(url, nil, headers)
    body = JSON.parse(resp.body)
    self.token = body['access_token']
    #puts "Token: #{self.token}"

    url = "https://alliance-platform-usersadapter-prod.apps.eu.kamereon.io/user-adapter/v1/users/current"
    body = get(url)
    self.user_id = body['userId']
    #puts "UserID: #{self.user_id}"

    url = "https://nci-bff-web-prod.apps.eu.kamereon.io/bff-web/v2/users/#{self.user_id}/cars"
    body = get(url)
    self.car = body['data'].first
    self.vin = self.car['vin']
    #puts "VIN: #{self.vin}"

    #puts "Login complete"
    true
  end

  def get(url, params = nil)
    url = "https://alliance-platform-caradapter-prod.apps.eu.kamereon.io/car-adapter/"+url unless url.start_with?('https')
    headers = { 'Authorization' => "Bearer #{self.token}", :params => params }
    headers["Accept"] = 'application/vnd.api+json'
    resp = RestClient.get(url, headers)
    JSON.parse(resp.body)
  end

  def post(url, body)
    url = "https://alliance-platform-caradapter-prod.apps.eu.kamereon.io/car-adapter/"+url unless url.start_with?('https')
    body = JSON.generate(body) unless body.class == String
    headers = { 'Authorization' => "Bearer #{self.token}" }
    headers["Content-Type"] = "application/vnd.api+json";
    headers["Accept"] = 'application/vnd.api+json'
    resp = RestClient.post(url, body, headers)
    JSON.parse(resp.body)
  end

  def status(name, params = nil)
    url = "v1/cars/#{vin}/#{name}"
    get(url, params)
  end

  def action(name, attributes = nil)
    url = "v1/cars/#{vin}/actions/#{name}"
    name = name.split('-').map(&:capitalize).join
    body = { data: { type: "#{name}" }}
    body[:data][:attributes] = attributes if attributes
    post(url, body)
  end

  def battery_refresh
    action('refresh-battery-status')
  end

  def battery_status
    status('battery-status')
  end

  def charging_start
    action('charging-start', { action: 'start'})
  end

  def charging_stop
    action('charging-start', { action: 'stop'})
  end

  def hvac_refresh
    action('refresh-hvac-status')
  end

  def hvac_status
    status('hvac-status')
  end

  def hvac_start
    action('hvac-start', { action: 'start', targetTemperature: 21})
  end

  def hvac_stop
    action('hvac-start', { action: 'stop'})
  end

  def hvac_cancel
    action('hvac-start', { action: 'cancel'})
  end

  def location_refresh
    action('refresh-location')
  end

  def location
    status('location')
  end

  def cockpit
    status('cockpit')
  end

  def pressure
    status('pressure')
  end

  def trip_history(period, start, stop)
    status('trip-history', {type: period, start: start, end: stop})
  end

end

if(ARGV[0])
  l = Leaf.new
  l.login
  r = l.send(ARGV[0])
  puts JSON.pretty_generate(r) if ARGV[0].end_with?('status')
end
