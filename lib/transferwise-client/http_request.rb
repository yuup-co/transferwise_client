module TransferwiseClient
  # send request
  class HttpRequest
    def initialize(auth_key = nil)
      @auth_key = auth_key
    end

    def send_post_request(request)
      if request.api_version.present?
        custom_endpoint = endpoint.gsub("v1", request.api_version)
      else
        custom_endpoint = endpoint
      end

      url = URI("#{custom_endpoint}/#{request.path}")
      post_response = http_post(url, request.to_h.to_json)

      if post_response.response.header["x-2fa-approval-result"] == 'REJECTED' && post_response.response.header["x-2fa-approval"].present?

        # take one time token from failed request.
        ott = post_response.response.header["x-2fa-approval"]

        return http_post(url, request.to_h.to_json, ott)
      end
      post_response

    end

    def send_get_request(path, api_version: nil)
      custom_endpoint = if api_version
        endpoint.gsub("v1", api_version)
      else
        endpoint
      end

      url = URI("#{custom_endpoint}/#{path}")
      http_get(url)
    end

    def send_patch_request(request)
      if request.api_version.present?
        custom_endpoint = endpoint.gsub("v1", request.api_version)
      else
        custom_endpoint = endpoint
      end

      url = URI("#{custom_endpoint}/#{request.path}")
      http_patch(url, request.to_h.to_json)
    end

    def send_validation_request(validation_params)
      validation_params.map do |params|
        url = URI("#{validation_url}/#{params[:path]}")
        url.query = URI.encode_www_form(params[:params])
        http_get(url)
      end
    end

    private

    def http_post(url, body, ott = nil)
      if ott.present?
        private_pem = OpenSSL::PKey::RSA.new(sca_private_encryption_key)
        private_key = OpenSSL::PKey::RSA.new(private_pem.to_pem)
        signature_key = private_key.sign(OpenSSL::Digest::SHA256.new, ott.to_s)
        signature = Base64.strict_encode64(signature_key)
      end

      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true
      http_request = Net::HTTP::Post.new(url)
      http_request['Content-Type'] = 'application/json'
      http_request['Authorization'] = "Bearer #{@auth_key}"
      http_request['x-2fa-approval'] = ott.to_s if ott.present?
      http_request['X-Signature'] = signature.to_s if ott.present?
      http_request.body = body
      http.request(http_request)
    end

    def http_get(url)
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true
      http_request = Net::HTTP::Get.new(url)
      http_request['Content-Type'] = 'application/json'
      http_request['Authorization'] = "Bearer #{@auth_key}" if @auth_key
      http.request(http_request)
    end

    def http_patch(url, body)
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true
      http_request = Net::HTTP::Patch.new(url)
      http_request['Content-Type'] = 'application/json'
      http_request['Authorization'] = "Bearer #{@auth_key}"
      http_request.body = body
      http.request(http_request)
    end

    def endpoint
      TransferwiseClient.configuration.url
    end

    def validation_url
      TransferwiseClient.configuration.validation_url
    end

    def sca_private_encryption_key
      TransferwiseClient.configuration.sca_private_encryption_key
    end
  end
end
