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
    it "creates providers for valid athena_providers" do
      allow(@connector.connection).to receive("GET").and_return(Struct.new(:code, :body).new(200,IO.read("spec/mock_json/mock_providers.json")))
      @service.sync_providers @practice
      expect(Provider.count).to be(2)
    end
  end
end
