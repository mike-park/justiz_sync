require_relative "spec_helper"

describe JustizSync::OpencrxCourt do
  let(:court1) { Justiz::Contact.new(court: 'TEST 1') }
  let(:court2) { Justiz::Contact.new(court: 'TEST 2') }

  before do
    Opencrx::connect("http://localhost:8080", "guest", "guest")
  end

  before do
    ids = JustizSync::OpencrxCourt.all_ids
    JustizSync::OpencrxCourt.destroy(ids)
  end

  it "streams" do
    JustizSync::OpencrxCourt.sync(court1)
    stream = JustizSync::Stream.new
    stream.sync(court2)
    stream.close(true)
    crx = JustizSync::OpencrxCourt.find(court1.id)
    expect(crx).to_not be
    crx = JustizSync::OpencrxCourt.find(court2.id)
    expect(crx.name).to eq(court2.court)
    crx.destroy
  end

  it "deletes all entries" do
    stream = JustizSync::Stream.new
    stream.close
    result_set = JustizSync::OpencrxCourt.find_tagged
    expect(result_set.length).to eq(0)
  end
end
