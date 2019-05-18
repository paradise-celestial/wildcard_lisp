require "./spec_helper"

describe WildcardLISP do
  describe "nil" do
    it "exists" do
      %(nil).should execute_to nil
    end

    it "can be printed" do
      %(print nil).should execute_to_output "nil"
    end
  end

  describe "numbers" do
    they "exist" do
      %(1).should execute_to 1
    end

    they "can be negative" do
      %(-1).should execute_to -1
    end

    they "can be floats" do
      %(0.5).should execute_to 0.5
    end

    they "can be added" do
      %(+ 1 2).should execute_to 3
    end

    they "can be added to floats" do
      %(+ 1 0.3).should execute_to 1.3
    end

    they "can be added with nesting" do
      %(+ 3 (+ 1 3 2)).should execute_to 9
    end

    they "can be subtracted" do
      %(- 3 1 1).should execute_to 1
    end

    they "can be subtracted from floats" do
      %(- 3 1 1.5).should execute_to 0.5
    end
  end

  describe "strings" do
    they "exist" do
      %("hello world").should execute_to "hello world"
    end

    they "can be concatenated" do
      %(+ "hello " 'world').should execute_to "hello world"
    end

    they "can be concatenated with nesting" do
      %(+ "hello" (+ " " "wonderful" " ") 'world').should execute_to "hello wonderful world"
    end
  end

  describe "variables" do
    they "should raise exceptions if called before creation" do
      expect_raises(Exception, "no such wildcard foo") do
        WildcardLISP.exec %(foo)
      end

      expect_raises(Exception, "no such wildcard foo") do
        WildcardLISP.exec %(+ 1 (foo))
      end
    end

    they "can be created" do
      context = WildcardLISP::Context.from_registry

      %(set foo 5).should execute_to 5, context: context
      %(+ foo 1).should execute_to 6, context: context
      %(+ (foo) 1).should execute_to 6, context: context
    end

    they "can be created locally in `let` blocks" do
      %(let foo 5 (+ foo 1)).should execute_to 6
    end

    pending "cannot be accessed outside their `let` blocks" do
      expect_raises(Exception, "no such wildcard foo") do
        WildcardLISP.exec %(+ (let foo 5 (+ foo 1)) foo)
      end
    end
  end

  describe "logical" do
    describe "`if` statements" do
      %(if "T" 5 1).should execute_to 5
      %(if nil 5 1).should execute_to 1

      they "have overloading support" do
        %(if "T" (print 5) (print 1)).should execute_to_output "5"
        %(if nil (print 5) (print 1)).should execute_to_output "1"
      end
    end

    describe "`and` statements" do
      %(and 5 1 "T").should execute_to 5
      %(and 7).should execute_to 7
      %(and nil).should execute_to nil
      %(and nil "5").should execute_to nil
      %(and 3 "T" nil).should execute_to nil

      # TODO: More tests
      they "have overloading support" do
        %(and (print 2) (print 3)).should execute_to_output "2"
      end
    end

    describe "`or` statements" do
      %(or 7).should execute_to 7
      %(or 5 1 "T").should execute_to 5
      %(or 3 "T" nil).should execute_to 3
      %(or nil 5).should execute_to 5
      %(or nil 3 6).should execute_to 3
      %(or nil).should execute_to nil
      %(or nil nil nil).should execute_to nil

      # TODO: More tests
      they "have overloading support" do
        %(or (print 2) (print 3)).should execute_to_output "23"
      end
    end

    describe "`not` statements" do
      %(not 1).should execute_to nil
      %(not "T").should execute_to nil
      %(not (not nil)).should execute_to nil
      %(not nil).should execute_to "T"
    end
  end

  describe "lambdas" do
    pending "can be created" do
      %(let add_one (lambda (a) (+ a 1)) (add_one 4)).should execute_to 5
    end
  end
end
