module Leo
  module V1
    class ReadReceipts < Grape::API
      resource :read_receipts
      before do
        authenticated
      end

      desc "create a message receipt"
      params do
        requires :message_id, type: Integer, allow_blank: false
      end

      post do
        message = Message.find(params[:message_id])
        read_receipt = ReadReceipt.new(reader: current_user, message: message)
        if read_receipt.save
          present :read_receipt, read_receipt
        end
      end
    end
  end
end
