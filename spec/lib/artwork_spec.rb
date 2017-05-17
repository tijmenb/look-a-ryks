require 'spec_helper'
require_relative './../../lib/artwork'

RSpec.describe Artwork do
  describe '.find' do
    it 'returns a Artwork hash' do
      expect(Artwork.find('RP-P-1910-4418')).to eql(
        'object_number' => 'RP-P-1910-4418',
        'image_url' => 'http://lh6.ggpht.com/IMe56fngoJjX-EUAycy-hVyBO7rpbyl5U2JkODyrvS5UfqMZ7MFlaJClUXfBt5zql879m_oj_2BiIbFu-nFWAqQVa0yi=s0',
        'long_title' => 'Portretten van twee courtisanes, Crispijn van de Passe (II), 1630 - 1632'
      )
    end
  end
end
