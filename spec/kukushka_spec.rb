# frozen_string_literal: true

RSpec.describe Kukushka do
  it "has a version number" do
    expect(Kukushka::VERSION).not_to be nil
  end

  context 'when sample list exists' do
    let(:lines) { File.readlines("fixtures/pl_001.txt", chomp: true) }

    it "do the job" do
      expect(Kukushka.kuku(['init', "fixtures/pl_001.txt"])).to eq nil
      expect(Kukushka.kuku(['config'])).to eq({:source=>"fixtures/pl_001.txt"})

      sample = Kukushka.kuku(['sample'])
      expect(lines).to include(sample)

      Kukushka.kuku(['cleanup'])
      expect(Kukushka.kuku(['config'])).to eq(Kukushka::INIT_CTA)
    end
  end
end
