require "spec_helper"

describe JustizSync::Cli do
  let(:vcr_options) { {record: :new_episodes, match_requests_on: [:method, :path, :query]} }

  it "syncs all records" do
    VCR.use_cassette('cli/sync', vcr_options) do
      JustizSync::Cli.start(%w(sync --verbose  --state=BRD))
    end
  end
end
