require File.expand_path("../spec_helper", File.dirname(__FILE__))

describe Sprinkle::Policy do
  include Sprinkle::Core

  let(:empty) { Proc.new {} }
  let(:name) { 'a package' }
  let(:packages) { Sprinkle::Package::PACKAGES }
  let(:packages_inner) { packages.instance_variable_get(:@packages) }

  before do
    Sprinkle::Package::PACKAGES.clear
  end

  after do
    Sprinkle::Package::PACKAGES.clear
  end

  context 'with namespaces' do
    it 'should support the namespace dsl syntax' do
      expect {
        namespace :a do
          package name, &empty
        end
      }.not_to raise_error
      expect(packages.count).to eq(1)
      expect(packages_inner[0].name).to eq("a:#{name}")
    end

    it 'should not pollute namespaces' do
      expect {
        namespace :a do
          package name, &empty
        end
        namespace :b do
          package name, &empty
        end
      }.not_to raise_error
      expect(packages.count).to eq(2)
      expect(packages_inner[0].name).to eq("a:#{name}")
      expect(packages_inner[1].name).to eq("b:#{name}")
    end
  end

  context 'with nested namespaces' do
    before do
      expect {
        namespace :a do
          package name, &empty
          namespace :b do
            package name, &empty
          end
      end}.to_not raise_error
    end

    it 'should support nested namespaces' do
      expect(packages.count).to eq(2)
      expect(packages_inner[0].name).to eq("a:#{name}")
      expect(packages_inner[1].name).to eq("a:b:#{name}")
    end

    it 'still be able to find packages' do
      expect(packages.find_all("a:b:#{name}").size).to be(1)
      expect(packages.find_all("a:#{name}").size).to be(1)
    end
  end

  context 'with policies' do
    before do
      namespace :a do
        @p1 = package name, &empty
        namespace :b do
          @p2 = package name, &empty
        end
      end

      @deployment = double(Sprinkle::Deployment)
      @deployment.stub(:style).and_return(double(:servers_for_role? => true))
      @p1.stub(:instance).and_return(@p1)
      @p2.stub(:instance).and_return(@p2)
    end

    it 'should support namespaced packages' do
      p1,p2 = "a:#{name}", "a:b:#{name}"
      p = policy 'policy', :roles => :app do
        requires  p1
        requires  p2
      end

      expect(p.packages).to include(p1,p2)
      expect(@p1).to receive(:process)
      expect(@p2).to receive(:process)
      p.process(@deployment)
    end

  end
end
