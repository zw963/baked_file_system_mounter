require "baked_file_system"

module BakedFileSystemMounter
  macro assemble(mapping)
    {% unless mapping.is_a? HashLiteral || mapping.is_a? ArrayLiteral %}
      {% raise "assemble only support Array or Hash as the only argument." %}
    {% end %}

    {% new_mapping = {} of String => String %}

    {% if mapping.is_a? ArrayLiteral %}
      {% for value in mapping %}
        {% new_mapping[value] = value %}
      {% end %}
    {% elsif mapping.is_a? HashLiteral %}
      {% new_mapping = mapping %}
    {% end %}

    {% root = system("pwd").strip.id %}
    {% i, j = 0, 0 %}

    class BakedFileSystemStorage
      extend BakedFileSystem
      {% for key, value in new_mapping %}
        bake_folder "{{root}}/{{key.id}}"
        @@backed_files_{{i}} = {{ run("./baked_file_system_mounter/baked_files", key).strip }} of String
        {% i += 1 %}
      {% end %}

      def self.mount
        {% for key, value in new_mapping %}
          @@backed_files_{{j}}.each do |filename|
            target_file_name = filename.sub("{{key.id}}", "{{value.id}}")

            FileUtils.mkdir_p File.dirname(target_file_name) unless File.exists?(target_file_name)

            File.write(target_file_name, get(filename.sub("{{key.id}}/", "")).gets_to_end)

            {% j += 1 %}
          end
        {% end %}
      end
    end
  end
end
