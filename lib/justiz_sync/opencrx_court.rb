require 'opencrx'

module JustizSync
  class OpencrxCourt
    TAG = 'justiz'

    attr_reader :court

    class << self
      def sync(justiz_court)
        OpencrxCourt.new(justiz_court).sync
      end

      def find(id)
        query = id_to_query(id)
        Opencrx::Model::LegalEntity.query(query).first
      end

      def find_tagged
        tagged = []
        position = 0
        size = 500
        begin
          result_set = Opencrx::Model::LegalEntity.query(size: size, position: position,
                                                         query: "thereExistsUserString2().equalTo(\"#{TAG}\")")
          position += result_set.length
          tagged += result_set
        end while result_set && result_set.more?
        tagged
      end

      def all_ids
        find_tagged.map { |crx| crx.userString1 }
      end

      def destroy(ids)
        ids.each do |id|
          crx = find(id)
          crx.destroy if crx
        end
      end

      # court.id is stored in openCRX userString1
      def id_to_query(id)
        {query: "thereExistsUserString1().equalTo(\"#{id}\")"}
      end
    end


    def initialize(court)
      @court = court
    end

    def sync
      return 0 if entity.userString3 == court.digest

      entity.name = court.court
      entity.aliasName = court.justiz_id
      entity.userString3 = court.digest
      entity.save

      court_address = court.location_address
      process_address(Opencrx::Model::PostalAddress, usage(:visitor), court_address.city.blank?) do |address|
        address.postalStreet = court_address.street
        address.postalCode = court_address.plz
        address.postalCity = court_address.city
        address.postalCountry = country(:de)
      end

      court_address = court.post_address
      process_address(Opencrx::Model::PostalAddress, usage(:business), court_address.city.blank?) do |address|
        address.postalStreet = court_address.street
        address.postalCode = court_address.plz
        address.postalCity = court_address.city
        address.postalCountry = country(:de)
      end

      process_address(Opencrx::Model::PhoneNumber, usage(:business), court.phone.blank?) do |address|
        address.phoneNumberFull = court.phone
        address.automaticParsing = true
      end

      process_address(Opencrx::Model::PhoneNumber, usage(:fax), court.fax.blank?) do |address|
        address.phoneNumberFull = court.fax
        address.automaticParsing = true
      end

      process_address(Opencrx::Model::EMailAddress, usage(:business), court.email.blank?) do |address|
        address.emailAddress = court.email
      end

      process_address(Opencrx::Model::WebAddress, usage(:business), court.url.blank?) do |address|
        address.webUrl = court.url
      end

      1
    end

    def addresses
      @addresses ||= entity.query(:address, self.class.id_to_query(court.id))
    end

    def entity
      @entity ||= find_entity || create_entity
    end

    private

    def process_address(klass, usage, destroy, &block)
      address = find_address(klass, usage)
      if destroy
        address.destroy if address
        return
      end
      address ||= build_address(klass, usage)
      update_address(address, &block)
    end

    def update_address(address, &block)
      original_attrs = address.attributes.dup
      address.isMain = true
      yield address
      address.save if address.attributes != original_attrs
    end

    def find_address(klass, usage)
      addresses.find do |address|
        address.usage.include?(usage.to_s) && address.class == klass
      end
    end

    def build_address(klass, usage)
      address = klass.new(usage: usage, userString1: court.id, userString2: TAG)
      address.assign_to(entity)
      address
    end

    def usage(name)
      Opencrx::Model::Address::USAGE[name]
    end

    def country(name)
      Opencrx::Model::PostalAddress::COUNTRY[name]
    end

    def find_entity
      self.class.find(court.id)
    end

    def create_entity
      le = Opencrx::Model::LegalEntity.new(name: court.court, userString1: court.id, userString2: TAG)
      puts "Failed to save #{court.court}" unless le.save
      le
    end

  end
end