platform :ios, '9.0'
use_frameworks!
inhibit_all_warnings!

def pods
    pod 'SwiftyBeaver'
    pod 'pop','~>1.0.6'
    pod 'SnapKit'
end

target 'SSComponents' do
    pods
end

#每次执行install时，修改编译配置
post_install do |installer|
    
    #打开 wholeMoldule 优化
    installer.pods_project.build_configurations.each do |config|
    if config.name == 'Debug'
        config.build_settings['OTHER_SWIFT_FLAGS'] = ['$(inherited)', '-Onone']
        config.build_settings['SWIFT_OPTIMIZATION_LEVEL'] = '-Owholemodule'
        end
    end
end
