Puppet::Type.type(:vpp_config).provide(:vpp) do

  def file_path
    '/etc/vpp/startup.conf'
  end

  def initialize(value={})
    super(value)
    settings_arr = @resource[:setting].split('/')
    @section = settings_arr[0]
    @real_setting = settings_arr[1]
    @dev = settings_arr[2]

    if @section.nil? || @real_setting.nil?
      fail("#{@resource[:setting]} is not a valid setting string")
    end

    if @dev
      @search_regex = /^\s*dev\s+#{@dev}\s*{([^}]*)}?/
    else
      @search_regex = /^\s*#{@real_setting}\s+(\S+)?/
    end

  end

  def write_config(config)
    if File.read(file_path) != config
      File.open(file_path, 'w') do |fh|
        fh.puts(config)
      end
    end
  end

  def get_sections
    vpp_config = File.read(file_path)
    scanner = StringScanner.new vpp_config

    #first skip to section beginning
    string = scanner.scan_until(/^\s*#{@section}\s*{\s*/)

    #if we can't find the section, add it to the end
    return vpp_config+"\n#{@section} {", "", "}\n" unless string

    level = 1
    before = string
    after = ''
    section_config = ''

    while current_char = scanner.getch
      case current_char
      when '{'
        level += 1
        section_config << current_char
      when '}'
        level -= 1
        if level == 0
          after = current_char + scanner.post_match
          break
        else
          section_config << current_char
        end
      else
        section_config << current_char
      end
    end

    fail("Failed to parse VPP config: #{vpp_config}") unless level == 0
    return before, section_config, after
  end

  def add_setting(value)
    before, section_config, after = get_sections

    if @dev
      if value.to_s.empty?
        setting_string = "#{@real_setting} #{@dev}"
      else
        setting_string = "#{@real_setting} #{@dev} {#{value}}"
      end
    else
      setting_string = "#{@real_setting} #{value}"
    end

    if section_config =~ @search_regex
      section_config.sub!(@search_regex, "  #{setting_string}")
    else
      section_config.rstrip!
      section_config << "\n  #{setting_string}\n"
    end

    write_config(before+section_config+after)
  end

  def create
    add_setting(@resource[:value])
  end

  def destroy
    before, section_config, after = get_sections
    section_config.sub!(@search_regex, "")
    write_config(before+section_config+after)
  end

  def exists?
    before, section_config, after = get_sections
    @search_regex.match(section_config)
  end

  def value
    before, section_config, after = get_sections
    @search_regex.match(section_config) { |m| m[1] }
  end

  def value=(value)
    add_setting(value)
  end

end
