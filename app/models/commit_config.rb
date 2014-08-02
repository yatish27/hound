class CommitConfig
  HOUND_CONFIG_FILE = ".hound.yml"

  def initialize(commit)
    @commit = commit
  end

  def to_hash
    config_files.inject({}) { |accum, config| accum.merge(config) }
  end

  private

  def config_files
    (included_config_files + [hound_config]).compact
  end

  def hound_config
    @hound_config ||= load_config_file(HOUND_CONFIG_FILE)
  end

  def included_config_file_paths
    if hound_config
      hound_config.delete("Include") || []
    else
      []
    end
  end

  def included_config_files
    @included_config_files ||= included_config_file_paths.map do |file_path|
      load_config_file(file_path)
    end
  end

  def load_config_file(file_path)
    raw_yaml = @commit.file_content(file_path)

    if raw_yaml
      YAML.load(raw_yaml)
    end
  end
end
