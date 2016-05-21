# encoding: utf-8
require 'rails_helper'

describe TiSqlegalize::V2::RelationsController do

  let!(:query) { Fabricate(:finished_query) }

  context "without and authenticated user" do

    it "requires authentication" do
      get_api :show, query_id: query.id
      expect(response.status).to eq(401)
    end

  end

  context "with an authenticated user" do

    let(:user) { Fabricate(:user) }

    before(:each) { sign_in user }

    it "fetches a query result" do
      get_api :show, query_id: query.id
      expect(response.status).to eq(200)
      expect(jsonapi_type).to eq('relation')
      expect(jsonapi_id).to eq(query.id)
      expect(jsonapi_data).to reside_at(v2_query_result_url(query.id))
      expect(jsonapi_attr 'sql').to eq(query.statement)
      expect(jsonapi_attr 'heading').to eq(['a'])
      expect(jsonapi_rel 'heading_a').to \
        relate_to(v2_query_result_heading_url(query.id, 'a'))
      expect(jsonapi_rel 'body').to \
        relate_to(v2_query_result_body_url(query.id))
    end
  end
end