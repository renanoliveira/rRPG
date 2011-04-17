#-*- coding: utf-8 -*-

require 'test_helper'

class RunGameTurnTest < GameTestCase
  def setup
    @game   = Game.new :dimensions => [5, 5]

    @player = MockedCharacter.new('Player')
    @enemy1 = MockedCharacter.new('Enemy1')

    @game.characters << @player
    @game.characters << @enemy1
  end

  def test_call_before_turn_start_callback_on_all_characters
    @game.run_a_turn
    @game.characters.each do |char|
      assert_action_called(:before_turn_start, char)
    end
  end

  def test_ask_which_action_to_run_on_all_characters
    @game.run_a_turn
    @game.characters.each do |char|
      assert_action_called(:action?, char, 2)
    end
  end

  def test_ask_which_action_params
    @game.run_a_turn

    assert_equal({:others => [@enemy1],
                   :tl => [0, 0], :br => [4, 4]},
                 @player.instance_variable_get("@scenario"))

    assert_equal({:others => [@player],
                   :tl => [0, 0], :br => [4, 4]},
                 @enemy1.instance_variable_get("@scenario"))
  end

  def test_call_action_on_all_characters
    @game.run_a_turn
    @game.characters.each do |char|
      assert_action_called(:full_attack, char, 1)
    end
  end

  def test_call_action_params
    def @player.full_attack(scenario = {})
      @scenario = scenario
    end

    @game.run_a_turn

    assert_equal({:others => [@enemy1],
                   :tl => [0, 0], :br => [4, 4]},
                 @player.instance_variable_get("@scenario"))

    assert_equal({:others => [@player],
                   :tl => [0, 0], :br => [4, 4]},
                 @enemy1.instance_variable_get("@scenario"))
  end

  def test_run_a_turn_return_ok_in_normal_turns
    assert(@game.run_a_turn,
           '#run_a_turn should returning true to keep the loop chain')
  end

  def test_stop_game_if_quit_action_called
    def @player.action? scenario
      :quit
    end

    assert_nil(@game.run_a_turn,
               'Game#finish_game not invoked when :quit action wass called')
  end

  def test_know_action_types
    assert_equal([:quit, :move, :full_attack, :move_and_attack],
                 @game.know_actions)
  end
end