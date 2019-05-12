require "./spec_helper"

describe WildcardLISP do
  # TODO: Write tests

  it "executes code" do
    WildcardLISP.exec %(print 1)
  end

  it "executes nested code" do
    WildcardLISP.exec %(print (+ 1 2))
  end

  it "can add together numbers and addition expressions" do
    WildcardLISP.exec %(print (+ 1 (+ 1 2)))
  end
end
