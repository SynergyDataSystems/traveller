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
    zip = @input[/\b([0-9]{5})\b/]
    @input.sub!(zip, '') unless zip.nil?
    zip
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
    three_word_states = ['district of columbia']
    three_word_states.find { |s| s == token_str }
  end

  def check_two_word_states(tokens)
    token_str = tokens.join(' ')
    two_word_states = ['new hampshire', 'new jersey', 'new mexico', 'new york', 'north carolina', 'north dakota', 'puerto rico', 'rhode island', 'south carolina', 'south dakota', 'west virginia' ]
    two_word_states.find { |s| s == token_str }
  end

  def check_one_word_states(tokens)
    token_str = tokens.join(' ')
    one_word_states = ['alabama', 'alaska', 'arizona', 'arkansas', 'california', 'colorado', 'connecticut', 'delaware', 'florida', 'georgia', 'hawaii', 'idaho', 'illinois', 'indiana', 'iowa', 'kansas', 'kentucky', 'louisiana', 'maine', 'maryland', 'massachusetts', 'michigan', 'minnesota', 'mississippi', 'missouri', 'montana',  'nebraska', 'nevada', 'ohio', 'oklahoma', 'oregon', 'pennsylvania', 'tennessee', 'texas', 'utah', 'vermont', 'virginia', 'washington', 'wisconsin', 'wyoming']
    one_word_states.find { |s| s == token_str }
  end

  def check_abbreviations(tokens)
    token_str = tokens.join(' ')
    abbreviations = ['al', 'ak', 'az', 'ar', 'ca', 'co', 'ct', 'de', 'dc', 'fl', 'ga', 'hi', 'id', 'il', 'in', 'ia', 'ks', 'ky', 'la', 'me', 'md', 'ma', 'mi', 'mn', 'ms', 'mo', 'mt', 'ne', 'nv', 'nh', 'nj', 'nm', 'ny', 'nc', 'nd', 'oh', 'ok', 'or', 'pa', 'pr', 'ri', 'sc', 'sd', 'tn', 'tx', 'ut', 'vt', 'va', 'wa', 'wv', 'wi', 'wy']
    abbreviations.find { |s| s == token_str }
  end

  private

  def state_to_abbreviation_mappings
    { 'alabama' => 'al', 'alaska' => 'ak', 'america samoa' => 'as', 'arizona' => 'az', 'arkansas' => 'ar', 'california' => 'ca', 'colorado' => 'co', 'connecticut' => 'ct',
      'delaware' => 'de', 'district of columbia' => 'dc', 'micronesia1' => 'fm', 'florida' => 'fl', 'georgia' => 'ga', 'guam' => 'gu', 'hawaii' => 'hi', 'idaho' => 'id',
      'illinois' => 'il', 'indiana' => 'in', 'iowa' => 'ia', 'kansas' => 'ks', 'kentucky' => 'ky', 'louisiana' => 'la', 'maine' => 'me', 'marshall isands' => 'mh',
      'maryland' => 'md', 'massachusetts' => 'ma', 'michigan' => 'mi', 'minnesota' => 'mn', 'mississippi' => 'ms', 'missouri' => 'mo', 'montana' => 'mt', 'nebraska' => 'ne',
      'nevada' => 'nv', 'new hampshire' => 'nh', 'new jersey' => 'nj', 'new mexico' => 'nm', 'new york' => 'ny', 'north carolina' => 'nc', 'north dakota' => 'nd',
      'ohio' => 'oh', 'oklahoma' => 'ok', 'oregon' => 'or', 'palau' => 'pw', 'pennsylvania' => 'pa', 'puerto rico' => 'pr', 'rhode island' => 'ri', 'south carolina' => 'sc',
      'south dakota' => 'sd', 'tennessee' => 'tn', 'texas' => 'tx', 'utah' => 'ut', 'vermont' => 'vt', 'virgin island' => 'vi', 'virginia' => 'va', 'washington' => 'wa',
      'west virginia' => 'wv', 'wisconsin' => 'wi', 'wyoming' => 'wy' }
  end

  def convert_abbreviation_to_state(abbreviation)
    mappings = state_to_abbreviation_mappings.invert
    mappings[abbreviation]
  end

  def convert_state_to_abbreviation(state)
    state_to_abbreviation_mappings[state]
  end
end
