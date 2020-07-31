# frozen_string_literal:true
require Rails.root.join('api', 'gen', 'api', 'pancake', 'maker', 'pancake_pb')
require Rails.root.join('api', 'gen', 'api', 'pancake', 'maker', 'pancake_services_pb')
require 'grpc'

module RubyLogger
  def logger
    LOGGER
  end

  LOGGER = Logger.new(STDOUT)
  LOGGER.level = :debug
end

module GRPC
  extend RubyLogger
end

class Bakery
  include ActiveModel::Model

  class Menu
    CLASSIC = "classic"
    BANANA_AND_WHIP = "babana_and_whip"
    BACON_AND_CHEESE = "bacon_and_cheese"
    MIX_BERRY = "mix_berry"
    BAKED_MARSHMALLOW = "baked_marshmallow"
    SPICY_CURRY = "spicy_curry"
  end

  def self.bake_pancake(menu)
    req = Pancake::Maker::BakeRequest.new({
             menu: pb_menu(menu),
          })

    res = stub.bake(req)

    {
        chef_name: res.pancake.chef_name,
        menu: res.pancake.menu,
        technical_score: res.pancake.technical_score,
        create_time: res.pancake.create_time,
    }
  end

  def self.report
    res = stub.report(Pancake::Maker::ReportRequest.new())

    res.report.bake_counts.map {|r| [r.menu, r.count]}.to_h
  end

  def self.pb_menu(menu)
    case menu
    when Menu::CLASSIC
      :CLASSIC
    when Menu::BANANA_AND_WHIP
      :BANANA_AND_WHIP
    when Menu::BACON_AND_CHEESE
      :BACON_AND_CHEESE
    when Menu::MIX_BERRY
      :MIX_BERRY
    when Menu::BAKED_MARSHMALLOW
      :BAKED_MARSHMALLOW
    when Menu::SPICY_CURRY
      :SPICY_CURRY
    else
      raise "unknown menu: #{menu}"
    end
  end

  def self.config_dsn
    "127.0.0.1:50051"
  end

  def self.stub
    Pancake::Maker::PancakeBakerService::Stub.new(
        config_dsn,
        :this_channel_is_insecure,
        timeout: 10
    )
  end
end
