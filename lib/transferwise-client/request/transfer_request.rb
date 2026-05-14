module TransferwiseClient
  # Quote request class
  class TransferRequest < Request
    attr_accessor :target_account
    attr_accessor :quote
    attr_accessor :customer_transaction_id
    attr_accessor :details

    def valid?
      true
    end

    def path
      'transfers'
    end

    def to_h
      {
        targetAccount: target_account, quote: quote,
        customerTransactionId: customer_transaction_id,
        details: details
      }
    end
  end
end
