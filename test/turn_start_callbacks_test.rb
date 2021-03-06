#-*- coding: utf-8 -*-

require 'test_helper'

class TurnStartCallbacksTest < GameTestCase
  def test_without_callbacks_registered
    char = CharacterWithoutCallbacks.new 'WithoutTurnStart'
    char.turn_start!

    refute char.callback_calls
  end

  def test_turn_start_should_calls_callback
    char = CharacterWithCallbacks.new 'WithTurnStart'
    char.turn_start!

    assert_equal 2, char.callback_calls
  end

  def test_callbacks_should_be_called_once
    char = CharacterWithRepeatedCallbacks.new 'WithRepeatedTurnStart'
    char.turn_start!

    assert_equal 2, char.callback_calls
  end

  def test_instances_callbacks
    magneto   = CharacterWithCallbacks.new 'WithTurnStart1'
    wolverine = CharacterWithCallbacks.new 'WithTurnStart2'

    def wolverine.regenerate
      @callback_calls ||= 0
      @callback_calls  += 1

      @regenerated = true  # do something with health!
    end

    magneto.turn_start!

    wolverine.before_turn_start :regenerate
    wolverine.turn_start!

    assert_equal 2,   magneto.callback_calls
    assert_equal 3, wolverine.callback_calls

    assert(wolverine.instance_variable_get("@regenerated"),
           'ObjectCallback not called on before_turn_start')
  end

  def test_turn_start_order
    char = CharacterWithoutCallbacks.new 'WithoutTurnStart'

    def char.callback1
      @called_callbacks ||= []
      @called_callbacks << '1st'
    end

    def char.callback2
      @called_callbacks ||= []
      @called_callbacks << '2nd'
    end

    char.instance_variable_set("@before_turn_start_callbacks",
                               ['callback1', :callback2])

    char.turn_start!

    assert_equal(char.instance_variable_get("@called_callbacks"),
                 ['1st', '2nd'])
  end

  private
  class CharacterWithoutCallbacks < Character::Base
    attr_accessor :callback_calls
  end

  class CharacterWithCallbacks < CharacterWithoutCallbacks
    before_turn_start :my_1st_custom_callback
    before_turn_start :my_2nd_custom_callback

    def my_1st_custom_callback
      @callback_calls ||= 0
      @callback_calls  += 1
    end

    def my_2nd_custom_callback
      @callback_calls ||= 0
      @callback_calls  += 1
    end
  end

  class CharacterWithRepeatedCallbacks < CharacterWithCallbacks
    before_turn_start :my_1st_custom_callback
  end
end
