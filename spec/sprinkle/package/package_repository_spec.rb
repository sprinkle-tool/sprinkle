require File.expand_path("../../spec_helper", File.dirname(__FILE__))

describe Sprinkle::Package::PackageRepository do
  
  before do
    @repository = PackageRepository.new {}
    @test_package = Package.new(:test) {}
    @mysql_package = Package.new(:mysql, :provides => :db) {}
    @test_v2_package = Package.new(:test) do
      version "2"
    end
    @another_package = Package.new(:another) {}
  end

  it 'should allow adding a package' do
    @repository.add @test_package
    @repository.count.should eq 1
  end
  
  it 'should allow clearing' do
    @repository.add @test_package
    @repository.clear
    @repository.count.should eq 0
  end
  
  it "should find by provides" do
    @repository.add @mysql_package
    @repository.find_all("db").should eq [ @mysql_package ]
  end
  
  it "should find by name" do
    @repository.add @test_package
    @repository.find_all("test").should eq [ @test_package ]
  end
  
  it "should filter by version" do
    @repository.add @test_package
    @repository.add @test_v2_package
    @repository.find_all("test").size.should eq 2
    @repository.first("test", :version => "2").should eq @test_v2_package
  end

  after do
  end
  
end
