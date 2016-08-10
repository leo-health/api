namespace :backfill do
  desc 'back fill closure_reason_id on closure_note'
  task closure_reason_id: :environment do
    ClosureNote.where(closure_reason_id: nil).find_each do |reason|
      default_closure_reason_id = 7
      print "failed to set closure reason id for note #{note.id}" unless reason.update_attributes(closure_reason_id: default_closure_reason_id)
    end
  end
end
