module Leo
  module V1
    class Vaccines < Grape::API
      resource :vaccines do
        get do
          content_type "application/octet-stream"
          # TIMESTAMP_Jain_Leo_Flatiron Pediatrics_Immunization_History.pdf
          header['Content-Disposition'] = "attachment; filename={}"
          env['api.format'] = :binary
          template = Tilt::ERBTemplate.new(Rails.root.join('app', 'views', 'vaccines', 'vaccines.html.erb'))
          p = Patient.all[1]
          output = template.render(p)
          pdf = WickedPdf.new.pdf_from_string(output, {page_size: 'Letter'})
          save_path = Rails.root.join('app', 'views', 'tmp.pdf')
          File.open(save_path, 'wb'){|file| file << pdf }
        end
      end
    end
  end
end
