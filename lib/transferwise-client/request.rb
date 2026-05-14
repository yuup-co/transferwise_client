module TransferwiseClient
  # Quote request class
  class Request < Hash
    def path
      raise 'Path not implemented.'
    end

    def validation_params
      {}
    end

    def api_version
      nil
    end

    def http_method
      :post
    end

    def to_h
      raise 'to_h not implemented.'
    end
  end
end
