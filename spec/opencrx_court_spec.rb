require_relative "spec_helper"

describe JustizSync::OpencrxCourt do
  before do
    Opencrx::connect("http://localhost:8080", "guest", "guest")
  end

  context "sync" do
    let(:court) { OpenStruct.new(court: 'Staatsanwaltschaft Düsseldorf',
                                 location_address: OpenStruct.new(
                                     street: 'Fritz-Roeber-Straße 2', plz: '40213', city: 'Düsseldorf'),
                                 post_address: OpenStruct.new(
                                     street: 'P.O.Box 123', plz: '40999', city: 'Düsseldorf - Post'),
                                 phone: '0211 6025 0',
                                 fax: '0211 6025 2929',
                                 justiz_id: 'R1100S',
                                 url: 'http://www.sta-duesseldorf.nrw.de',
                                 email: 'poststelle@sta-duesseldorf.nrw.de',
                                 id: 'Staatsanwaltschaft Düsseldorf/poststelle@sta-duesseldorf.nrw.de'
    ) }

    let(:vcr_options) { {match_requests_on: [:method, :path, :query, :body]} }

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
      expect(crx.attribute(:userString1)).to eq(court.id)

      addresses = crx.addresses

      expect(find_attribute(addresses, :phoneNumberFull)).to include(court.phone, court.fax)
      expect(find_attribute(addresses, :postalCode)).to include(court.post_address.plz, court.location_address.plz)
      expect(find_attribute(addresses, :webUrl)).to eq([court.url])
      expect(find_attribute(addresses, :emailAddress)).to eq([court.email])
    end

    it "should create a court" do
      VCR.use_cassette('create', vcr_options) do
        JustizSync::OpencrxCourt.sync(court)
        crx = JustizSync::OpencrxCourt.find(court.id)
        match_court(court, crx)
      end
    end

    it "should find court" do
      VCR.use_cassette('find', vcr_options) do
        crx = JustizSync::OpencrxCourt.find(court.id)
        match_court(court, crx)
      end
    end

    it "should update a court" do
      VCR.use_cassette('update', vcr_options) do
        court.court += ' Update'
        court.post_address.plz += ' Update'
        court.url += ' Update
'
        JustizSync::OpencrxCourt.sync(court)
        crx = JustizSync::OpencrxCourt.find(court.id)

        expect(court.court).to match(/Update/)
        match_court(court, crx)
      end
    end
  end
end
