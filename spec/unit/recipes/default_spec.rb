require 'spec_helper'

describe 'mysql-resources::default' do
  context 'When all attributes are default, on an unspecified platform' do
    platform 'redhat'

    it 'converges successfully' do
      expect { chef_run }.to_not raise_error
    end
  end

  context 'When all attributes are default, on an unspecified platform' do
    platform 'ubuntu'

    it 'converges successfully' do
      expect { chef_run }.to_not raise_error
    end
  end
end
