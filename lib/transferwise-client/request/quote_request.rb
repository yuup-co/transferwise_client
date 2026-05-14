module TransferwiseClient
  # Quote request class
  class QuoteRequest < Request
    attr_accessor :source
    attr_accessor :target
    attr_accessor :target_amount
    attr_accessor :pay_out

    def valid?
      true
    end

    def path
      'quotes'
    end

    def api_version
      "v3/profiles/#{profile_id}"
    end

    def to_h
      {
        sourceCurrency: source,
        targetCurrency: target,
        targetAmount: target_amount,
        payOut: pay_out
      }
    end

    private

    def profile_id
      TransferwiseClient.configuration.profile_id
    end
  end
end
