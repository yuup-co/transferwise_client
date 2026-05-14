module TransferwiseClient
  class CompleteBatchGroupRequest < Request
    attr_accessor :batch_group_id, :version

    def valid?
      true
    end

    def http_method
      :patch
    end

    def api_version
      "v3/profiles/#{profile_id}"
    end

    def path
      "batch-payments/#{batch_group_id}"
    end

    def to_h
      { version: version || 1, status: "COMPLETED" }
    end

    private

    def profile_id
      TransferwiseClient.configuration.profile_id
    end
  end
end
