module TransferwiseClient
  class BatchGroupTransferRequest < Request
    attr_accessor :target_account, :quote_uuid, :customer_transaction_id, :details, :batch_group_id

    def valid?
      true
    end

    def api_version
      "v3/profiles/#{TransferwiseClient.configuration.profile_id}"
    end

    def path
      "batch-groups/#{batch_group_id}/transfers"
    end

    def to_h
      {
        targetAccount: target_account,
        quoteUuid: quote_uuid,
        customerTransactionId: customer_transaction_id,
        details: details
      }
    end
  end
end
