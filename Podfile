# Uncomment the next line to define a global platform for your project
platform :ios, '9.0'

target 'TodayDiary' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for TodayDiary
  pod 'FSCalendar'
end


post_install do |installer|
  installer.generated_projects.each do |project|
    project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
        config.build_settings.delete('GENERATE_INFOPLIST_FILE') if target.name.start_with?('FSCalendar')
      end
    end
  end
end