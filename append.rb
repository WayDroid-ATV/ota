#!/usr/bin/env ruby
require 'json'
require 'digest/sha2'

ASB_LEVEL = ARGV[0]

%w[A13 A13TV A14 A14TV A15 A15TV A16 A16TV].each do |variant|
  %w[system vendor].each do |img|
    %w[arm64 x86_64].each do |arch|
      %w[GAPPS VANILLA MAINLINE].each do |type|
        json_path   = File.join(variant, img == 'system' ? 'system/lineage' : img, "waydroid_#{arch}/#{type}.json")
        target_name = "#{variant.end_with?('TV') ? 'waydroid_tv' : 'waydroid'}_#{arch}"
        lineage_ver = \
            case variant
              when /^A13/
                "lineage-20.0"
              when /^A14/
                "lineage-21.0"
              when /^A15/
                "lineage-22.2"
              when /^A16/
                "lineage-23.2"
              end

        next unless File.exist?(json_path)
        json = JSON.load_file(json_path, symbolize_names: true)

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
            version:  lineage_ver.delete_prefix('lineage-')
          }
        end

        json[:response].sort_by! { |e| - e[:datetime] }

        File.write(json_path, JSON.pretty_generate(json))
      end
    end
  end
end
