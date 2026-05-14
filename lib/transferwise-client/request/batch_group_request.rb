module TransferwiseClient
  class BatchGroupRequest < Request
    attr_accessor :source_currency, :name

    def valid?
      true
    end

    def api_version
      "v3/profiles/#{profile_id}"
    end

    def path
      "batch-payments"
    end

    def to_h
      { sourceCurrency: source_currency, name: name }
    end

    private

    def profile_id
      TransferwiseClient.configuration.profile_id
    end
  end
end
