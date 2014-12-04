#!/usr/bin/env ruby
# encoding: UTF-8

require 'mongo'
require "test/unit"

include Mongo

class TestMongo < Test::Unit::TestCase

  def setup
    @client = MongoClient.new("localhost","27017")
    @db   = @client['test']
    @coll = @db['testcoll']
  end

  def test_connection
    assert(@client)
    assert(@db)
    assert(@coll)
  end

  def test_insert
    100.times do |i|
      @coll.insert({:count => i+1})
    end
    assert_equal(100,@coll.count)
  end

  def test_find
    entry = @coll.find({:count => 5}).to_a
    entry.each do |e|
      assert_equal(5,e['count'])
    end
  end

  def test_update
    @coll.update({ :count => 5}, { :count => 'foobar'})
    entry = @coll.find({:count => 'foobar'}).to_a
    entry.each do |e|
      assert_equal('foobar',e['count'])
    end
  end

  def test_remove
    @coll.remove
    assert_equal(0,@coll.count)
  end
end
