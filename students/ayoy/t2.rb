#!/usr/bin/env ruby

# This exercise will teach you how to use modules in ruby
#
# In the village there are 3 types of beings
#
#  * Human - he is mortal and can solve problems
#  * Dogs - it is mortal but can not solve problems
#  * Ghost - it is immortal and can also solve problems
#
#  HINT: we see that following behaviours are shared
#    * Human and Dog share mortality
#    * Human and Ghost share intelligence
#
# Look at the testcase for more details...
#

module Intelligence
  attr_reader :intelligence

  def init_intelligence(hash)
    @intelligence = hash[:intelligence]
  end

  def solve(difficulty)
    if @intelligence >= difficulty
      @intelligence += 1
      return true
    end
    false
  end
end

module Mortality
  def self.included(base)
    base.send(:include, InstanceMethods)
    base.send(:extend, ClassMethods)
  end

  module InstanceMethods
    attr_reader :age

    def init_age(hash)
      @age = hash[:age]
    end
  end

  module ClassMethods
    def has_age_groups(hash)
      hash.keys.each do |group_name|
        define_method("#{group_name}?") do
          hash[group_name].include?(@age)
        end
      end

      define_method("dead?") do
        hash.values.any? do |v|
          return false if v.include?(@age)
        end
        true
      end
    end
  end
end

class Dog
  include Mortality

  has_age_groups :young => (0..5), :old => (6..20)

  def initialize(hash = {})
    init_age(hash)
  end
end

class Human
  include Mortality
  include Intelligence

  has_age_groups :young => (0..16), :middle_aged => (17..50), :old => (51..80)

  def initialize(hash = {})
    init_age(hash)
    init_intelligence(hash)
  end
end

class Ghost
  include Intelligence

  def initialize(hash = {})
    init_intelligence(hash)
  end
end

require 'test/unit'

class IntelligentBeing
  include Intelligence

  def initialize(hash)
    init_intelligence(hash)
  end
end

class MortalBeing
  include Mortality::InstanceMethods
  extend Mortality::ClassMethods

  has_age_groups :young => (0..9), :old => (10..30)

  def initialize(hash)
    init_age(hash)
  end
end

class LongLivingMortalBeing
  include Mortality

  has_age_groups :young => (0..29), :middle_aged => (30..99), :old => (100..300)

  def initialize(hash)
    init_age(hash)
  end
end

class BeingsTest < Test::Unit::TestCase
  def test_initialize_human
    human = Human.new(:age => 20, :intelligence => 30)
    assert_equal 20, human.age
    assert_equal 30, human.intelligence
  end

  def test_initialize_dog
    dog = Dog.new(:age => 5)
    assert_equal 5, dog.age
  end

  def test_initialize_ghost
    ghost = Ghost.new(:intelligence => 200)
    assert_equal 200, ghost.intelligence
  end

  def test_intelligent_being_can_solve_problems
    being = IntelligentBeing.new(:intelligence => 50)
    assert !being.solve(51)
    assert being.solve(49)
  end

  def test_intelligent_being_inteligence_increases_after_solving_problem
    being = IntelligentBeing.new(:intelligence => 50)
    being.solve(49)
    assert_equal 51, being.intelligence

    being = IntelligentBeing.new(:intelligence => 50)
    being.solve(51)
    assert_equal 50, being.intelligence
  end

  def test_mortal_being_has_age_groups
    being = MortalBeing.new(:age => 9)
    assert being.young?
    assert !being.old?

    being = MortalBeing.new(:age => 10)
    assert !being.young?
    assert being.old?

    being = MortalBeing.new(:age => -1)
    assert !being.young?
    assert !being.old?
    assert being.dead?

    being = MortalBeing.new(:age => 31)
    assert !being.young?
    assert !being.old?
    assert being.dead?
  end

  def test_mortal_being_has_customizable_age_groups
    being = LongLivingMortalBeing.new(:age => 31)
    assert being.middle_aged?
  end

  def human_is_mortal_and_intelligent
    human = Human.new
    # TODO: human is instance methods? wird... ;)
    assert human.is_a?(Mortality)
    assert human.is_a?(Intelligence)
  end

  def dog_is_mortal_but_not_intelligent
    dog = Dog.new
    assert dog.is_a?(Mortality)
    assert !dog.is_a?(Intelligence)
  end

  def ghost_is_intelligent_but_not_mortal
    ghost = Ghost.new
    assert !ghost.is_a?(Mortality)
    assert ghost.is_a?(Intelligence)
  end
end

