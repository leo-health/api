require "rails_helper"
describe AthenaPracticeSyncService do
  before do
    @service = AthenaPracticeSyncService.new
    @connector = AthenaHealthApiHelper::AthenaHealthApiConnector.instance
  end

  describe ".sync_providers" do
    before do
      @practice = create(:practice, athena_id: 1)
    end
    it "creates users with clinical role" do
      allow(@connector.connection).to receive("GET").and_return(Struct.new(:code, :body).new(200,IO.read("spec/mock_json/mock_providers.json")))
      @service.sync_providers @practice
      expect(StaffProfile.count).to be(3)
    end
  end
end
