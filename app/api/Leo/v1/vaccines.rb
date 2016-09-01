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
        authorize! :read, patient
        if patient && patient.vaccines.count > 0
          output = template.render(patient)
          WickedPdf.new.pdf_from_string(output, {page_size: 'Letter'})
        else
          error!({error_code: 422, user_message: "No vaccines record" }, 422)
        end
      end
    end
  end
end
