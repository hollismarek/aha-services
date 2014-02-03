require 'spec_helper'

describe AhaServices::Redmine do

  context 'feature creation' do
    let(:project_id) { 2 }
    let(:service) do
      described_class.new(
        { redmine_url: 'http://localhost:4000', project_id: project_id, api_key: '123456' },
        json_fixture('create_feature_event.json')
      )
    end

    before do
      stub_aha_api_posts
    end

    it "responds to receive(:create_feature)" do
      expect(service).to receive(:receive_create_feature)
      service.receive(:create_feature)
    end

    context 'authenticated' do
      context 'not versioned' do
        before { populate_redmine_projects service }

        context 'available tracker' do
          let(:issue_create_raw) { raw_fixture 'redmine/issues/create.json' }
          before do
            stub_request(:post, "#{service.data.redmine_url}/projects/#{project_id}/issues.json").
              to_return(status: 201, body: issue_create_raw, headers: {})
          end
          it "sends one integration messages for issue and for requirement" do
            # integration messages for the issue
            expect(service.api).to receive(:create_integration_field).with("PROD-2", "redmine_issues", :id, anything).once
            expect(service.api).to receive(:create_integration_field).with("PROD-2", "redmine_issues", :url, anything).once
            expect(service.api).to receive(:create_integration_field).with("PROD-2", "redmine_issues", :name, anything).once
            # integration messages for issue's requirement
            expect(service.api).to receive(:create_integration_field).with("PROD-2-1", "redmine_issues", :id, anything).once
            expect(service.api).to receive(:create_integration_field).with("PROD-2-1", "redmine_issues", :url, anything).once
            expect(service.api).to receive(:create_integration_field).with("PROD-2-1", "redmine_issues", :name, anything).once
            service.receive(:create_feature)
          end
        end
        context 'unavailable tracker' do
          let(:tracker_id) { 4 }
          before do
            stub_request(:post, "#{service.data.redmine_url}/projects/#{project_id}/issues.json").
              to_return(status: 201, body: issue_create_raw, headers: {})
          end
          it "returns error" do
            expect(service.api).not_to receive(:create_integration_field)
            service.receive(:create_feature)
          end
        end
      end

      context 'versioned' do
        before { populate_redmine_projects_and_versions service }
        context 'available tracker' do
        end
        context 'unavailable tracker' do
          let(:tracker_id) { 4 }
        end
      end
    end
  end
end