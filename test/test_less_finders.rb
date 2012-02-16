require 'rubygems'
require 'minitest/autorun'
require 'mini_shoulda'
require 'less_finders'


class LessFindersTest < MiniTest::Spec
  
  class Finder; include LessFinders; end
  
  
  should "scopes return just the scopes from the params" do
    params = {:controller => "expenses", :action => "index", :id => 7, :blah_id => 18}
    assert_equal( {:id => 7, :blah_id => 18}, Finder.new(params).send(:scopes))
  end

  should "scopes return just the scopes from the params for new" do
    params = {:controller => "expenses", :action => "new"}
    finder = RailsInteraction::Index.new params
    assert_equal( {}, finder.send(:scopes))
  end
  
  should "singular_instance without parent" do
    business = create_business
    business.update_attribute :expires_on, Date.today+1
    expense = create_expense :business_id => business.id
    params = {:controller => "expenses", :id => expense.id}
    finder = RailsInteraction::Index.new params, nil, business
    
    assert_equal( {:expense => expense}, finder.send(:singular_instance))
  end
  
  should "singular_instance with parent" do
    business = create_business 
    business.update_attribute :expires_on, Date.today+1
    expense = create_expense :business_id => business.id, :amount => 11
    expense_item = expense.expense_items.create!(:amount => 5)

    params = {:controller => "expense_items", :action => "index", :expense_id => expense.id, :id => expense_item.id}
    finder = RailsInteraction::Index.new params, nil, business
    
    assert_equal( {:expense => expense, :expense_item => expense_item}, finder.send(:singular_instance))
  end
  
  
  should "plural_instance without parent" do
    business = create_business
    business.update_attribute :expires_on, Date.today+1
    expense = create_expense :business_id => business.id
    params = {:controller => "expenses"}
    finder = RailsInteraction::Index.new params, nil, business
    
    assert_equal( {:expenses => [expense]}, finder.send(:plural_instance))
  end
  
  should "plural_instance with parent" do
    business = create_business 
    business.update_attribute :expires_on, Date.today+1
    expense = create_expense :business_id => business.id, :amount => 11

    params = {:controller => "expense_items", :action => "index", :expense_id => expense.id}
    finder = RailsInteraction::Index.new params, nil, business
    
    assert_equal( {:expense => expense, :expense_items => expense.expense_items}, finder.send(:plural_instance))
  end
  
  
  context "not nested" do
    
    context "infer object" do
    
      should "return an object class for the controller param" do
        params = {:controller => "expenses"}
        finder = RailsInteraction::Index.new params
        assert_equal Expense, finder.send(:object_class)
      end
    
      should "return an object name for the controller param" do
        params = {:controller => "expenses"}
        finder = RailsInteraction::Index.new params
        assert_equal "expense", finder.send(:object_name)
      end
      
      should "return the object id from the param" do
        params = {:id => 7}
        finder = RailsInteraction::Index.new params
        assert_equal 7, finder.send(:id)
      end
    end
      
    context "infer parent" do
      setup do
        @finder = RailsInteraction::Index.new( {})
        @finder.stubs(:scopes).returns({})
      end
      should "return '' for parent name" do
        assert_equal "", @finder.send(:parent_name)
      end

      should "return nil for parent class" do
        assert_equal nil, @finder.send(:parent_class)
      end
    
      should "return nil for parent id" do
        assert_equal nil, @finder.send(:parent_id)
      end
    
      should "return nil for parent id name" do
        assert_equal nil, @finder.send(:parent_id_name)
      end
    
      should "return nil for parent" do
        assert_equal nil, @finder.send(:parent)
      end
    end
  
  end
  
  
  context "nested" do
    
    context "infer object" do
    
      should "return an object class for the controller param" do
        params = {:controller => "expenses"}
        finder = RailsInteraction::Index.new params
        assert_equal Expense, finder.send(:object_class)
      end
    
      should "return an object name for the controller param" do
        params = {:controller => "expenses"}
        finder = RailsInteraction::Index.new params
        assert_equal "expense", finder.send(:object_name)
      end
      
      should "return the object id from the param" do
        params = {:id => 7}
        finder = RailsInteraction::Index.new params
        assert_equal 7, finder.send(:id)
      end
    end
      
    context "infer parent" do
      setup do
        @finder = RailsInteraction::Index.new( {:expense_id => 18})
      end
      should "return '' for parent name" do
        assert_equal "expense", @finder.send(:parent_name)
      end

      should "return nil for parent class" do
        assert_equal Expense, @finder.send(:parent_class)
      end
    
      should "return nil for parent id" do
        assert_equal 18, @finder.send(:parent_id)
      end
    
      should "return nil for parent id name" do
        assert_equal :expense_id, @finder.send(:parent_id_name)
      end
    end
  
  end
end
