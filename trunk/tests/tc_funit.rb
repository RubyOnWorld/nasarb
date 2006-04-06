$:.unshift File.join( File.dirname(__FILE__), '..', 'lib' )
require 'funit'

class TestFunit < Test::Unit::TestCase

 include Funit
 include Funit::Assertions

 def testMainDriverCompiles
  writeTestRunner []
  assert File.exists?("TestRunner.f90")
  assert system("#{Funit::Compiler.new.name} TestRunner.f90")
  assert File.exists?("a.out")
 end

 def testIsEqual
  @suiteName = "dummy"
  @testName = "dummy"
  @lineNumber = "dummy"
  isequal("IsEqual(1.0,m(1,1))")
  assert_equal '.not.(1.0==m(1,1))', @condition
 end 

 def testIsRealEqual
  @suiteName = "dummy"
  @testName = "dummy"
  @lineNumber = "dummy"
  isrealequal("IsRealEqual(a,b)")
ans = <<EOF
.not.(a+2*spacing(real(a)).ge.b &
             .and.a-2*spacing(real(a)).le.b)
EOF
  assert_equal ans.chomp, @condition
  assert_equal '"b (",b,") is not",a,"within",2*spacing(real(a))', @message 

  isrealequal("IsRealEqual(1.0,m(1,1))")
ans = <<EOF
.not.(1.0+2*spacing(real(1.0)).ge.m(1,1) &
             .and.1.0-2*spacing(real(1.0)).le.m(1,1))
EOF
  assert_equal ans.chomp, @condition
 end

 def testHandlesDependency
  File.open('unit.f90','w') do |f|
   f.printf "module unit\n  use unita, only : a\nend module unit\n"
  end
  File.open('unita.f90','w') do |f|
   f.printf "module unita\n  integer :: a = 5\nend module unita\n"
  end
  File.open('unitMT.ftk','w') do |f|
   f.printf "beginTest A\n  IsEqual(5, a)\nendTest\n"
  end  
  assert_nothing_raised{runAllFtks}
 end

 def testEmbeddedDependencies
  File.open('unit.f90','w') do |f|
   f.printf "module unit\n  use unita, only : a\nend module unit\n"
  end
  File.open('unita.f90','w') do |f|
   f.printf "module unita\n  use unitb, only : b \n  integer :: a = b\nend module unita\n"
  end
  File.open('unitb.f90','w') do |f|
   f.printf "module unitb\n  integer,parameter :: b = 5\nend module unitb\n"
  end
  File.open('unitMT.ftk','w') do |f|
   f.printf "beginTest A\n  IsEqual(5, a)\nendTest\n"
  end  
  assert_nothing_raised{Funit::runAllFtks}
 end

 def testRequestedModules
  assert_equal ["asdfga"], requestedModules(["asdfga"])
  assert_equal ["asd","fga"], requestedModules(["asd","fga"])
  assert requestedModules([]).empty?
  modules = %w[ldfdl lmzd]
  ftks = modules.map{|f| f+'MT.ftk'}.join(' ')
  system "touch "+ftks
  assert_equal modules, requestedModules([])
 end

 def testFTKExists
  moduleName = "ydsbe"
  File.rm_f(moduleName+"MT.ftk")
  assert_equal false, ftkExists?(moduleName)
  system "touch "+moduleName+"MT.ftk"
  assert Funit::ftkExists?(moduleName)
 end

 def tear_down
  File.rm_f(*Dir["dummyunit*"])
  File.rm_f(*Dir["unit*"])
  File.rm_f(*Dir["ydsbe*"])
  File.rm_f(*Dir["lmzd*"])
  File.rm_f(*Dir["ldfdl*"])
  File.rm_f(*Dir["ydsbe*"])
  File.rm_f(*Dir["TestRunner*"])
  File.rm_f(*Dir["a.out"])
 end

end
