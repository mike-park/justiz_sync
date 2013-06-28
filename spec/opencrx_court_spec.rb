require_relative "spec_helper"

describe JustizSync::OpencrxCourt do
  let(:court) { Justiz::Contact.new(court: 'TEST Staatsanwaltschaft Düsseldorf',
                                    location: 'Fritz-Roeber-Straße 2, 40213 Düsseldorf',
                                    post: 'P.O.Box 123, 40999 Düsseldorf - Post',
                                    phone: '0211 6025 0',
                                    fax: '0211 6025 2929',
                                    justiz_id: 'R1100S',
                                    url: 'http://www.sta-duesseldorf.nrw.de',
                                    email: 'poststelle@sta-duesseldorf.nrw.de') }


  before do
    Opencrx::connect("http://localhost:8080", "guest", "guest")
  end

  context "sync" do
    before do
      delete_courts(court.id)
    end

    def find_attribute(addresses, name)
      addresses.map do |address|
        address.attribute(name)
      end.compact
    end

    def match_court(court, crx)
      #ap crx.compact
      #ap crx.addresses.map(&:compact)

      expect(crx.name).to eq(court.court)
      expect(crx.aliasName).to eq(court.justiz_id)
      expect(crx.userString1).to eq(court.id)
      expect(crx.userString2).to eq(JustizSync::OpencrxCourt::TAG)
      expect(crx.userString3).to eq(court.digest)

      addresses = crx.addresses

      expect(find_attribute(addresses, :phoneNumberFull)).to include(court.phone, court.fax)
      expect(find_attribute(addresses, :postalCode)).to include(court.post_address.plz, court.location_address.plz)
      expect(find_attribute(addresses, :webUrl)).to eq([court.url])
      expect(find_attribute(addresses, :emailAddress)).to eq([court.email])
    end

    it "should create and find court" do
      expect(JustizSync::OpencrxCourt.sync(court)).to eq(1)
      crx = JustizSync::OpencrxCourt.find(court.id)
      match_court(court, crx)
      delete_courts(court.id)
    end

    # id is now digest, so any changes creates a new id
    #it "should update court" do
    #  JustizSync::OpencrxCourt.sync(court)
    #
    #  updated_court = court.dup
    #  updated_court.url += ' Update'
    #
    #  expect(JustizSync::OpencrxCourt.sync(updated_court)).to eq(1)
    #  crx = JustizSync::OpencrxCourt.find(court.id)
    #  match_court(updated_court, crx)
    #  crx.destroy
    #  expect(JustizSync::OpencrxCourt.find(court.id)).to_not be
    #end

    it "should not update unchanged court" do
      JustizSync::OpencrxCourt.sync(court)
      crx = JustizSync::OpencrxCourt.find(court.id)
      match_court(court, crx)

      expect(JustizSync::OpencrxCourt.sync(court)).to eq(0)
      crx.destroy
    end
  end
end
