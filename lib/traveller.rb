class Traveller
  # Parse locations for fun!
  #
  # Example:
  #   >> traveller = Traveller.new("canton, oh 44720")
  #   >> traveller.state
  #   => "Ohio"
  #
  # Arguments:
  #   input: (String)

  attr_accessor :city, :state, :latitude, :longitude, :zip, :state_abbreviation

  def initialize(input)
		@input = input.downcase

    # Begin parsing
    @zip = parse_zip

    if @input.include?(',')
      city_st = @input.split(',').map(&:strip)

      if city_st.length == 2
        parse_city_from(city_st[0])
        parse_state_from(city_st[1])
        return
      end
    end

    tokens = @input.split(' ')
    rough_parse(tokens)
  end

  def parse_zip
    zip = parse_us_zip
    zip = parse_canadian_zip if zip.nil?
    @input.sub!(zip, '') if zip.present?
    zip
  end

  def parse_us_zip
    us_zip_regex = /\b([0-9]{5})\b/.freeze
    @input[us_zip_regex]
  end

  def parse_canadian_zip
    can_zip_regex = /\b([abceghjklmnprstvxy]\d[abceghjklmnprstvwxyz]( )?\d[abceghjklmnprstvwxyz]\d)\b/.freeze
    @input[can_zip_regex]
  end

  def parse_city_from(str)
    @city = str.strip
  end

  def parse_state_from(str)
    tokens = str.split(' ').map(&:strip)
    matching_state = full_state_parse(tokens)

    if matching_state.present?
      @state = matching_state
      @state_abbreviation = convert_state_to_abbreviation(matching_state)
    else
      @state_abbreviation = check_abbreviations(tokens)
      @state = convert_abbreviation_to_state(@state_abbreviation)
    end
  end

  def rough_parse(tokens)
    max_negative_index = tokens.length * -1
    recursive_parse(tokens, max_negative_index)
  end

  def recursive_parse(tokens, index)
    if index == 0
      @city = parse_city_from(tokens.join(' '))
      return
    end

    matching_state = full_state_parse(tokens[index..-1])

    if matching_state.present?
      @state = matching_state
      @state_abbreviation = convert_state_to_abbreviation(matching_state)
      @city = parse_city_from(tokens[0..index-1].join(' ')) unless index == tokens.length * -1
      return
    end

    matching_abbreviation = check_abbreviations(tokens[index..-1])
    if matching_abbreviation.present?
      @state = convert_abbreviation_to_state(matching_abbreviation)
      @state_abbreviation = matching_abbreviation
      @city = parse_city_from(tokens[0..index-1].join(' ')) unless index == tokens.length * -1
      return
    end

    return recursive_parse(tokens, index + 1)
  end

  def full_state_parse(tokens)
    matching_state = check_three_word_states(tokens)
    matching_state = check_two_word_states(tokens) if matching_state.nil?
    matching_state = check_one_word_states(tokens) if matching_state.nil?
    matching_state
  end

  def check_three_word_states(tokens)
    token_str = tokens.join(' ')
    three_word_states = state_names_by_num_of_words(3)
    three_word_states.find { |s| s == token_str }
  end

  def check_two_word_states(tokens)
    token_str = tokens.join(' ')
    two_word_states = state_names_by_num_of_words(2)
    two_word_states.find { |s| s == token_str }
  end

  def check_one_word_states(tokens)
    token_str = tokens.join(' ')
    one_word_states = state_names_by_num_of_words(1)
    one_word_states.find { |s| s == token_str }
  end

  def check_abbreviations(tokens)
    token_str = tokens.join(' ')
    abbreviations = us_state_abbreviations + province_abbreviations
    abbreviations.find { |s| s == token_str }
  end

  private

  def us_state_to_abbreviation_mappings
    { 'alabama' => 'al', 'alaska' => 'ak', 'america samoa' => 'as', 'arizona' => 'az', 'arkansas' => 'ar', 'california' => 'ca', 'colorado' => 'co', 'connecticut' => 'ct',
      'delaware' => 'de', 'district of columbia' => 'dc', 'micronesia1' => 'fm', 'florida' => 'fl', 'georgia' => 'ga', 'guam' => 'gu', 'hawaii' => 'hi', 'idaho' => 'id',
      'illinois' => 'il', 'indiana' => 'in', 'iowa' => 'ia', 'kansas' => 'ks', 'kentucky' => 'ky', 'louisiana' => 'la', 'maine' => 'me', 'marshall isands' => 'mh',
      'maryland' => 'md', 'massachusetts' => 'ma', 'michigan' => 'mi', 'minnesota' => 'mn', 'mississippi' => 'ms', 'missouri' => 'mo', 'montana' => 'mt', 'nebraska' => 'ne',
      'nevada' => 'nv', 'new hampshire' => 'nh', 'new jersey' => 'nj', 'new mexico' => 'nm', 'new york' => 'ny', 'north carolina' => 'nc', 'north dakota' => 'nd',
      'ohio' => 'oh', 'oklahoma' => 'ok', 'oregon' => 'or', 'palau' => 'pw', 'pennsylvania' => 'pa', 'puerto rico' => 'pr', 'rhode island' => 'ri', 'south carolina' => 'sc',
      'south dakota' => 'sd', 'tennessee' => 'tn', 'texas' => 'tx', 'utah' => 'ut', 'vermont' => 'vt', 'virgin island' => 'vi', 'virginia' => 'va', 'washington' => 'wa',
      'west virginia' => 'wv', 'wisconsin' => 'wi', 'wyoming' => 'wy' }
  end

  def province_to_abbreviation_mappings
    {
      'alberta' => 'ab', 'british columbia' => 'bc', 'manitoba' => 'mb', 'new brunswick' => 'nb', 'newfoundland & labrador' => 'nl', 'newfoundland and labrador' => 'nl',
      'nova scotia' => 'ns', 'northwest territories' => 'nt', 'nunavut' => 'nu', 'ontario' => 'on',
      'prince edward island' => 'pe', 'quebec' => 'qc', 'saskatchewan' => 'sk', 'yukon' => 'yt'
    }
  end

  def us_state_abbreviations
    us_state_to_abbreviation_mappings.values
  end

  def province_abbreviations
    province_to_abbreviation_mappings.values
  end

  def us_state_names
    us_state_to_abbreviation_mappings.keys
  end

  def province_names
    province_to_abbreviation_mappings.keys
  end

  def state_names_by_num_of_words(number_of_words)
    state_names = us_state_names + province_names
    state_names.select { |state_name| state_name.split.size == number_of_words }
  end

  def state_to_abbreviation_mappings
    us_state_to_abbreviation_mappings.merge(province_to_abbreviation_mappings)
  end

  def convert_abbreviation_to_state(abbreviation)
    mappings = state_to_abbreviation_mappings.invert
    mappings[abbreviation]
  end

  def convert_state_to_abbreviation(state)
    state_to_abbreviation_mappings[state]
  end
end
