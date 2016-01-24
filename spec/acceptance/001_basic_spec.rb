require 'spec_helper_acceptance'

describe "topbeat class:" do

  package_name = 'topbeat'
  service_name = 'topbeat'
  pid_file     = '/var/run/topbeat.pid'

  describe "default parameters" do

    it 'should run successfully' do
      pp = "
      class { 'topbeat':
        output => {
          'logstash' => {
            'hosts' => [
              'localhost:5044',
            ],
          },
        },
      }"

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      sleep 5
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero
      sleep 5
    end

    describe service(service_name) do
      it { should be_enabled }
      it { should be_running }
    end

    describe package(package_name) do
      it { should be_installed }
    end

    describe file(pid_file) do
      it { should be_file }
      its(:content) { should match /[0-9]+/ }
    end

    it 'Show all running topbeat processes' do
      shell('ps auxfw | grep topbeat | grep -v grep')
    end

  end

end
