require File.expand_path '../spec_helper.rb', __FILE__
require 'json'

RSpec.describe "Alma Webhook receiver app", type: :request do
  let(:bib_updated_json) do
    {
        "id"=>"3235071115491107182",
        "action"=>"BIB",
        "institution"=>{"value"=>"01UPENN_INST", "desc"=>"University of Pennsylvania"},
        "time"=>"2020-08-17T15:03:24.605Z",
        "event"=>{"value"=>"BIB_UPDATED", "desc"=>"BIB record updated"},
        "bib"=>{
            "mms_id"=>"9977111159403681", "record_format"=>"marc21", "linked_record_id"=>{
                "value"=>"993400000000015976", "type"=>"CZ"},
            "title"=>"Farm and Business : The Journal of the Caribbean Agro-Economic Society",
            "author"=>nil, "issn"=>nil, "isbn"=>nil,
            "network_number"=>["(CKB)3400000000015976", "(EXLCZ)993400000000015976"],
            "place_of_publication"=>"St. Augustine",
            "publisher_const"=>"Caribbean Agro-Economic Society",
            "holdings"=>
                {"value"=>"", "link"=>"/almaws/v1/bibs/9977111159403681/holdings"},
            "created_by"=>"NON_SFX_CREATOR", "created_date"=>"2012-02-25Z",
            "last_modified_by"=>"System", "last_modified_date"=>"2020-08-17Z",
            "suppress_from_publishing"=>"false", "suppress_from_external_search"=>"false",
            "sync_with_oclc"=>"NONE", "sync_with_libraries_australia"=>"NONE",
            "originating_system"=>"NON_SFX", "originating_system_id"=>"993400000000015976",
            "anies"=>["__XML__"], "requests"=>nil, "link"=>nil},
        "holding"=>nil, "item"=>nil, "portfolio"=>nil, "representation"=>nil
    }.to_json
  end
  let(:bib_deleted_json) do
    {
        "id"=>"3229093755673699933", "action"=>"BIB",
        "institution"=>{"value"=>"01UPENN_INST", "desc"=>"University of Pennsylvania"},
        "time"=>"2020-08-17T15:21:45.747Z", "event"=>
            {"value"=>"BIB_DELETED", "desc"=>"BIB record deleted"},
        "bib"=>{
            "mms_id"=>"9977111307103681", "record_format"=>"marc21", "linked_record_id"=>
                {"value"=>"993780000000297684", "type"=>"CZ"},
            "title"=>"IFPRI Discussion Papers", "author"=>nil, "issn"=>nil, "isbn"=>nil,
            "network_number"=>["(CKB)3780000000297684", "(EXLCZ)993780000000297684"],
            "publisher_const"=>"International Food Policy Research Institute",
            "holdings"=>{
                "value"=>"", "link"=>"/almaws/v1/bibs/9977111307103681/holdings"},
            "created_by"=>"NON_SFX_CREATOR", "created_date"=>"2017-05-14Z",
            "last_modified_by"=>"System", "last_modified_date"=>"2020-08-17Z",
            "suppress_from_publishing"=>"false", "suppress_from_external_search"=>"false",
            "sync_with_oclc"=>"BIBS", "sync_with_libraries_australia"=>"NONE",
            "originating_system"=>"NON_SFX", "originating_system_id"=>"993780000000297684",
            "anies"=>["__XML__"], "requests"=>nil, "link"=>nil},
        "holding"=>nil, "item"=>nil, "portfolio"=>nil, "representation"=>nil
    }.to_json
  end
  let(:bib_added_json) do
      {
          "id"=>"7120811384122420557", "action"=>"BIB",
          "institution"=>{"value"=>"01UPENN_INST", "desc"=>"University of Pennsylvania"},
          "time"=>"2020-08-17T15:03:25.393Z", "event"=>
              {"value"=>"BIB_CREATED", "desc"=>"BIB record created"},
          "bib"=>{
              "mms_id"=>"9977795539303681", "record_format"=>"marc21",
              "linked_record_id"=>{"value"=>"993390000000032320", "type"=>"CZ"},
              "title"=>"Stata Journal", "author"=>nil, "issn"=>nil, "isbn"=>nil,
              "network_number"=>["(CKB)3390000000032320", "(EXLCZ)993390000000032320"],
              "holdings"=>{"value"=>"", "link"=>"/almaws/v1/bibs/9977795539303681/holdings"},
              "created_by"=>"CKB", "created_date"=>"2013-05-25Z", "last_modified_by"=>"System",
              "last_modified_date"=>"2020-08-17Z", "suppress_from_publishing"=>"false",
              "suppress_from_external_search"=>"false", "sync_with_oclc"=>"NONE",
              "sync_with_libraries_australia"=>"NONE", "originating_system"=>"CKB",
              "originating_system_id"=>"(CKB)3390000000032320",
              "anies"=>["__XML__"], "requests"=>nil, "link"=>nil},
          "holding"=>nil, "item"=>nil, "portfolio"=>nil, "representation"=>nil
      }.to_json
    end
  context 'GET' do
    it "respond at /" do
      get '/'
      expect(last_response).to be_ok
    end
    it 'echos a challenge param' do
      get '/', challenge: 'test'
      expect(last_response.body).to include 'test'
    end
  end
  context 'POST' do
    context 'validates message integrity' do
      it 'returns 200 if signature header is valid' do
        header 'X-Exl-Signature', 'm7izclXuZdi/sg9d1RfmJ50gY2rDqJyLGhfFmC2pp6I='
        header 'CONTENT_TYPE', 'application/json'
        post '/', bib_updated_json
        expect(last_response.status).to eq 204
      end
      it 'returns 401 if signature header is NOT valid' do
        header 'X-Exl-Signature', 'baaaaaaad'
        header 'CONTENT_TYPE', 'application/json'
        post '/', bib_updated_json
        expect(last_response.status).to eq 401
      end
    end
    context 'handles responses accordingly' do
      before do
        allow(MessageValidator).to receive(:valid?).and_return true
      end
      it 'by sending a slack message if created bib' do
        post '/', bib_added_json
        expect_any_instance_of(SlackNotifier).to receive(:ping)
      end
      it 'by NOT sending a slack message if updated bib' do
        post '/', bib_updated_json
        expect(SlackNotifier).not_to receive(:ping)
      end
    end
  end
end