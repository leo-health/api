module Leo
  module V1
    class Notes < Grape::API
      desc 'return a single escalation_note or closure_note'
      before do
        authenticated
      end

      params do
        requires :note_type, type: String, allow_blank: false, values: ['escalation', 'close']
      end

      get 'notes/:id' do
        if params[:note_type].to_sym == :escalation
          note = EscalationNote.find(params[:id])
        else
          note = ClosureNote.find(params[:id])
        end
        present :note, note, with: Leo::Entities::FullMessageEntity
      end
    end
  end
end
