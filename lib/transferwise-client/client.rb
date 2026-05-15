module TransferwiseClient
  # Create quote
  class Client
    def self.connect(auth_key)
      # Test connection
      TransferwiseClient::Client.new(auth_key)
    end

    attr_reader :profiles

    def initialize(auth_key)
      @http_request = HttpRequest.new(auth_key)
    end

    # POST requests
    def create_account(account_request)
      return nil unless account_request.valid?

      transferwise_response = @http_request.send_post_request(account_request)
      Account.new(ResponseFactory.new(transferwise_response).response.to_h)
    end

    def create_quote(quote_request)
      return nil unless quote_request.valid?

      transferwise_response = @http_request.send_post_request(quote_request)
      Quote.new(ResponseFactory.new(transferwise_response).response.to_h)
    end

    def temporary_quote(source, target, target_amount)
      transferwise_response = @http_request.send_get_request(
        "quotes?source=#{source}&target=#{target}&targetAmount=#{target_amount}&rateType=FIXED"
      )
      Quote.new(ResponseFactory.new(transferwise_response).response.to_h)
    end

    def create_transfer(transfer_request)
      return nil unless transfer_request.valid?

      transferwise_response = @http_request.send_post_request(transfer_request)
      Transfer.new(ResponseFactory.new(transferwise_response).response.to_h)
    end

    def fund(fund_request)
      return nil unless fund_request.valid?

      transferwise_response = @http_request.send_post_request(fund_request)
      ResponseFactory.new(transferwise_response).response
    end

    def create_batch_group_transfer(transfer_request)
      return nil unless transfer_request.valid?

      transferwise_response = @http_request.send_post_request(transfer_request)
      Transfer.new(ResponseFactory.new(transferwise_response).response.to_h)
    end

    def create_batch_group(batch_group_request)
      return nil unless batch_group_request.valid?

      transferwise_response = @http_request.send_post_request(batch_group_request)
      ResponseFactory.new(transferwise_response).response
    end

    def complete_batch_group(complete_request)
      return nil unless complete_request.valid?

      if complete_request.version.nil?
        # get the version immediately before completing
        batch_group = get_batch_group(complete_request.batch_group_id)
        complete_request.version = batch_group.version
      end

      transferwise_response = @http_request.send_patch_request(complete_request)
      ResponseFactory.new(transferwise_response).response
    end

    # GET requests
    def get_transfer(transfer_id)
      transferwise_response = @http_request.send_get_request("transfers/#{transfer_id}")
      Transfer.new(ResponseFactory.new(transferwise_response).response.to_h)
    end

    def get_quote(quote_id)
      transferwise_response = @http_request.send_get_request("quotes/#{quote_id}")
      Quote.new(ResponseFactory.new(transferwise_response).response.to_h)
    end

    def get_batch_group(batch_id)
      profile_id = TransferwiseClient.configuration.profile_id
      transferwise_response = @http_request.send_get_request("profiles/#{profile_id}/batch-groups/#{batch_id}", api_version: "v3")
      BatchGroup.new(ResponseFactory.new(transferwise_response).response.to_h)
    end

    def get_account_statement(borderless_account_id, currency,
                              start_date = 4.week.ago.utc.iso8601,
                              end_date = Time.now.utc.iso8601)
      transferwise_response = @http_request.send_get_request(
        "borderless-accounts/#{borderless_account_id}/statement.json?currency=#{currency}&" \
        "intervalStart=#{start_date}&intervalEnd=#{end_date}"
      )

      ResponseFactory.new(transferwise_response).response.transactions
    end

    def get_borderless_account(profile_id)
      transferwise_response = @http_request.send_get_request(
        "borderless-accounts?profileId=#{profile_id}"
      )
      ResponseFactory.new(transferwise_response).response[0]
    end

    def get_account_credits(borderless_account_id, currency, start_date = 4.week.ago.utc.iso8601,
                            end_date = Time.now.utc.iso8601)
      get_account_statement(borderless_account_id, currency, start_date, end_date)
        .select do |transaction|
          transaction['type'] == 'CREDIT'
        end
    end

    def get_account_balances(profile_id)
      get_borderless_account(profile_id).balances
    end
  end
end
