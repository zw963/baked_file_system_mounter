require "baked_file_system"

module BakedFileSystemMounter
  macro assemble(from, to)
    {% begin %}
      {% root = system("pwd").strip.id %}

      class BakedFileSystemStorage
        extend BakedFileSystem
        BACKED_FILES = {{ run("./backed_files", from) }}

        bake_folder "{{root}}/{{from.id}}"

        def self.mount
          BACKED_FILES.each do |filename|
            target_file_name = filename.sub("{{from.id}}", "{{to.id}}")

            FileUtils.mkdir_p File.dirname(target_file_name) unless File.exists?(target_file_name)

            File.write(target_file_name, get(filename.sub("{{from.id}}/", "")).gets_to_end)
          end
        end
      end
    {% end %}
  end
end
