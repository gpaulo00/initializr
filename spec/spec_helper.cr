require "spec2"
require "../src/managers/index"
require "../src/runners"

include Spec2::GlobalDSL

# Documentation Reporter
Spec2.doc

# My own basic mock system
module MyMock(T)
  getter mock = [] of T

  def clear
    @mock.clear
  end
end

# Mock implementation of `Initializr::Managers::IPackageManager`
class MockPackageManager < Initializr::Managers::IPackageManager
  include MyMock(String)
  id "test"
  name "mock manager"

  def to_install(input : Array(String)) : Bool?
    @mock += input
    nil
  end
end

# Mock implementation of `Initializr::Runners::IRunner`
class MockRunner < Initializr::Runners::IRunner
  include MyMock(String)

  def to_run(input : Array(String))
    @mock += input
  end
end

# Mock implementation of `Initializr::Managers::IManagersList`
class MockManagersList < Initializr::Managers::IManagersList
  def initialize(mock : Initializr::Managers::IPackageManager)
    @availables << mock
  end
end
