namespace :backfill do
  desc 'back fill closure_reason_id on closure_note'
  task closure_reason_id: :environment do
    ClosureNote.where(closure_reason_id: nil).find_each do |note|
      note.closure_reason = ClosureReason.find(6)
      print "failed to set closure reason id for note #{note.id}" unless note.save
    end
  end
end
