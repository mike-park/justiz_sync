require "spec_helper"

describe JustizSync::Cli do

  it "syncs all BRD records" do
    JustizSync::Cli.start(%w(sync --verbose  --state=BRD))
  end

  xit "syncs all records" do
    JustizSync::Cli.start(%w(sync --verbose))
  end
end
