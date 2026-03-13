#!/usr/bin/env ruby
require 'fileutils'
require 'json'
require 'digest/sha2'

ASB_LEVEL = ARGV[0]

%w[a13 a13_tv a14 a14_tv a15 a16_qpr0 a16_qpr2 a16_tv].each do |variant|
  %w[system vendor].each do |img|
    %w[arm64 x86_64].each do |arch|
      %w[GAPPS VANILLA MAINLINE].each do |type|
        json_path   = File.join(variant, img == 'system' ? 'system/lineage' : img, "waydroid_#{arch}/#{type}.json")
        target_name = "#{variant.include?('tv') ? 'waydroid_tv' : 'waydroid'}_#{arch}"
        lineage_ver = \
            case variant
              when /^a13/
                'lineage-20.0'
              when /^a14/
                'lineage-21.0'
              when /^a15/
                'lineage-22.2'
              when 'a16_qpr0'
                'lineage-23.0'
              when 'a16_qpr2'
                'lineage-23.2'
              when 'a16_tv'
                'lineage-23.{0,2}'
              end

        if File.exist?(json_path)
          json = JSON.load_file(json_path, symbolize_names: true)
        else
          FileUtils.mkdir_p(File.dirname(json_path))
          json = { response: [] }
        end

        Dir["#{lineage_ver}-*-#{type}-#{target_name}-#{img}.zip"].each do |zip|
          stat = File.stat(zip)

          json[:response].delete_if { |e| e[:filename] == zip }
          json[:response] << {
            datetime: stat.mtime.to_i,
            filename: zip,
            id:       Digest::SHA256.file(zip),
            romtype:  type,
            asb:      ASB_LEVEL,
            size:     stat.size,
            url:      "https://sourceforge.net/projects/waydroid-atv/files/images/#{img}/#{target_name}/#{zip}/download",
            version:  zip[/^lineage-(\d+\.\d+)/, 1]
          }
        end

        next if json[:response].empty?
        json[:response].sort_by! { |e| - e[:datetime] }

        File.write(json_path, JSON.pretty_generate(json))
      end
    end
  end
end
