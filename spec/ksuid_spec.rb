# frozen_string_literal: true

RSpec.describe KSUID do
  it "has a version number" do
    expect(KSUID::VERSION).not_to be nil
  end

  it "is configurable" do
    generator = -> { "\x00" * KSUID::BYTES[:payload] }

    KSUID.configure { |config| config.random_generator = generator }

    expect(KSUID.config.random_generator).to eq(generator)
  end

  describe ".call" do
    it "returns KSUIDs in tact" do
      ksuid = KSUID.new

      result = KSUID.call(ksuid)

      expect(result).to eq(ksuid)
    end

    it "converts byte strings to KSUIDs" do
      ksuid = KSUID.new

      result = KSUID.call(ksuid.to_bytes)

      expect(result).to eq(ksuid)
    end

    it "converts byte arrays to KSUIDs" do
      ksuid = KSUID.new

      result = KSUID.call(ksuid.__send__(:uid))

      expect(result).to eq(ksuid)
    end

    it "converts base 62 strings to KSUIDs" do
      ksuid = KSUID.new

      result = KSUID.call(ksuid.to_s)

      expect(result).to eq(ksuid)
    end

    it "returns nil if passed nil" do
      result = KSUID.call(nil)

      expect(result).to be_nil
    end

    it "raise an ArgumentError upon an unknown value" do
      expect { KSUID.call(1) }.to raise_error(ArgumentError)
    end

    it "as_json converts it to json" do
      ksuid = KSUID.new
      expect(ksuid.as_json).to eq(ksuid.to_s)
    end

    it "to_json converts it to json string" do
      ksuid = KSUID.new
      expect(ksuid.to_json).to eq('"' + ksuid.to_s + '"')
    end

    it "to_yaml converts it to yaml" do
      ksuid = KSUID.new
      expect(ksuid.to_yaml).to eq(ksuid.to_s)
    end

    it "marshal dumps and loads" do
      ksuid = KSUID.new
      ksuid_dump = Marshal.dump(ksuid)
      expect(Marshal.load(ksuid_dump)).to eq(ksuid)
    end
  end
end
