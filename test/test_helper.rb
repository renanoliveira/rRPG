#-*- coding: utf-8 -*-

require 'minitest/autorun'
require 'support'

require 'game'
require 'character'
require 'player_character'
require 'non_player_character'

class GameTestCase < MiniTest::Unit::TestCase
  def assert_action_called(action, char, times = 1)
    calls = char.called_actions[action]
    error = "#{char.name}#action? invoked #{calls} times."
    assert_equal(times, calls, error)
  end

  def assert_correct_scenario_on(char, game = @game)
    others = game.characters.reject{|c| c == char }

    assert_equal({others: others, tl: [0, 0], br: game.limits},
                 char.instance_variable_get("@scenario"))
  end
end

class MockedCharacter
  attr_accessor :called_actions, :name

  def initialize(name)
    @name, @called_actions = name, Hash.new(0)
  end

  def method_missing(sym, *args, &block)
    @called_actions[sym] += 1
  end

  def action?(scenario = {})
    @scenario = scenario
    @called_actions[:action?] += 1
    :full_attack if @called_actions[:action?] > 1
  end

  def dead?
    false
  end
end
