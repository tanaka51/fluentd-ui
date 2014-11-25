require "spec_helper"

describe "out_stdout" do
  let(:exists_user) { build(:user) }
  let(:daemon) { build(:fluentd, variant: "td-agent") }
  let(:match) { "stdout.**" }

  before do
    Fluentd.stub(:instance).and_return(daemon)
    Fluentd::Agent::TdAgent.any_instance.stub(:detached_command).and_return(true)
    daemon.agent.config_write ""
    
    visit '/sessions/new'
    within("form") do
      fill_in 'session_name', :with => exists_user.name
      fill_in 'session_password', :with => exists_user.password
    end
    click_button I18n.t("terms.sign_in")
  end

  it "Shown form with filled in td.*.* on match" do
    visit daemon_setting_out_stdout_path
    page.should have_css('input[name="fluentd_setting_out_stdout[match]"]')
  end

  it "Updated config after submit" do
    daemon.agent.config.should_not include(match)
    visit daemon_setting_out_stdout_path
    within('#new_fluentd_setting_out_stdout') do
      fill_in "Match", with: match
    end
    click_button I18n.t("fluentd.common.finish")
    daemon.agent.config.should include(match)
  end
end
