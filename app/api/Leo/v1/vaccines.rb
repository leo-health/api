module Leo
  module V1
    class Vaccines < Grape::API
      before do
        authenticated
      end

      # TIMESTAMP_Jain_Leo_Flatiron Pediatrics_Immunization_History.pdf
      get ':patient_id/vaccines' do
        content_type "application/octet-stream"
        header['Content-Disposition'] = "attachment; filename=vaccines.pdf"
        env['api.format'] = :binary
        template = Tilt::ERBTemplate.new(Rails.root.join('app', 'views', 'vaccines', 'vaccines.html.erb'))
        patient = Patient.find_by(id: params[:patient_id])
        if patient
          output = template.render(patient)
          WickedPdf.new.pdf_from_string(output, {page_size: 'Letter'})
        end
        # pdf = WickedPdf.new.pdf_from_string(output, {page_size: 'Letter'})
        # save_path = Rails.root.join('app', 'views', 'tmp.pdf')
        # File.open(save_path, 'wb'){|file| file << pdf }
      end
    end
  end
end
