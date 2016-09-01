module Leo
  module V1
    class Vaccines < Grape::API
      before do
        authenticated
      end

      get ':patient_id/vaccines' do
        content_type "application/pdf"
        env['api.format'] = :binary
        template = Tilt::ERBTemplate.new(Rails.root.join('app', 'views', 'vaccines', 'vaccines.html.erb'))
        patient = Patient.find_by(id: params[:patient_id])
        if patient && patient.vaccines.count > 1
          output = template.render(patient)
          WickedPdf.new.pdf_from_string(output, {page_size: 'Letter'})
        end
      end
    end
  end
end
