# encoding: utf-8
require 'rails_helper'

RSpec.describe TiSqlegalize::Query, :type => :model do

  before(:each) { Resque.redis = MockRedis.new }

  let!(:queue) { Resque.queue_from_class(TiSqlegalize::Query) }

  let!(:query) { TiSqlegalize::Query.new('select 1') }

  it 'creates new queries' do
    query.create!
    expect(query.id).not_to be_nil
    expect(query.status).to eq(:created)
    expect(Resque.redis.keys.length).to eq(2)
  end

  it 'does not save nonexistent queries' do
    query.status = :finished
    query.save!
    expect(query.id).to be_nil
    expect(Resque.redis.keys.length).to eq(0)
  end

  it 'updates created queries' do
    query.create!
    query.status = :finished
    query.save!

    q = TiSqlegalize::Query.find(query.id)
    expect(q.status).to eq(:finished)
  end

  it 'appends rows' do
    query.create!
    rows = ['a','b','c']
    query << rows

    q = TiSqlegalize::Query.find(query.id)
    expect(q[0, 10]).to eq(rows)
  end

  it 'perform statement' do
    query.create!

    rows = ['a','b','c']
    expect(TiSqlegalize::Query).to \
      receive(:execute).with(query.statement).and_return(rows)

    TiSqlegalize::Query.perform(query.id)

    q = TiSqlegalize::Query.find(query.id)
    expect(q[0, 10]).to eq(rows)
  end
end
